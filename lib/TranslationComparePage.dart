import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'package:hwj_translation_flutter/net.dart';
import 'dart:collection';
import 'dart:convert';

class TranslationComparePage extends StatefulWidget {
  TranslationComparePage(this.translationList);

  List<Translation> translationList;

  @override
  State<StatefulWidget> createState() =>
      _TranslationComparePage(translationList);
}

class _TranslationComparePage extends State<TranslationComparePage> {
  _TranslationComparePage(this.translationList);

  List<Translation> translationList;

  Map<String, String> selectedTranslationContent = HashMap();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            "翻译校对",
            style: TextStyle(color: Colors.black),
          ),
          actions: buildActions(),
        ),
        body: buildBody());
  }

  List<Widget> buildActions() {
    List<Widget> actions = [];
    actions.add(GestureDetector(
      onTap: () {
        saveTranslation();
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 20),
        child: const Icon(Icons.save_rounded),
      ),
    ));
    return actions;
  }

  Widget buildBody() {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.all(10),
      width: double.infinity,
      child: Center(
        child: Column(
          children: [
            Container(
              child: Row(
                children: [
                  buildTranslationText("Key", "", 300, FontWeight.bold),
                  Expanded(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          buildTranslationText(
                              "原翻译", "", null, FontWeight.bold),
                          buildTranslationText(
                              "新翻译", "", null, FontWeight.bold),
                        ]),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  Translation translation = translationList[index];
                  return buildTranslationListItem(translation);
                },
                itemCount: translationList.length,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTranslationListItem(Translation translation) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildTranslationText(
            translation.translationKey, "", 300, FontWeight.bold),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: buildTranslationText(
                      translation.oldTranslationContent ?? "",
                      translation.selectedTranslationContent ?? "",
                      null,
                      null),
                  onTap: () {
                    translation.selectedTranslationContent =
                        translation.oldTranslationContent;
                    setState(() {});
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  child: buildTranslationText(translation.translationContent,
                      translation.selectedTranslationContent ?? "", null, null),
                  onTap: () {
                    translation.selectedTranslationContent =
                        translation.translationContent;
                    setState(() {});
                  },
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget buildTranslationText(
      String text, String selectedText, double? width, FontWeight? fontWeight) {
    // print("buildTranslationText $text");
    Color textBackColor;
    Color textColor;
    if (selectedText == text) {
      textBackColor = Colors.lightGreen;
      textColor = Colors.white;
    } else {
      textBackColor = Colors.white;
      textColor = Colors.black;
    }
    return Container(
        color: textBackColor,
        width: width,
        padding: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
        child: Text(
          text,
          style: TextStyle(fontWeight: fontWeight, color: textColor),
        ));
  }

  void saveTranslation() {
    for (var element in translationList) {

      String? selectedTranslationContent = element.selectedTranslationContent;
      if (null != selectedTranslationContent) {
        element.translationContent = selectedTranslationContent;
        element.forceAdd = true;
      } else {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return AlertDialog(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text("${element.translationKey}未选择翻译"));
            });
        return;
      }
    }
    WJHttp().addTranslationsV2(translationList).then((value) {
      if (value.code == 200) {
        print("添加翻译成功");
        print("Navigator.of(context).pop();");
        Navigator.of(context).pop(true);
      } else {
        print("添加翻译失败，失败列表:${value.data.length}");
      }
      // fetchTranslation();
    });
  }
}
