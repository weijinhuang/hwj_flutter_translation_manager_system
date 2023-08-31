import 'dart:collection';
// import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'package:hwj_translation_flutter/net.dart';

import 'bean.dart';


const LANGUAGE_KEY = "Key";
class DataTableDemoPage2 extends StatefulWidget {
  DataTableDemoPage2(this.project);

  final Project project;


  @override
  State<StatefulWidget> createState() => _DataTableDemoState2(project);
}

class _DataTableDemoState2 extends State<DataTableDemoPage2> {
  _DataTableDemoState2(this.project);

  List<Translation> translationList = List.empty();
  Map<String, Map<String, String>> translationMap = HashMap();
  Project project;
  List<String> languageIdList = [];

  String _newLanguageId = "";
  String _newLanguageName = "";

  @override
  void initState() {
    super.initState();

    fetchTranslation();
  }


  void fetchTranslation() {
    WJHttp http = WJHttp();
    http.fetchLanguageList(project.projectId).then((languageListWrapper) => {
      http
          .fetchTranslation(project.projectId)
          .then((translationListWrapper) => {
        setState(() {
          languageIdList.clear();
          languageIdList.add(LANGUAGE_KEY);
          for (var element in languageListWrapper.data) {
            languageIdList.add(element.languageId);
          }
          translationList = translationListWrapper.data;
          for (var element in translationList) {
            Map<String, String>? translationDetail =
            translationMap[element.translationKey];
            if (translationDetail == null) {
              translationDetail = HashMap();
              translationMap[element.translationKey] =
                  translationDetail;
            }
            translationDetail[element.languageId] =
                element.translationContent;
          }
        })
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('DataTable'),
        backgroundColor: Colors.red[400]!,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            horizontalMargin: 10.0,
            showBottomBorder: true,

            showCheckboxColumn: true,
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            columns: buildTableTitles(),
            rows: buildTranslationRows(),
          ),
        ),
      ),
    );
  }
  List<DataColumn> buildTableTitles() {
    List<DataColumn> titles = [];
    for (var element in languageIdList) {
      titles.add(DataColumn(
          label: GestureDetector(
            onLongPress: () {
              if (element == LANGUAGE_KEY) {
                return;
              }
              showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return showDeleteLanguageDialog(element);
                  });
            },
            child: SizedBox(
              width: 300,
              child: Text(
                element,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )));
    }
    return titles;
  }

  List<DataRow> buildTranslationRows() {
    List<DataRow> rows = [];
    for (var translationKey in translationMap.keys) {
      rows.add(DataRow(cells: buildCells(translationKey)));
    }
    return rows;
  }

  List<DataCell> buildCells(String translationKey) {
    var translations = translationMap[translationKey];
    List<DataCell> cells = [];
    cells.add(DataCell(Text(translationKey), onDoubleTap: () {
      showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return showDeleteTranslationDialog(translations, translationKey);
          });
    }));
    if (null != translations) {
      for (var i = 1; i < languageIdList.length; i++) {
        var languageId = languageIdList[i];
        var translation = translations[languageId];
        cells.add(DataCell(Text(translation ?? ""), onTap: () async {
          var result = await showDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return buildTranslationEditDialog(
                    translationKey, context, translations);
              });
          addTranslation(result);
        }));
      }
    }
    return cells;
  }

  void addTranslation(Map<String, String> result) {
    if (result.isNotEmpty) {
      print("result.isNotEmpty");
      var languageIdList = result.keys.toList(growable: false);
      String key = result[languageIdList[0]] ?? "";
      if (key.isEmpty) {
        print("key.isEmpty");
        return;
      }
      print("key:$key");
      List<Translation> translationList = [];
      for (int i = 1; i < languageIdList.length; i++) {
        String languageId = languageIdList[i];
        Translation translation = Translation(
            key, languageId, result[languageId] ?? "", project.projectId);
        translationList.add(translation);
      }
      addTranslationRemote(translationList);
    } else {
      print("result.isEmpty");
    }
  }
  void addTranslationRemote(List<Translation> translationList) {
    if (translationList.isEmpty) {
      fetchTranslation();
      return;
    }
    var first = translationList.last;
    WJHttp wjHttp = WJHttp();
    wjHttp.addTranslation(first).then((value) {
      translationList.removeLast();
      addTranslationRemote(translationList);
    });
  }

  showDeleteLanguageDialog(String languageId) {
    return AlertDialog(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("删除语言$languageId？"),
      actions: [
        SizedBox(
            width: 200,
            height: 30,
            child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("取消"))),
        SizedBox(
            width: 200,
            height: 30,
            child: TextButton(
              onPressed: () {
                print("onPressed:deleteLanguageRemote(languageId)");
                deleteLanguageRemote(languageId);
                Navigator.pop(context);
              },
              child: const Text(
                "确定",
                style: TextStyle(color: Colors.blueAccent),
              ),
            )),
      ],
    );
  }
  void deleteLanguageRemote(String languageId) {
    print("deleteLanguageRemote");
    Language language = Language(languageId, "languageName", project.projectId);
    WJHttp().deleteLanguage(language).then((value) {
      if (value.code == 200) {
        languageIdList.remove(languageId);
      }
      setState(() {});
    });
  }

  AlertDialog buildTranslationEditDialog(String? translationKey,
      BuildContext context, Map<String, String>? translationIdContentMap) {
    Map<String, String> translationIdContentMapChanged =
    HashMap<String, String>();
    translationIdContentMapChanged[LANGUAGE_KEY] = translationKey ?? "";
    String? titleText = translationKey;
    if (titleText == null) {
      titleText = "添加语言";
    } else {
      titleText = "编辑语言";
    }
    // var keys = translationIdContentMap.keys.toList();
    return AlertDialog(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(titleText),
      content: SizedBox(
        height: 500,
        width: 500,
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            String languageId = languageIdList[index];
            return buildTranslationEditText(
                translationKey,
                translationIdContentMap,
                translationIdContentMapChanged,
                languageId);
          },
          itemCount: languageIdList.length,
        ),
      ),
      actions: [
        SizedBox(
            width: 200,
            height: 30,
            child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("取消"))),
        SizedBox(
            width: 200,
            height: 30,
            child: TextButton(
              onPressed: () {
                // translationIdContentMap[languageId] = translationTemp ?? "";
                String? key =
                    translationIdContentMapChanged[LANGUAGE_KEY] ?? "";
                if (key.isNotEmpty) {
                  print("key:$key");
                  setState(() {});
                  Navigator.of(context).pop(translationIdContentMapChanged);
                } else {
                  print("key为空");
                  Navigator.of(context).pop(null);
                }
              },
              child: const Text(
                "确定",
                style: TextStyle(color: Colors.blueAccent),
              ),
            )),
      ],
    );
  }

  Widget buildTranslationEditText(
      String? translationKey,
      Map<String, String>? translations,
      Map<String, String> translationChanged,
      String languageId) {
    String? initialValue;
    if (languageId == LANGUAGE_KEY) {
      initialValue = translationKey;
    } else {
      initialValue = translations?[languageId] ?? " ";
    }
    initialValue ??= " ";
    return SizedBox(
      width: 500,
      height: 80,
      child: TextFormField(
        autofocus: true,
        initialValue: initialValue,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            filled: false,
            hintText: "请输入翻译内容",
            labelText: languageId),
        onChanged: (value) {
          translations?[languageId] = value;
          translationChanged[languageId] = value;
        },
      ),
    );
  }
  showDeleteTranslationDialog(
      Map<String, String>? translationMap, String translationKey) {
    return AlertDialog(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("是否删除翻译$translationKey？"),
      actions: [
        SizedBox(
            width: 200,
            height: 30,
            child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("取消"))),
        SizedBox(
            width: 200,
            height: 30,
            child: TextButton(
              onPressed: () {
                deleteTranslationRemote(translationKey);
                Navigator.pop(context);
              },
              child: const Text(
                "确定",
                style: TextStyle(color: Colors.blueAccent),
              ),
            )),
      ],
    );
  }

  void deleteTranslationRemote(String translationKey) {
    WJHttp()
        .deleteTranslationByKey(translationKey, project.projectId)
        .then((value) {
      if (value.code == 200) {
        translationMap.remove(translationKey);
      }
      setState(() {});
    });
  }

  void updateTranslation(Map<String, String> translationMap) {}
}