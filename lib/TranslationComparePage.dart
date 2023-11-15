import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'package:hwj_translation_flutter/net.dart';
import 'dart:collection';
import 'dart:convert';

class TranslationComparePage extends StatefulWidget {
  TranslationComparePage(this.translationList);

  List<Translation> translationList;

  @override
  State<StatefulWidget> createState() => _TranslationComparePage(translationList);
}

class _TranslationComparePage extends State<TranslationComparePage> {
  _TranslationComparePage(this.translationList);

  List<Translation> translationList;

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
        ),
        body: buildBody());
  }

  Widget buildBody() {
    return Container(
      margin: EdgeInsets.all(10),
      width: double.infinity,
      child: Center(
        child: Column(
          children: [
            Row(
              children: [
                buildTranslationText("Key", 300, FontWeight.bold),
                buildTranslationText("原翻译", null, FontWeight.bold),
                buildTranslationText("新翻译", null, FontWeight.bold),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  Translation translation = translationList[index];
                  return buildTranslationListItem(translation);
                },
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
        buildTranslationText(translation.translationKey, 300, FontWeight.bold),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [buildTranslationText(translation.oldTranslationContent ?? "", null, null), buildTranslationText(translation.translationContent, null, null)],
          ),
        )
      ],
    );
  }

  Widget buildTranslationText(String text, double? width, FontWeight? fontWeight) {
    // print("buildTranslationText $text");
    Container textItem = Container(
        color: Colors.white70,
        width: width,
        margin: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
        height: 40,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: fontWeight),
        ));
    return textItem;
  }
}
