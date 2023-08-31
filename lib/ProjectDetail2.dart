// import 'dart:collection';
// import 'dart:convert';
//
// // import 'dart:html';
// // import 'dart:js_interop';
//
// import 'package:flutter/material.dart';
// import 'package:hwj_translation_flutter/WJHttp.dart';
// import 'package:hwj_translation_flutter/net.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:xml/xml.dart';
//
// const LANGUAGE_KEY = "Key";
//
// class ProjectDetail extends StatefulWidget {
//   ProjectDetail(this.project);
//
//   final Project project;
//
//   @override
//   State<StatefulWidget> createState() => _ProjectDetail(project);
// }
//
// class _ProjectDetail extends State<ProjectDetail> {
//   _ProjectDetail(this.project);
//
//   List<Translation> translationList = List.empty();
//   Map<String, Map<String, String>> translationMap = HashMap();
//   Project project;
//   List<String> languageIdList = [""];
//
//   String _newLanguageId = "";
//   String _newLanguageName = "";
//
//   @override
//   void initState() {
//     super.initState();
//     fetchTranslation();
//   }
//
//   void fetchTranslation() {
//     WJHttp http = WJHttp();
//     http.fetchLanguageList(project.projectId).then((languageListWrapper) => {
//           http
//               .fetchTranslation(project.projectId)
//               .then((translationListWrapper) => {
//                     setState(() {
//                       languageIdList.clear();
//                       languageIdList.add(LANGUAGE_KEY);
//                       for (var element in languageListWrapper.data) {
//                         languageIdList.add(element.languageId);
//                       }
//                       translationList = translationListWrapper.data;
//                       for (var element in translationList) {
//                         Map<String, String>? translationDetail =
//                             translationMap[element.translationKey];
//                         if (translationDetail == null) {
//                           translationDetail = HashMap();
//                           translationMap[element.translationKey] =
//                               translationDetail;
//                         }
//                         translationDetail[element.languageId] =
//                             element.translationContent;
//                       }
//                     })
//                   })
//         });
//   }
//
//   void addTranslationRemote(List<Translation> translationList) {
//     WJHttp().addTranslations(translationList).then((value) {
//       print("addTranslations result: ${value.msg}");
//     });
//     // if (translationList.isEmpty) {
//     //   fetchTranslation();
//     //   return;
//     // }
//     // var first = translationList.last;
//     // WJHttp wjHttp = WJHttp();
//     // wjHttp.addTranslation(first).then((value) {
//     //   translationList.removeLast();
//     //   addTranslationRemote(translationList);
//     // });
//   }
//
//   void addTranslation(Map<String, String> result) {
//     if (result.isNotEmpty) {
//       print("result.isNotEmpty");
//       var languageIdList = result.keys.toList(growable: false);
//       String key = result[languageIdList[0]] ?? "";
//       if (key.isEmpty) {
//         print("key.isEmpty");
//         return;
//       }
//       print("key:$key");
//       List<Translation> translationList = [];
//       for (int i = 1; i < languageIdList.length; i++) {
//         String languageId = languageIdList[i];
//         Translation translation = Translation(
//             key, languageId, result[languageId] ?? "", project.projectId);
//         translationList.add(translation);
//       }
//       addTranslationRemote(translationList);
//     } else {
//       print("result.isEmpty");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         floatingActionButton: FloatingActionButton(
//           tooltip: "添加语言",
//           elevation: 30,
//           onPressed: () async {
//             var result = await showDialog(
//                 barrierDismissible: true,
//                 context: context,
//                 builder: (context) {
//                   return buildTranslationEditDialog(null, context, null);
//                 });
//             addTranslation(result);
//           },
//           child: const Icon(Icons.add),
//         ),
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           iconTheme: const IconThemeData(color: Colors.black),
//           title: Text(
//             project.projectName,
//             style: const TextStyle(color: Colors.black),
//           ),
//           actions: [
//             GestureDetector(
//               onTap: () {
//                 showDialog(
//                     barrierDismissible: true,
//                     context: context,
//                     builder: (context) {
//                       return showAddLanguageDialog();
//                     });
//               },
//               child: Container(
//                 margin: const EdgeInsets.only(left: 10, right: 20),
//                 child: const Icon(Icons.add_circle_sharp),
//               ),
//             )
//           ],
//         ),
//         body: buildBody());
//   }
//
//   GlobalKey importBtnKey = GlobalKey();
//
//   Widget buildBody() {
//     // if (translationMap.isEmpty) {
//     //   return const Center(child: CircularProgressIndicator());
//     // }
//     // return buildTranslationTable();
//     return Container(
//       margin: const EdgeInsets.only(left: 20, top: 50, right: 20, bottom: 50),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               TextButton(
//                 child: Text("导入"),
//                 key: importBtnKey,
//                 onPressed: () {
//                   showImportLanguageDialog();
//                 },
//               ),
//               TextButton(
//                 child: Text("导出"),
//                 onPressed: () {},
//               ),
//               SizedBox(
//                 width: 700,
//                 height: 40,
//                 child: TextFormField(
//                   autofocus: true,
//                   textInputAction: TextInputAction.next,
//                   decoration: const InputDecoration(
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(30))),
//                       filled: false,
//                       hintText: "输入key或翻译内容搜索"),
//                   onChanged: (value) {
//                     project.projectName = value;
//                   },
//                 ),
//               ),
//             ],
//           ),
//           buildTranslationTable(),
//           // buildTranslationList()
//         ],
//       ),
//     );
//   }
//
//   Widget buildTranslationItem(int index) {
//     Translation translation = translationList[index];
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         Expanded(
//           child: Container(
//               height: 45,
//               alignment: Alignment.centerLeft,
//               decoration: const BoxDecoration(
//                   border: Border(bottom: BorderSide(color: Color(0x889D9CA1)))),
//               child: Text(
//                 translation.translationKey,
//               )),
//         ),
//         Expanded(
//           child: Container(
//               height: 45,
//               padding: const EdgeInsets.only(left: 15),
//               alignment: Alignment.centerLeft,
//               decoration: const BoxDecoration(
//                   border: Border(bottom: BorderSide(color: Color(0x889D9CA1)))),
//               child: Text(
//                 translation.translationContent,
//               )),
//         )
//       ],
//     );
//   }
//
//   Widget buildTranslationList() {
//     var translationKeyList = translationMap.keys.toList(growable: false);
//     return CustomScrollView(slivers: [
//       SliverList(
//         delegate: SliverChildBuilderDelegate(
//           (context, index) {
//             var translationKey = translationKeyList[index];
//             return buildTranslationItem2(translationKey);
//           },
//           childCount: translationKeyList.length,
//         ),
//       )
//     ]);
//   }
//
//   Widget buildTranslationItem2(String translationKey) {
//     var translationContentMap = translationMap[translationKey];
//
//     List<Widget> widgetList = [];
//     for (String language in languageIdList) {
//       SizedBox text = SizedBox(
//           width: 200,
//           height: 40,
//           child: Text(translationContentMap?[language] ?? ""));
//       widgetList.add(text);
//     }
//     return Container(
//       width: 1000,
//       child: Row(
//         children: widgetList,
//       ),
//     );
//   }
//
//   Widget buildTranslationTable() {
//     return Expanded(
//       child: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             horizontalMargin: 10,
//             showBottomBorder: true,
//             columns: buildTableTitles(),
//             rows: buildTranslationRows(),
//             columnSpacing: 50,
//           ),
//         ),
//       ),
//     );
//   }
//
//   List<DataColumn> buildTableTitles() {
//     List<DataColumn> titles = [];
//     for (var element in languageIdList) {
//       titles.add(DataColumn(
//           label: GestureDetector(
//         onLongPress: () {
//           if (element == LANGUAGE_KEY) {
//             return;
//           }
//           showDialog(
//               barrierDismissible: true,
//               context: context,
//               builder: (context) {
//                 return showDeleteLanguageDialog(element);
//               });
//         },
//         child: SizedBox(
//           width: 300,
//           child: Text(
//             element,
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//         ),
//       )));
//     }
//     return titles;
//   }
//
//   List<DataRow> buildTranslationRows() {
//     List<DataRow> rows = [];
//     for (var translationKey in translationMap.keys) {
//       rows.add(DataRow(cells: buildCells(translationKey)));
//     }
//     return rows;
//   }
//
//   List<DataCell> buildCells(String translationKey) {
//     var translations = translationMap[translationKey];
//     List<DataCell> cells = [];
//     cells.add(DataCell(Text(translationKey), onDoubleTap: () {
//       showDialog(
//           barrierDismissible: true,
//           context: context,
//           builder: (context) {
//             return showDeleteTranslationDialog(translations, translationKey);
//           });
//     }));
//     if (null != translations) {
//       for (var i = 1; i < languageIdList.length; i++) {
//         var languageId = languageIdList[i];
//         var translation = translations[languageId];
//         cells.add(DataCell(Text(translation ?? ""), onTap: () async {
//           var result = await showDialog(
//               barrierDismissible: true,
//               context: context,
//               builder: (context) {
//                 return buildTranslationEditDialog(
//                     translationKey, context, translations);
//               });
//           addTranslation(result);
//         }));
//       }
//     }
//     return cells;
//   }
//
//   Widget buildTranslationEditText(
//       String? translationKey,
//       Map<String, String>? translations,
//       Map<String, String> translationChanged,
//       String languageId) {
//     String? initialValue;
//     if (languageId == LANGUAGE_KEY) {
//       initialValue = translationKey;
//     } else {
//       initialValue = translations?[languageId] ?? " ";
//     }
//     initialValue ??= " ";
//     return SizedBox(
//       width: 500,
//       height: 80,
//       child: TextFormField(
//         autofocus: true,
//         initialValue: initialValue,
//         textInputAction: TextInputAction.next,
//         decoration: InputDecoration(
//             border: const OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(5))),
//             filled: false,
//             hintText: "请输入翻译内容",
//             labelText: languageId),
//         onChanged: (value) {
//           translations?[languageId] = value;
//           translationChanged[languageId] = value;
//         },
//       ),
//     );
//   }
//
//   AlertDialog buildTranslationEditDialog(String? translationKey,
//       BuildContext context, Map<String, String>? translationIdContentMap) {
//     Map<String, String> translationIdContentMapChanged =
//         HashMap<String, String>();
//     translationIdContentMapChanged[LANGUAGE_KEY] = translationKey ?? "";
//     String? titleText = translationKey;
//     if (titleText == null) {
//       titleText = "添加语言";
//     } else {
//       titleText = "编辑语言";
//     }
//     // var keys = translationIdContentMap.keys.toList();
//     return AlertDialog(
//       elevation: 10,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       title: Text(titleText),
//       content: SizedBox(
//         height: 500,
//         width: 500,
//         child: ListView.builder(
//           shrinkWrap: true,
//           itemBuilder: (context, index) {
//             String languageId = languageIdList[index];
//             return buildTranslationEditText(
//                 translationKey,
//                 translationIdContentMap,
//                 translationIdContentMapChanged,
//                 languageId);
//           },
//           itemCount: languageIdList.length,
//         ),
//       ),
//       actions: [
//         SizedBox(
//             width: 200,
//             height: 30,
//             child: TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text("取消"))),
//         SizedBox(
//             width: 200,
//             height: 30,
//             child: TextButton(
//               onPressed: () {
//                 // translationIdContentMap[languageId] = translationTemp ?? "";
//                 String? key =
//                     translationIdContentMapChanged[LANGUAGE_KEY] ?? "";
//                 if (key.isNotEmpty) {
//                   print("key:$key");
//                   setState(() {});
//                   Navigator.of(context).pop(translationIdContentMapChanged);
//                 } else {
//                   print("key为空");
//                   Navigator.of(context).pop(null);
//                 }
//               },
//               child: const Text(
//                 "确定",
//                 style: TextStyle(color: Colors.blueAccent),
//               ),
//             )),
//       ],
//     );
//   }
//
//   String? importLanguageId = "";
//
//   void showImportLanguageDialog() {
//     RenderBox? button =
//         importBtnKey.currentContext?.findRenderObject() as RenderBox?;
//     final RenderBox? overlay =
//         Overlay.of(context).context.findRenderObject() as RenderBox?;
//     if (null != button && null != overlay) {
//       final RelativeRect position = RelativeRect.fromRect(
//         Rect.fromPoints(
//           button.localToGlobal(Offset.zero, ancestor: overlay),
//           button.localToGlobal(button.size.bottomRight(Offset.zero),
//               ancestor: overlay),
//         ),
//         Offset.zero & overlay.size,
//       );
//
//       List<PopupMenuEntry<String>> languageItemArray = [];
//       for (String languageId in languageIdList) {
//         languageItemArray.add(PopupMenuItem<String>(
//             value: languageId,
//             child: ListTile(
//                 leading: const Icon(Icons.visibility),
//                 title: Text(languageId))));
//       }
//       showMenu(context: context, position: position, items: languageItemArray)
//           .then<void>((value) {
//         if (!mounted) return null;
//         importLanguageId = value;
//         if (importLanguageId != LANGUAGE_KEY) {
//           selectFile();
//         }
//       });
//     }
//   }
//
//   Widget showAddLanguageDialog() {
//     return AlertDialog(
//       elevation: 10,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       title: const Text("添加新语言"),
//       content: SizedBox(
//         height: 300,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: 500,
//               height: 100,
//               child: TextFormField(
//                 autofocus: true,
//                 textInputAction: TextInputAction.next,
//                 decoration: const InputDecoration(
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(5))),
//                     filled: false,
//                     hintText: "请输入语言id（如cn）",
//                     labelText: "语言id"),
//                 onChanged: (value) {
//                   _newLanguageId = value;
//                 },
//               ),
//             ),
//             SizedBox(
//               width: 500,
//               height: 200,
//               child: TextFormField(
//                 autofocus: true,
//                 textInputAction: TextInputAction.next,
//                 decoration: const InputDecoration(
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(5))),
//                     filled: false,
//                     hintText: "请输入语言名字（如中文）",
//                     labelText: "语言名字"),
//                 onChanged: (value) {
//                   _newLanguageName = value;
//                 },
//               ),
//             )
//           ],
//         ),
//       ),
//       actions: [
//         SizedBox(
//             width: 200,
//             height: 30,
//             child: TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text("取消"))),
//         SizedBox(
//             width: 200,
//             height: 30,
//             child: TextButton(
//               onPressed: () {
//                 addLanguageRemote();
//                 Navigator.pop(context);
//               },
//               child: const Text(
//                 "确定",
//                 style: TextStyle(color: Colors.blueAccent),
//               ),
//             )),
//       ],
//     );
//   }
//
//   void addLanguageRemote() {
//     WJHttp()
//         .addLanguage(
//             Language(_newLanguageId, _newLanguageName, project.projectId))
//         .then((value) {
//       if (value.code == 200) {
//         fetchTranslation();
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(value.msg)));
//       }
//     });
//   }
//
//   showDeleteLanguageDialog(String languageId) {
//     return AlertDialog(
//       elevation: 10,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       title: Text("删除语言$languageId？"),
//       actions: [
//         SizedBox(
//             width: 200,
//             height: 30,
//             child: TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text("取消"))),
//         SizedBox(
//             width: 200,
//             height: 30,
//             child: TextButton(
//               onPressed: () {
//                 print("onPressed:deleteLanguageRemote(languageId)");
//                 deleteLanguageRemote(languageId);
//                 Navigator.pop(context);
//               },
//               child: const Text(
//                 "确定",
//                 style: TextStyle(color: Colors.blueAccent),
//               ),
//             )),
//       ],
//     );
//   }
//
//   showDeleteTranslationDialog(
//       Map<String, String>? translationMap, String translationKey) {
//     return AlertDialog(
//       elevation: 10,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       title: Text("是否删除翻译$translationKey？"),
//       actions: [
//         SizedBox(
//             width: 200,
//             height: 30,
//             child: TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text("取消"))),
//         SizedBox(
//             width: 200,
//             height: 30,
//             child: TextButton(
//               onPressed: () {
//                 deleteTranslationRemote(translationKey);
//                 Navigator.pop(context);
//               },
//               child: const Text(
//                 "确定",
//                 style: TextStyle(color: Colors.blueAccent),
//               ),
//             )),
//       ],
//     );
//   }
//
//   void deleteLanguageRemote(String languageId) {
//     print("deleteLanguageRemote");
//     Language language = Language(languageId, "languageName", project.projectId);
//     WJHttp().deleteLanguage(language).then((value) {
//       if (value.code == 200) {
//         languageIdList.remove(languageId);
//       }
//       setState(() {});
//     });
//   }
//
//   void deleteTranslationRemote(String translationKey) {
//     WJHttp()
//         .deleteTranslationByKey(translationKey, project.projectId)
//         .then((value) {
//       if (value.code == 200) {
//         translationMap.remove(translationKey);
//       }
//       setState(() {});
//     });
//   }
//
//   void updateTranslation(Map<String, String> translationMap) {}
//
//   void selectFile() async {
//     FilePickerResult? result = await FilePicker.platform
//         .pickFiles(type: FileType.any, allowMultiple: false);
//     if (result != null && result.files.isNotEmpty) {
//       final fileBytes = result.files.first.bytes;
//       final fileName = result.files.first.name;
//       String xmlString;
//       if (null != fileBytes) {
//         xmlString = utf8.decode(fileBytes);
//       } else {
//         xmlString = '''
//         <resources>
//           <string name="Device_charged">设备已通电</string>
//           <string name="a4x_ai_area_content">定义提醒区域，只推送精准位置的触发消息，过滤掉其余信息。</string>
//           <string name="a4x_ai_area_title">提醒区域</string>
//           <string name="a4x_ai_cloud_10GB">(≤10GB)</string>
//         </resources>
//         ''';
//       }
//       var xmlDocument = XmlDocument.parse(xmlString);
//
//       for (var element in xmlDocument.childElements) {
//         for (var childElement in element.childElements) {
//           String languageKey = childElement.attributes.first.value;
//           String translationContent = childElement.innerText;
//           print("$languageKey:$translationContent");
//           Translation translation = new Translation(
//               languageKey, "languageId", translationContent, project.projectId);
//         }
//       }
//     }
//   }
// }
