import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'package:hwj_translation_flutter/net.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'common/theme.dart';

class ReorderLanguageListPage extends StatefulWidget {

  Project project;
  List<Language> localLanguageList = [];

  ReorderLanguageListPage(this.project, this.localLanguageList);

  @override
  _ReorderLanguageListPageState createState() => _ReorderLanguageListPageState();
}

class _ReorderLanguageListPageState extends State<ReorderLanguageListPage> {

  @override
  Widget build(BuildContext context) {
    List<Language> localLanguageList = widget.localLanguageList;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {
              saveOrder();
            },
            icon: const Icon(Icons.save),
            tooltip: "保存",
          ),
          const Text("        ")
        ],
      ),
      body: ReorderableListView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        children: <Widget>[
          for (final Language item in localLanguageList)
            ListTile(
              key: ValueKey(item),
              title: Text("${item.languageName}(${item.languageDes})"),
              trailing: Icon(Icons.drag_handle), // 显示拖动手柄图标
            ),
        ],
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final Language item = localLanguageList.removeAt(oldIndex);
            localLanguageList.insert(newIndex, item);
          });
        },
      ),
    );
  }

  void saveOrder() {
    for (int i = 0; i < widget.localLanguageList.length; i++) {
      Language language = widget.localLanguageList[i];
      language.languageOrder = i;
    }
    WJHttp().updateLanguagesV2(widget.localLanguageList).then((value){
        Navigator.of(context).pop(widget.localLanguageList);
    });

  }
}
