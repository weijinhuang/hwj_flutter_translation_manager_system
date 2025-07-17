import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'package:hwj_translation_flutter/net.dart';
import 'dart:collection';
import 'dart:convert';

class EditTranslationDetailPage extends StatefulWidget {
  EditTranslationDetailPage(this.projectId, this.moduleId, this.translationKey, this.languageIdToTranslationMap, this.languageList);

  String projectId;
  int moduleId;
  String? translationKey;
  Map<int, Translation>? languageIdToTranslationMap;
  List<Language> languageList;

  @override
  State<StatefulWidget> createState() => _EditTranslationDetailPage();
}

class _EditTranslationDetailPage extends State<EditTranslationDetailPage> with SingleTickerProviderStateMixin {
  _EditTranslationDetailPage();

  String defaultFrom = "en";
  Set<Translation> translationChangedList = {};

  String translationKeyChange = "";
  String? defaultTranslateSrc; //调用翻译接口时候的基准翻译文本
  // Map<int, String?> translationContentMap = HashMap();
  Map<int, Translation> translationContentMap = HashMap();
  String loadingLanguageName = "";

  late final Animation<double> _animation;
  late final AnimationController _repeatController;
  late final TextEditingController _translationKeyController;

  @override
  void initState() {
    super.initState();
    _repeatController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_repeatController);

    //确认翻译使用的基准语言（使用语言列表的第一个）
    defaultFrom = widget.languageList.first.languageName;

    // if (null != widget.languageIdToTranslationMap) {
    //   for (var language in widget.languageList) {
    //     int languageId = language.languageId!;
    //     translationContentMap[languageId] = widget.languageIdToTranslationMap?[languageId]?.translationContent;
    //   }
    // }
    var map = widget.languageIdToTranslationMap;

    // translationContentMap = deepCopyMap(map);
    for (Language language in widget.languageList) {
      int? languageId = language.languageId;
      if (null != languageId) {
        Translation? originalTranslation;
        if (map != null) {
          originalTranslation = map[languageId];
        }
        if (originalTranslation != null) {
          var json = originalTranslation.toJson();
          var editTranslation = Translation.fromJson(json);
          translationContentMap[languageId] = editTranslation;
        } else {
          Translation editTranslation = Translation(
            widget.translationKey ?? "",
            languageId,
            "",
            widget.projectId,
          );
          translationContentMap[languageId] = editTranslation;
        }
      }
    }

    for (Language language in widget.languageList) {
      if (language.languageName == defaultFrom) {
        defaultTranslateSrc = widget.languageIdToTranslationMap?[language.languageId]?.translationContent;
        break;
      }
    }

    translationKeyChange = widget.translationKey ?? "";
    _translationKeyController = TextEditingController(text: widget.translationKey ?? "");
  }

  @override
  Widget build(BuildContext context) {
    // print("_EditTranslationDetailPage build:");
    List<Widget> widgetList = [];

    Widget titleRow = Container(
      padding: EdgeInsets.only(right: 20),
      width: 500,
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            "编辑翻译",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Spacer(),
          GestureDetector(
            child: Text("复制"),
            onTap: () {
              setState(() {
                translationKeyChange = "${translationKeyChange}_copy";
                _translationKeyController.text = translationKeyChange;
                for (var translation in translationContentMap.values) {
                  translation.translationId = null;
                  print("复制翻译：${translation.toJson()}");
                }
              });
            },
          ),
        ],
      ),
    );
    widgetList.add(titleRow);
    Widget keyText;
    keyText = TextFormField(
      controller: _translationKeyController,
      autofocus: true,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)), // 圆角半径
            borderSide: BorderSide(color: Colors.blue, width: 3.0), // 边框颜色和粗细
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: Colors.green, width: 3.0), // 聚焦时边框颜色
          ),
          filled: false,
          hintText: "请输入Key",
          labelStyle: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 24),
          labelText: "LanguageKey"),
      onChanged: (value) {
        // _translationKeyController.text = value;
        translationKeyChange = value;
        // for (Translation translation in translationContentMap.values) {
        //   translation.translationKey = value;
        //   translation.forceAdd = true;
        // }
        print("onChange:translationKeyChange:$value");
      },
    );

    Widget keyItem = Container(
      width: 500,
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: keyText,
          ),
          buildTranslationAllBtn("google"),
          buildTranslationAllBtn("baidu"),
        ],
      ),
    );
    widgetList.add(keyItem);

    for (int i = 0; i < widget.languageList.length; i++) {
      Language language = widget.languageList[i];
      var translation = translationContentMap[language.languageId];

      Widget googleBtn = buildTranslateBtn(language, "google", () {
        translateByGoogle(language, () {
          setState(() {
            loadingLanguageName = "";
          });
        });
      });
      Widget baiduBtn = buildTranslateBtn(language, "baidu", () {
        translateByBaidu(language, () {
          setState(() {
            loadingLanguageName = "";
          });
        });
      });
      Widget translationItem = SizedBox(
        width: 500,
        height: 80,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                key: Key(translation?.translationContent ?? ""),
                autofocus: true,
                maxLines: null,
                initialValue: translation?.translationContent ?? " ",
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      borderSide: BorderSide(color: Colors.green, width: 1.0), // 聚焦时边框颜色
                    ),
                    filled: false,
                    hintText: "请输入内容",
                    labelText: "${language.languageName}(${language.languageDes})"),
                onChanged: (value) {
                  if (null != translation) {
                    translation.oldTranslationContent = translation.translationContent;
                    translation.translationContent = value;
                  }

                  // translation?.forceAdd = true;
                  if (language.languageName == defaultFrom) {
                    defaultTranslateSrc = value;
                  }
                },
              ),
            ),
            googleBtn,
            baiduBtn
          ],
        ),
      );
      widgetList.add(translationItem);
    }
    Widget actions = SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text(
                "取消",
                style: TextStyle(color: Colors.grey),
              )),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop({translationKeyChange: translationContentMap});
              },
              child: const Text("确定 "))
        ],
      ),
    );
    widgetList.add(actions);
    return ListView(
      shrinkWrap: true,
      children: widgetList,
    );
  }

  Widget buildTranslateBtn(Language language, String translatePlatform, Function onTap) {
    String imageRes;
    if (translatePlatform == "google") {
      imageRes = 'images/google.png';
    } else {
      imageRes = 'images/baidu.png';
    }
    Widget translateBtn;
    print("正在加载:$loadingLanguageName");
    if (loadingLanguageName == language.languageName) {
      translateBtn = RotationTransition(
        turns: _animation,
        child: Image.asset(
          imageRes,
          width: 50,
          height: 50,
        ),
      );
    } else {
      translateBtn = GestureDetector(
        child: Image.asset(
          imageRes,
          width: 50,
          height: 50,
        ),
        onTap: () {
          onTap();
        },
      );
    }
    return translateBtn;
  }

  @override
  void dispose() {
    _repeatController.dispose();
    super.dispose();
  }

  void translateByGoogle(Language to, Function callback) {
    String? src = defaultTranslateSrc;
    if (null != src) {
      setState(() {
        loadingLanguageName = to.languageName;
      });
      WJHttp().translateByGoogleV2(src, defaultFrom, to.languageName).then((value) {
        if (value.code == 200) {
          String? translationResult = value.data?.transResult;
          if (translationResult != null) {
            translationContentMap[to.languageId ?? 0]?.translationContent = translationResult;
          }
        }
        callback();
      });
    }
  }

  void translateByBaidu(Language to, Function callback) {
    String? src = defaultTranslateSrc;
    if (null != src) {
      setState(() {
        loadingLanguageName = to.languageName;
      });
      WJHttp().translateByBaiduV2(src, defaultFrom, to.languageName).then((value) {
        if (value.code == 200) {
          String? translationResult = value.data?.transResult;
          if (translationResult != null) {
            translationContentMap[to.languageId ?? 0]?.translationContent = translationResult;
          }
        }
        callback();
      });
    }
  }

  Widget buildTranslationAllBtn(String translatePlatform) {
    List<Language> languageToTranslate = [];
    String imageRes;
    if (translatePlatform == "google") {
      imageRes = 'images/google_color.png';
    } else {
      imageRes = 'images/baidu_color.png';
    }
    return GestureDetector(
      child: Image.asset(
        imageRes,
        width: 50,
        height: 50,
      ),
      onTap: () {
        for (Language language in widget.languageList) {
          if (language.languageName != defaultFrom) {
            languageToTranslate.add(language);
          }
        }
        translationAll(widget.languageList, 0, translatePlatform);
      },
    );
  }

  void translationAll(List<Language> languageToTranslate, int currentPos, String translatePlatform) {
    print("translationAll:currentPos:$currentPos");
    if (currentPos >= languageToTranslate.length) {
      loadingLanguageName = "";
      setState(() {});
      showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return const AlertDialog(content: Text("已加载完毕"));
          });
      return;
    }
    Language to = languageToTranslate[currentPos];
    if (translatePlatform == "baidu") {
      translateByBaidu(to, () {
        Future.delayed(const Duration(milliseconds: 1000), () {
          currentPos++;
          translationAll(languageToTranslate, currentPos, translatePlatform);
        });
      });
    } else {
      translateByGoogle(to, () {
        Future.delayed(const Duration(milliseconds: 100), () {
          currentPos++;
          translationAll(languageToTranslate, currentPos, translatePlatform);
        });
      });
    }
  }
}
