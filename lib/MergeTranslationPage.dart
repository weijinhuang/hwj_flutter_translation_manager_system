import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/net.dart';

class MergeTranslationPage extends StatefulWidget {
  Map<String, Map<int, Translation>> translationKeyLanguageContentMap;

  List<Language> languageList;

  MergeTranslationPage(this.translationKeyLanguageContentMap, this.languageList);

  @override
  State<StatefulWidget> createState() {
    return _MergeTranslationPage();
  }
}

class _MergeTranslationPage extends State<MergeTranslationPage> {
  String selectedTranslationKey = "";

  @override
  Widget build(BuildContext context) {
    List<Widget> translationItems = [];
    for (var key in widget.translationKeyLanguageContentMap.keys) {
      var translationKeyLanguageContentMap = widget.translationKeyLanguageContentMap[key];
      if (null != translationKeyLanguageContentMap) {
        translationItems.add(buildTranslationListItem(translationKeyLanguageContentMap, selectedTranslationKey == key));
      }
    }
    translationItems.add(SizedBox(
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
                Navigator.of(context).pop(selectedTranslationKey);
              },
              child: const Text("确定 "))
        ],
      ),
    ));
    return Column(children: translationItems);
  }

  Widget buildTranslationListItem(Map<int, Translation> languageTranslationMap, bool selected) {
    List<Widget> widgetList = [];
    if (languageTranslationMap.isNotEmpty) {
      //Key
      String translationKey = languageTranslationMap.values.first.translationKey;
      Widget keyItem = buildTranslationText(translationKey, FontWeight.bold, selected);
      widgetList.add(keyItem);

      //翻译列表
      for (Language language in widget.languageList) {
        Translation? translation = languageTranslationMap[language.languageId];
        if (null != translation) {
          String translationContent = translation.translationContent ?? "";
          Widget contentItem = buildTranslationText(translationContent, null, selected);
          widgetList.add(GestureDetector(
            child: contentItem,
            onTap: () {
              selectedTranslationKey = translation.translationKey;
              setState(() {});
            },
          ));
        }
      }
    }
    return Flex(
      direction: Axis.horizontal,
      children: widgetList,
    );
  }

  Widget buildTranslationText(String text, FontWeight? fontWeight, bool selected) {
    // print("buildTranslationText $text");
    Color background = Colors.white;
    Color textColor = Colors.black;
    if (selected) {
      background = Colors.green;
      textColor = Colors.white;
    }
    Container textItem = Container(
        color: background,
        width: 200,
        margin: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
        height: 40,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: fontWeight, color: textColor),
        ));
    return textItem;
  }
}
