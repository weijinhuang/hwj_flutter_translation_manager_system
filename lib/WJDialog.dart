
import 'package:flutter/material.dart';

class WJDialog{

  Widget showAddLanguageDialog() {
    return AlertDialog(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("添加新语言"),
      content: SizedBox(
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 500,
              height: 100,
              child: TextFormField(
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))), filled: false, hintText: "请输入语言id（如cn）", labelText: "语言id"),
                onChanged: (value) {
                  // _newlanguageName = value;
                },
              ),
            ),
            SizedBox(
              width: 500,
              height: 200,
              child: TextFormField(
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))), filled: false, hintText: "请输入语言名字（如中文）", labelText: "语言名字"),
                onChanged: (value) {
                  // _newLanguageName = value;
                },
              ),
            )
          ],
        ),
      ),
      actions: [
        SizedBox(
            width: 200,
            height: 30,
            child: TextButton(
                onPressed: () {
                  // Navigator.pop(context);
                },
                child: const Text("取消"))),
        SizedBox(
            width: 200,
            height: 30,
            child: TextButton(
              onPressed: () {
                // addLanguageRemote();
                // Navigator.pop(context);
              },
              child: const Text(
                "确定",
                style: TextStyle(color: Colors.blueAccent),
              ),
            )),
      ],
    );
  }
}