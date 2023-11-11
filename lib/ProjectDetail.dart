import 'dart:collection';
import 'dart:convert';
import 'dart:html';

import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'package:hwj_translation_flutter/net.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart';

class ProjectDetail extends StatefulWidget {
  ProjectDetail(this.project);

  final Project project;

  @override
  State<StatefulWidget> createState() => _ProjectDetail(project);
}

class _ProjectDetail extends State<ProjectDetail> {
  _ProjectDetail(this.project);

  List<Language> languageList = [];
  List<Module> modules = [];

  List<Translation> translationList = List.empty();
  Map<int, Map<String, Map<int, Translation>>> translationRootMap = HashMap();

  Module? mCurrentSelectedModule;

  Project project;

  String _newlanguageName = "";
  String _newLanguageName = "";
  String translationKeyChange = "";

  @override
  void initState() {
    super.initState();
    fetchTranslation();
  }

  void fetchTranslation() {
    WJHttp http = WJHttp();
    http.fetchModuleList(project.projectId).then((moduleListWrapper) {
      if (moduleListWrapper.code == 200) {
        modules = moduleListWrapper.data;
        if (modules.isNotEmpty) {
          Module currentSelectedModule = modules[0];
          mCurrentSelectedModule = currentSelectedModule;
          http.fetchLanguageList(project.projectId).then((languageListWrapper) {
            if (languageListWrapper.code == 200) {
              languageList = languageListWrapper.data;
              for (Language element in languageList) {
                print("语言：${element.languageName}");
              }
              http.fetchTranslation(project.projectId, moduleId: mCurrentSelectedModule?.moduleId ?? -1).then((translationListWrapper) {
                setState(() {
                  translationList = translationListWrapper.data;
                  for (var element in translationList) {
                    Map<String, Map<int, Translation>>? translationKeyLanguageTranslationMap = translationRootMap[element.moduleId];
                    if (translationKeyLanguageTranslationMap == null) {
                      translationKeyLanguageTranslationMap = HashMap();
                      translationRootMap[element.moduleId ?? -1] = translationKeyLanguageTranslationMap;
                    }

                    Map<int, Translation>? languageTranslationMap = translationKeyLanguageTranslationMap[element.translationKey];
                    if (null == languageTranslationMap) {
                      languageTranslationMap = HashMap();
                      translationKeyLanguageTranslationMap[element.translationKey] = languageTranslationMap;
                    }
                    languageTranslationMap[element.languageId] = element;
                  }
                });
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          tooltip: "添加语言",
          elevation: 30,
          onPressed: () async {
            var result = await showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return showTranslationEditDialog(null, context, null);
                });
            addTranslationRemote(result.toList());
          },
          child: const Icon(Icons.add),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            project.projectName,
            style: const TextStyle(color: Colors.black),
          ),
          actions: buildActions(),
        ),
        body: buildBody());
  }

  List<Widget> buildActions() {
    List<Widget> actions = [];
    actions.add(GestureDetector(
      onTap: () {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return showAddLanguageDialog();
            });
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 20),
        child: const Icon(Icons.add_circle_sharp),
      ),
    ));
    actions.add(TextButton(
      key: importBtnKey,
      onPressed: () {
        showImportLanguageDialog((value) => selectFile(value));
      },
      child: const Text("导入"),
    ));
    actions.add(TextButton(
      child: const Text("导出"),
      onPressed: () {
        showImportLanguageDialog((language) => showSelectPlatformDialog((platform) => exportTranslation(platform, language)));
      },
    ));
    return actions;
  }

  GlobalKey importBtnKey = GlobalKey();

  Widget buildBody() {
    // if (translationMap.isEmpty) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    return Container(
      margin: const EdgeInsets.only(left: 20, top: 50, right: 20, bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 700,
                height: 40,
                child: TextFormField(
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))), filled: false, hintText: "输入key或翻译内容搜索"),
                  onChanged: (value) {
                    project.projectName = value;
                  },
                ),
              ),
            ],
          ),
          // buildTranslationTable(),
          buildLanguageListTitle(),
          buildTranslationList(mCurrentSelectedModule)
        ],
      ),
    );
  }

  Widget buildTranslationList(Module? module) {
    List<Map<int, Translation>> translationList = [];
    if (module == null) {
      print("module == null");
      for (Map<String, Map<int, Translation>> element in translationRootMap.values) {
        translationList.addAll(element.values);
      }
    } else {
      print("module == ${module.moduleName}");
      Map<String, Map<int, Translation>>? t = translationRootMap[module.moduleId];
      print("translation : ${t?.values.length ?? 0}");
      if (null != t) {
        translationList.addAll(t.values);
      }
    }
    return Expanded(
      child: ListView(
        scrollDirection: Axis.horizontal,
        itemExtent: 2160,
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return buildTranslationListItem(translationList[index]);
            },
            itemCount: translationList.length,
          )
        ],
      ),
    );
  }

  Widget buildLanguageListTitle() {
    List<Widget> widgetList = [];

    Widget textItem = buildTranslationText("Key", FontWeight.bold);
    widgetList.add(textItem);
    for (Language language in languageList) {
      Widget textItem = buildTranslationText("${language.languageDes}(${language.languageName})", FontWeight.bold);
      GestureDetector gestureDetector = GestureDetector(
          child: textItem,
          onDoubleTap: () {
            showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return showDeleteLanguageDialog(language);
                });
          });
      widgetList.add(gestureDetector);
    }
    return Flex(
      direction: Axis.horizontal,
      children: widgetList,
    );
  }

  Widget buildTranslationListItem(Map<int, Translation> languageTranslationMap) {
    List<Widget> widgetList = [];
    if (languageTranslationMap.isNotEmpty) {
      //Key
      String translationKey = languageTranslationMap.values.first.translationKey;
      Widget keyItem = buildTranslationText(translationKey, FontWeight.bold);
      widgetList.add(GestureDetector(
        child: keyItem,
        onDoubleTap: () {
          showDialog(
              barrierDismissible: true,
              context: context,
              builder: (context) {
                return showDeleteTranslationDialog(translationKey);
              });
        },
      ));
      //翻译列表
      for (Language language in languageList) {
        Widget contentItem = buildTranslationText(languageTranslationMap[language.languageId]?.translationContent ?? "", null);
        widgetList.add(GestureDetector(
          child: contentItem,
          onTap: () async {
            var result = await showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  return showTranslationEditDialog(translationKey, context, languageTranslationMap);
                });

            addTranslationRemote(result.toList());
          },
        ));
      }
    }
    return Flex(
      direction: Axis.horizontal,
      children: widgetList,
    );
  }

  Widget buildTranslationText(String text, FontWeight? fontWeight) {
    // print("buildTranslationText $text");
    Container textItem = Container(
        color: Colors.white70,
        width: 200,
        margin: const EdgeInsets.only(left: 5, right: 5, top: 1, bottom: 1),
        height: 40,
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          maxLines: 1,
          style: TextStyle(fontWeight: fontWeight),
        ));
    return textItem;
  }

  Widget buildTranslationEditText(int index, String? translationKey, Map<String, String>? translations, Map<String, String> translationChanged, String languageName) {
    String? initialValue;
    if (index == 0) {
      initialValue = translationKey;
    } else {
      initialValue = translations?[languageName] ?? " ";
    }
    initialValue ??= " ";
    return SizedBox(
      width: 500,
      height: 80,
      child: TextFormField(
        autofocus: true,
        initialValue: initialValue,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))), filled: false, hintText: "请输入内容", labelText: languageName),
        onChanged: (value) {
          translations?[languageName] = value;
          translationChanged[languageName] = value;
        },
      ),
    );
  }

  AlertDialog showTranslationEditDialog(String? translationKey, BuildContext context, Map<int, Translation>? translationIdContentMap) {
    Set<Translation> translationChangedList = {};
    // translationChangedList[LANGUAGE_KEY] = translationKey ?? "";
    String? titleText;
    translationKeyChange = translationKey ?? "";
    if (translationKey == null) {
      titleText = "添加语言";
    } else {
      titleText = "编辑语言";
    }
    print(titleText);
    // var keys = translationIdContentMap.keys.toList();

    List<Widget> widgetList = [];
    Widget keyItem = Container(
      width: 500,
      height: 80,
      margin: EdgeInsets.only(top: 10),
      child: TextFormField(
        autofocus: true,
        initialValue: translationKey,
        textInputAction: TextInputAction.next,
        decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))), filled: false, hintText: "请输入Key", labelText: "LanguageKey"),
        onChanged: (value) {
          print("onChange:translationKeyChange:$value");
          translationKeyChange = value;
        },
      ),
    );
    widgetList.add(keyItem);
    for (int i = 0; i < languageList.length; i++) {
      Language language = languageList[i];
      var translation = translationIdContentMap?[language.languageId];
      Widget translationItem = SizedBox(
        width: 500,
        height: 80,
        child: TextFormField(
          autofocus: true,
          initialValue: translation?.translationContent ?? " ",
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))), filled: false, hintText: "请输入内容", labelText: "${language.languageName}(${language.languageDes})"),
          onChanged: (value) {
            if (null != translation) {
              print("onChange:translation.translationContent:$value");
              translation.translationContent = value;
              translationChangedList.add(translation);
            } else {
              Translation newTranslation = Translation(translationKeyChange, language.languageId ?? -1, value, project.projectId, moduleId: mCurrentSelectedModule?.moduleId ?? 0, forceAdd: true);
              translationChangedList.add(newTranslation);
            }
          },
        ),
      );
      widgetList.add(translationItem);
    }

    return AlertDialog(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(titleText),
      content: SizedBox(
        width: 1000,
        child: Row(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: widgetList,
              ),
            ),
            Container(
              decoration: BoxDecoration(),
              width: 300,
              height: 300,
              child: TextFormField(
                autofocus: true,
                initialValue: " aaaaaaa",
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10), //内容内边距，影响高度
                  border: OutlineInputBorder(
                    gapPadding: 0,
                    borderSide: BorderSide.none,
                  ),
                  filled: false,
                ),
                onChanged: (value) {},
              ),
            ),
          ],
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
                // translationIdContentMap[languageName] = translationTemp ?? "";

                if (translationKeyChange.isNotEmpty) {
                  print("key:$translationKeyChange");
                  setState(() {});
                  Navigator.of(context).pop(translationChangedList);
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

  Language? importLanguageName = null;
  String? importPlatform = "";

  void showImportLanguageDialog(Function action) {
    RenderBox? button = importBtnKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (null != button && null != overlay) {
      final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
          button.localToGlobal(Offset.zero, ancestor: overlay),
          button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      );

      List<PopupMenuEntry<Language>> languageItemArray = [];
      for (Language language in languageList) {
        languageItemArray.add(PopupMenuItem<Language>(value: language, child: ListTile(leading: const Icon(Icons.visibility), title: Text("${language.languageName}(${language.languageDes})"))));
      }
      showMenu(context: context, position: position, items: languageItemArray).then<void>((value) {
        if (!mounted) return null;
        importLanguageName = value;
        action(value);
      });
    }
  }

  void showSelectPlatformDialog(Function action) {
    RenderBox? button = importBtnKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (null != button && null != overlay) {
      final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
          button.localToGlobal(Offset.zero, ancestor: overlay),
          button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      );

      List<PopupMenuEntry<String>> languageItemArray = [];
      List<String> platforms = ["android", "ios"];
      for (String platform in platforms) {
        languageItemArray.add(PopupMenuItem<String>(value: platform, child: ListTile(leading: const Icon(Icons.visibility), title: Text(platform))));
      }
      showMenu(context: context, position: position, items: languageItemArray).then<void>((value) {
        if (!mounted) return null;
        importPlatform = value;
        action(value);
      });
    }
  }

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
                  _newlanguageName = value;
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
                  _newLanguageName = value;
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
                  Navigator.pop(context);
                },
                child: const Text("取消"))),
        SizedBox(
            width: 200,
            height: 30,
            child: TextButton(
              onPressed: () {
                addLanguageRemote();
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

  showDeleteLanguageDialog(Language language) {
    return AlertDialog(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text("删除语言$language？"),
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
                print("onPressed:deleteLanguageRemote(languageName)");
                deleteLanguageRemote(language);
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

  showDeleteTranslationDialog(String translationKey) {
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

  void addTranslationRemote(List<Translation> translationList) {
    WJHttp().addTranslations(translationList).then((value) {
      if (value.code == 200) {
        print("添加翻译成功");
      } else {
        print("添加翻译失败，失败列表:${value.data.length}");
      }
      fetchTranslation();
    });
  }

  // void addTranslation(Map<int, Translation> result, int languageId) {
  //   if (languageId == -1) {
  //     print("languageId:$languageId");
  //     return;
  //   }
  //   if (result.isNotEmpty) {
  //     print("result.isNotEmpty");
  //     var languageIdList = result.keys.toList(growable: false);
  //     String key = result[languageIdList[0]]?.translationKey ?? "";
  //     if (key.isEmpty) {
  //       print("key.isEmpty");
  //       return;
  //     }
  //     print("key:$key");
  //     for (int i = 1; i < languageIdList.length; i++) {
  //       int languageId = languageIdList[i];
  //       Translation translation = Translation(key, languageId, result[languageId]?.translationContent ?? "", project.projectId);
  //       translationList.add(translation);
  //     }
  //     addTranslationRemote(translationList);
  //   } else {
  //     print("result.isEmpty");
  //   }
  // }

  void addLanguageRemote() {
    WJHttp().addLanguage(Language(_newlanguageName, _newLanguageName, project.projectId)).then((value) {
      if (value.code == 200) {
        fetchTranslation();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value.msg)));
      }
    });
  }

  void deleteLanguageRemote(Language language) {
    print("deleteLanguageRemote");
    WJHttp().deleteLanguage(language).then((value) {
      if (value.code == 200) {
        languageList.remove(language);
      }
      setState(() {});
    });
  }

  void deleteTranslationRemote(String translationKey) {
    WJHttp().deleteTranslationByKey(translationKey, project.projectId).then((value) {
      if (value.code == 200) {
        int? moduleId = mCurrentSelectedModule?.moduleId;
        if (null != moduleId) {
          var translationKeyMap = translationRootMap[moduleId];
          if (null != translationKeyMap) {
            translationKeyMap.remove(translationKey);
          }
        }
      }
      setState(() {});
    });
  }

  void updateTranslation(Set<Translation> translationSet) {
    WJHttp().addTranslations(translationSet.toList(growable: false)).then((value) {
      if (value.code == 200) {
        print("更新翻译成功");
      } else {
        print("更新翻译失败，失败列表:${value.data.length}");
      }
      fetchTranslation();
    });
  }

  void selectFile(Language language) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      final fileBytes = result.files.first.bytes;
      String xmlString;
      if (null != fileBytes) {
        xmlString = utf8.decode(fileBytes);
      } else {
        xmlString = '''
        <resources>
          <string name="Device_charged">设备已通电</string>
          <string-array name="night_node_array">
              <item>全彩夜视</item>
              <item>红外夜视</item>
              <item>黑白夜视</item>
          </string-array>
        </resources>
        ''';
      }
      var xmlDocument = XmlDocument.parse(xmlString);

      List<Translation> translations = [];
      for (var element in xmlDocument.childElements) {
        var elementName = element.name.toXmlString();
        print(elementName);
        if (elementName == "resources") {
          for (var childElement in element.childElements) {
            var childElementName = childElement.name.toXmlString();
            print(childElementName);
            if (childElementName == "string") {
              String languageKey = childElement.attributes.first.value;
              String translationContent = childElement.innerText;
              print("$languageKey:$translationContent");

              Translation translation = Translation(languageKey, language.languageId ?? 0, translationContent, project.projectId, moduleId: mCurrentSelectedModule?.moduleId ?? 0, forceAdd: false);
              translations.add(translation);
            } else if (childElementName == "string-array") {
              String languageKey = childElement.attributes.first.value;
              StringBuffer translationContentBuilder = StringBuffer();
              for (var thirdChildElement in childElement.childElements) {
                translationContentBuilder.write(thirdChildElement.innerText);
                translationContentBuilder.write("|");
              }

              String translationContent = translationContentBuilder.toString();
              Translation translation = Translation(languageKey, language.languageId ?? 0, translationContent, project.projectId, moduleId: mCurrentSelectedModule?.moduleId ?? 0, forceAdd: false);
              translations.add(translation);
            }

          }
        }
      }
      addTranslationRemote(translations);
    }
  }

  /// <string-array name="alarm_frequency">
  ///         <item>No Restrictions</item>
  ///         <item>1min</item>
  ///         <item>3min</item>
  ///         <item>5min</item>
  /// </string-array>
  ///
  void exportTranslation(String platform, Language language) {
    StringBuffer sb = StringBuffer();
    if (platform == "android") {
      sb.write('''<?xml version="1.0" encoding="utf-8"?>\n ''');
      sb.write('''<resources>\n''');
    }

    for (Module module in modules) {
      Map<String, Map<int, Translation>>? translationListInModule = translationRootMap[module.moduleId];
      if (null != translationListInModule) {
        for (Map<int, Translation> translationLanguageContentMap in translationListInModule.values) {
          Translation? translation = translationLanguageContentMap[language.languageId];
          if (translation != null) {
            String trans;
            if (translation.translationContent.contains("|")) {
              //数组
              var stringArray = translation.translationContent.split("|");
              if (platform == "ios") {
                // trans = "\n\"$key\"=$content";
                for (int i = 0; i < stringArray.length; i++) {
                  String str = stringArray[i];
                  trans = '''"${translation.translationKey}"$i=$str\n''';
                  print("trans$trans");
                }
              } else {
                //<string name="Device_charged">设备已通电</string>
                sb.write('''  <string-array name="${translation.translationKey}">\n''');
                for (int i = 0; i < stringArray.length; i++) {
                  String str = stringArray[i];
                  trans = '''   <item>$str</item>\n''';
                  sb.write(trans);
                }
                sb.write('''  </string-array>''');
              }
            } else {
              if (platform == "ios") {
                // trans = "\n\"$key\"=$content";
                trans = ''' "${translation.translationKey}"=${translation.translationContent}\n''';
              } else {
                //<string name="Device_charged">设备已通电</string>
                trans = ''' <string name="${translation.translationKey}">${translation.translationContent}</string>\n''';
              }
              print("trans$trans");
              sb.write(trans);
            }
          }
        }
      }
    }

    if (platform == "android") {
      sb.write('''\n</resources> ''');
    }

    var string = sb.toString();
    var downloadName = "Localizable.strings";
    if (platform == "android") {
      downloadName = "strings.xml";
    }
    final anchor = AnchorElement(href: 'data:application/octet-stream;utf-8,$string')..target = 'blank';

    anchor.download = downloadName;
    var body = document.body;
    if (null != body) {
      body.append(anchor);
    }
    anchor.click();
    anchor.remove();
  }

// Widget buildTranslationTable() {
//   return Expanded(
//     child: SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: DataTable(
//           horizontalMargin: 10,
//           showBottomBorder: true,
//           columns: buildTableTitles(),
//           rows: buildTranslationRows(),
//           columnSpacing: 50,
//         ),
//       ),
//     ),
//   );
// }
//
// List<DataColumn> buildTableTitles() {
//   List<DataColumn> titles = [];
//   List<String> titleItem = [];
//   titleItem.add("LanguageKey");
//   titleItem.addAll(languageNameList);
//   for (int i = 0; i < titleItem.length; i++) {
//     var element = titleItem[i];
//     titles.add(DataColumn(
//         label: GestureDetector(
//       onLongPress: () {
//         if (i == 0) {
//           return;
//         }
//         showDialog(
//             barrierDismissible: true,
//             context: context,
//             builder: (context) {
//               return showDeleteLanguageDialog(element);
//             });
//       },
//       child: SizedBox(
//         width: 100,
//         child: Text(
//           element,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//     )));
//   }
//
//   return titles;
// }

// List<DataRow> buildTranslationRows() {
//   List<DataRow> rows = [];
//   for (var translationKey in translationKeyContentMap.keys) {
//     rows.add(DataRow(cells: buildCells(translationKey)));
//   }
//   return rows;
// }
//
//   List<DataCell> buildCells(String translationKey) {
//     var translations = translationRootMap[translationKey];
//     List<DataCell> cells = [];
//     cells.add(DataCell(Text(translationKey), onDoubleTap: () {
//       showDialog(
//           barrierDismissible: true,
//           context: context,
//           builder: (context) {
//             return showDeleteTranslationDialog(translations, translationKey);
//           });
//     }));
//
//     for (var i = 0; i < languageList.length; i++) {
//       var languageName = languageList[i];
//       var translation = translations?[languageName];
//       cells.add(DataCell(
//           ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: 200),
//               child: Text(
//                 translation ?? "",
//                 overflow: TextOverflow.ellipsis,
//               )), onTap: () async {
//         var result = await showDialog(
//             barrierDismissible: true,
//             context: context,
//             builder: (context) {
//               return showTranslationEditDialog(translationKey, context, translations);
//             });
//         addTranslation(result);
//       }));
//     }
//
//     return cells;
//   }
}
