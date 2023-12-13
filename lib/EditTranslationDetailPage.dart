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
  }

  @override
  Widget build(BuildContext context) {
    // print("_EditTranslationDetailPage build:");
    List<Widget> widgetList = [];
    translationKeyChange = widget.translationKey ?? "";
    Widget keyItem = Container(
      width: 500,
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              autofocus: true,
              initialValue: widget.translationKey,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))), filled: false, hintText: "请输入Key", labelText: "LanguageKey"),
              onChanged: (value) {
                print("onChange:translationKeyChange:$value");
              },
            ),
          ),
          IconButton(
              onPressed: () {
                List<Language> languageToTranslate = [];
                for (Language language in widget.languageList) {
                  if (language.languageName != defaultFrom) {
                    languageToTranslate.add(language);
                  }
                }
                translationAll(widget.languageList, 0);
              },
              icon: const Icon(Icons.adb))
        ],
      ),
    );
    widgetList.add(keyItem);
    for (int i = 0; i < widget.languageList.length; i++) {
      Language language = widget.languageList[i];
      var translationContent = translationContentMap[language.languageId];

      Widget button;
      print("正在加载:$loadingLanguageName");
      if (loadingLanguageName == language.languageName) {
        button = RotationTransition(
          turns: _animation,
          child: IconButton(
              onPressed: () {
                translateByBaidu(language, () {
                  loadingLanguageName = "";
                });
              },
              icon: const Icon(Icons.translate)),
        );
      } else {
        button = IconButton(
            onPressed: () {
              translateByBaidu(language, () {
                loadingLanguageName = "";
              });
            },
            icon: const Icon(Icons.translate));
      }
      // print("for:$translationContent");
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
            button
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

  @override
  void dispose() {
    _repeatController.dispose();
    super.dispose();
  }

  void translateByBaidu(Language to, Function callback) {
    String? src = defaultTranslateSrc;
    if (null != src) {
      loadingLanguageName = to.languageName;
      WJHttp().translateByBaidu(src, defaultFrom, to.languageName).then((value) {
        if (value.code == 200) {
          List<BaiduTranslation?>? translationResult = value.data?.trans_result;
          if (translationResult != null && translationResult.isNotEmpty) {
            var translationDetail = translationResult[0];
            if (null != translationDetail) {
              String? dst = translationDetail.dst;
              if (dst != null) {
                setState(() {
                  translationContentMap[to.languageId ?? 0] = dst;
                });
              }
            }
          }
        }
        callback();
      });
    }
  }

  void translationAll(List<Language> languageToTranslate, int currentPos) {
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
    translateByBaidu(to, () {
      Future.delayed(const Duration(seconds: 1), () {
        currentPos++;
        translationAll(languageToTranslate, currentPos);
      });
    });
  }
}
