import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/net.dart';

class TranslationItemWidget extends StatefulWidget {

  Translation translation;
  Color selectedColor = Colors.green;


  TranslationItemWidget(this.translation, this.selectedColor);

  @override
  State createState() {
    return _TranslationItemWidget();
  }


}

class _TranslationItemWidget extends State<TranslationItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.translation.translationContent);
  }
}
