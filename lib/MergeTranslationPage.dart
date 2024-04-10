import 'dart:collection';
import 'package:hwj_translation_flutter/WJHttp.dart';

import 'MergeTranslationDialogPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/net.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

class MergeTranslationPage extends StatefulWidget {
  Map<String, Map<int, Translation>> translationKeyLanguageContentMap;

  List<Language> languageList;

  MergeTranslationPage(this.translationKeyLanguageContentMap, this.languageList, {super.key});

  @override
  State<StatefulWidget> createState() => _MergeProjectSelectProjectPage();
}

class _MergeProjectSelectProjectPage extends State<MergeTranslationPage> {
  bool hasDeleteTranslation = false;

  List<String> selectedTranslationKey = [];
  Map<String, Map<int, Translation>> similarTranslationList = HashMap();
  Map<String, Map<int, Translation>> currentSourceTranslation = HashMap();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        // canPop = true;
        Navigator.of(context).pop(hasDeleteTranslation);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "合并翻译",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                var result = await showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      return buildMergeTranslationDialog();
                    });
                if (result != null) {
                  mergeRemote(result);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(left: 10, right: 20),
                child: const Icon(Icons.call_merge),
              ),
            )
          ],
        ),
        body: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildLeftTranslationList(),
              buildRightTranslationList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMergeTranslationDialog() {
    Map<String, Map<int, Translation>> map = HashMap();
    map.addAll(currentSourceTranslation);
    for (var key in similarTranslationList.keys) {
      if (selectedTranslationKey.contains(key)) {
        var similarTranslation = similarTranslationList[key];
        if (similarTranslation != null) {
          map[key] = similarTranslation;
        }
      }
    }
    return AlertDialog(
      elevation: 10,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("选择主翻译,其他翻译将会被删除"),
      content: SizedBox(
        width: 1000,
        child: MergeTranslationDialogPage(map, widget.languageList),
      ),
    );
  }

  Widget buildRightTranslationList() {
    List<Map<int, Translation>> translationList = similarTranslationList.values.toList();
    return Expanded(
        child: ListView.builder(
      itemBuilder: (context, index) {
        return buildTranslationListItem(translationList[index], false);
      },
      // itemExtent: 100,
      itemCount: translationList.length,
    ));
  }

  Widget buildLeftTranslationList() {
    List<Map<int, Translation>> translationList = widget.translationKeyLanguageContentMap.values.toList();
    return Expanded(
        child: ListView.builder(
      itemBuilder: (context, index) {
        return buildTranslationListItem(translationList[index], true);
      },
      // itemExtent: 100,
      itemCount: translationList.length,
    ));
  }

  Widget buildTranslationListItem(Map<int, Translation> languageTranslationMap, bool left) {
    List<Widget> widgetList = [];
    if (languageTranslationMap.isNotEmpty) {
      //Key
      String translationKey = languageTranslationMap.values.first.translationKey;
      bool selected = selectedTranslationKey.contains(translationKey);
      Widget keyItem = buildTranslationText(translationKey, FontWeight.bold, false, 200,1);
      widgetList.add(keyItem);

      //翻译列表
      for (Language language in widget.languageList) {
        Translation? translation = languageTranslationMap[language.languageId];
        if (null != translation) {
          String translationContent = translation.translationContent ?? "";
          Widget contentItem = buildTranslationText(translationContent, null, selected, null,5);
          widgetList.add(Expanded(
            child: GestureDetector(
              child: contentItem,
              onTap: () {
                // buildTranslationEditDialog(translationKey, context, languageTranslationMap);

                if (left) {
                  selectedTranslationKey.clear();
                  selectedTranslationKey.add(translationKey);
                  currentSourceTranslation = {translationKey: languageTranslationMap};
                  setState(() {
                    searchSimilarTranslation(language, translationKey, translationContent);
                  });
                } else {
                  setState(() {
                    if (selected) {
                      selectedTranslationKey.remove(translationKey);
                    } else {
                      selectedTranslationKey.add(translationKey);
                    }
                  });
                }
              },
            ),
          ));
        }
      }
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widgetList,
      ),
    );
  }

  Widget buildTranslationText(String text, FontWeight? fontWeight, bool selected, double? width,int? lines) {
    // print("buildTranslationText $text");
    Color background = Colors.white70;
    Color textColor = Colors.black;
    if (selected) {
      background = Colors.green;
      textColor = Colors.white;
    }

    Container textItem = Container(
        color: background,
        width: width,
        margin: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          softWrap: true,
          maxLines: lines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: fontWeight, color: textColor),
        ));
    return textItem;
  }

  void searchSimilarTranslation(Language language, String sourceTranslationKey, String sourceTranslationContent) {
    similarTranslationList.clear();
    Iterable<Map<int, Translation>> translationLanguageMap = widget.translationKeyLanguageContentMap.values;
    translationLanguageMap.forEach((element) {
      Translation? translation = element[language.languageId];
      if (null != translation) {
        var ratioValue = ratio(sourceTranslationContent, translation.translationContent);
        if (ratioValue > 80) {
          if (sourceTranslationKey != translation.translationKey) {
            var languageTranslationMap = widget.translationKeyLanguageContentMap[translation.translationKey];
            if (null != languageTranslationMap) {
              similarTranslationList[translation.translationKey] = languageTranslationMap;
            }
          }
        }
      }
    });
  }

  void mergeRemote(resultKey) {
    List<String> deleteTranslationKeyList = [];
    for (var element in currentSourceTranslation.keys) {
      if (element != resultKey) {
        deleteTranslationKeyList.add(element);
      }
    }
    for (var element in similarTranslationList.keys) {
      if (element != resultKey) {
        deleteTranslationKeyList.add(element);
      }
    }
    WJHttp().mergeTranslation(resultKey, deleteTranslationKeyList, widget.languageList.first.projectId).then((value) {
      setState(() {
        similarTranslationList.clear();
        hasDeleteTranslation = true;
        for (var key in deleteTranslationKeyList) {
          widget.translationKeyLanguageContentMap.remove(key);
        }
      });
    });
  }
}
