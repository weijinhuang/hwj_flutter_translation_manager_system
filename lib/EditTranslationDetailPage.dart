import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'package:hwj_translation_flutter/net.dart';
import 'dart:collection';
import 'dart:convert';

class EditTranslationDetailPage extends StatefulWidget {
  EditTranslationDetailPage(this.projectId, this.moduleId, this.translationKey, this.languageIdContentMapParam, this.languageList);

  String projectId;
  int moduleId;
  String? translationKey;
  Map<int, Translation>? languageIdContentMapParam;
  List<Language> languageList;

  @override
  State<StatefulWidget> createState() => _EditTranslationDetailPage();
}

class _EditTranslationDetailPage extends State<EditTranslationDetailPage> with SingleTickerProviderStateMixin {
  _EditTranslationDetailPage();

  String defaultFrom = "en";
  Set<Translation> translationChangedList = {};
  String translationKeyChange = "";
  String? defaultTranslateSrc;
  Map<int, String?> translationContentMap = HashMap();

  String loadingLanguageName = "";

  late final Animation<double> _animation;
  late final AnimationController _repeatController;

  @override
  void initState() {
    super.initState();
    _repeatController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_repeatController);

    if (null != widget.languageIdContentMapParam) {
      for (var language in widget.languageList) {
        int languageId = language.languageId!;
        translationContentMap[languageId] = widget.languageIdContentMapParam?[languageId]?.translationContent;
      }
    }
    for (Language language in widget.languageList) {
      if (language.languageName == defaultFrom) {
        defaultTranslateSrc = widget.languageIdContentMapParam?[language.languageId]?.translationContent;
        break;
      }
    }

    translationKeyChange = widget.translationKey ?? "";
  }

  @override
  Widget build(BuildContext context) {
    // print("_EditTranslationDetailPage build:");
    List<Widget> widgetList = [];
    Widget keyText;
    if (translationKeyChange == "") {
      keyText = TextFormField(
        autofocus: true,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))), filled: false, hintText: "请输入Key", labelText: "LanguageKey"),
        onChanged: (value) {
          translationKeyChange = value;
          print("onChange:translationKeyChange:$value");
        },
      );
    } else {
      keyText = Text(translationKeyChange);
    }

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
      var translationContent = translationContentMap[language.languageId];

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
                key: Key(translationContent ?? ""),
                autofocus: true,
                maxLines: null,
                initialValue: translationContent ?? " ",
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    filled: false,
                    hintText: "请输入内容",
                    labelText: "${language.languageName}(${language.languageDes})"),
                onChanged: (value) {
                  translationContentMap[language.languageId ?? 0] = value;
                  if (language.languageName == "en") {
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
      WJHttp().translateByGoogle(src, defaultFrom, to.languageName).then((value) {
        if (value.code == 200) {
          String? translationResult = value.data?.transResult;
          if (translationResult != null) {
            translationContentMap[to.languageId ?? 0] = translationResult;
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
      WJHttp().translateByBaidu(src, defaultFrom, to.languageName).then((value) {
        if (value.code == 200) {
          String? translationResult = value.data?.transResult;
          if (translationResult != null) {
            translationContentMap[to.languageId ?? 0] = translationResult;
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
