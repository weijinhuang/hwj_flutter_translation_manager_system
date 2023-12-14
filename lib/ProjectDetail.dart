import 'dart:collection';
import 'dart:convert';
import 'dart:html';

import 'dart:io' as io;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/EditTranslationDetailPage.dart';
import 'package:hwj_translation_flutter/TranslationComparePage.dart';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'package:hwj_translation_flutter/net.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart';
import 'package:excel/excel.dart';

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
  List<Translation> translationListShowing = [];

  List<Translation> translationList = List.empty();
  Map<int, Map<String, Map<int, Translation>>> translationRootMap = HashMap();

  Module? mCurrentSelectedModule;

  Project project;

  String _newlanguageName = "";
  String _newLanguageName = "";
  ScrollController titleController = ScrollController();
  ScrollController translationListController = ScrollController();

  bool titleScrolling = false;
  bool contentScrolling = false;

  @override
  void initState() {
    super.initState();
    fetchTranslation();
    titleController.addListener(() {
      // if (contentScrolling) {
      //   return;
      // }
      // titleScrolling = true;
      // print("titleController scroll ${titleController.offset}");
      // translationListController.jumpTo(titleController.offset);
    });
    translationListController.addListener(() {
      if (titleScrolling) {
        return;
      }
      contentScrolling = true;
      print("translationListController scroll ${translationListController.offset}");
      titleController.jumpTo(translationListController.offset);
    });
  }

  void fetchTranslation() {
    translationRootMap.clear();
    translationListShowing.clear();
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
              languageList.sort((a, b) {
                if (a.languageName == "en" || a.languageName == "zh") {
                  return 0;
                } else {
                  return 1;
                }
              });
              for (Language element in languageList) {
                print("语言：${element.languageName}");
              }
              http.fetchTranslation(project.projectId, moduleId: mCurrentSelectedModule?.moduleId ?? -1).then((translationListWrapper) {
                setState(() {
                  translationList = translationListWrapper.data;
                  for (var element in translationList) {
                    Map<String, Map<int, Translation>>? translationKeyLanguageTranslationMap = translationRootMap[element.moduleId];
                    if (translationKeyLanguageTranslationMap == null) {
                      print("创建translationKeyLanguageTranslationMap：moduleId:${element.moduleId}");
                      translationKeyLanguageTranslationMap = HashMap();
                      translationRootMap[element.moduleId ?? -1] = translationKeyLanguageTranslationMap;
                    }

                    Map<int, Translation>? languageTranslationMap = translationKeyLanguageTranslationMap[element.translationKey];
                    if (null == languageTranslationMap) {
                      languageTranslationMap = HashMap();
                      // print("创建languageTranslationMap：translationKey:${element.translationKey}");
                      translationKeyLanguageTranslationMap[element.translationKey] = languageTranslationMap;
                    }
                    int langId = element.languageId;
                    languageTranslationMap[langId] = element;
                    // print("languageTranslationMap[element.languageId] = element 语言id：$langId");
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
            handleTranslationEdit(result);
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
        // showImportLanguageDialog((value) => selectFile(value));

        List<String> platforms = ["android", "ios", "excel"];
        showSelectPlatformDialog(platforms, (platForm) {
          if (platForm == "excel") {
          } else {
            showImportLanguageDialog((language) {
              if (platForm == "android") {
                importAndroid(language);
              } else {
                importIOS(language);
              }
            });
          }
        });
      },
      child: const Text("导入"),
    ));
    actions.add(TextButton(
      child: const Text("导出"),
      onPressed: () {
        List<String> platforms = ["android", "ios", "excel"];
        showSelectPlatformDialog(platforms, (platForm) {
          if (platForm == "excel") {
            exportTranslationExcel();
          } else if (platForm == "android") {
            exportTranslationAndroid();
          } else {
            showImportLanguageDialog((language) {
              if (platForm == "android") {
              } else {
                exportTranslationIOS(language);
              }
            });
          }
        });
      },
    ));
    return actions;
  }

  GlobalKey importBtnKey = GlobalKey();

  Widget buildBody() {
    return Container(
      // color: Colors.blueGrey,

      margin: const EdgeInsets.only(left: 20, top: 50, right: 20, bottom: 50),
      child: Column(
        // physics: const NeverScrollableScrollPhysics(),
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: TextFormField(
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))), filled: false, hintText: "输入key或翻译内容搜索"),
              onChanged: (value) {
                // project.projectName = value;
              },
              onFieldSubmitted: (value) {
                print("onFieldSubmitted");
              },
            ),
          ),
          // buildTranslationTable(),
          buildLanguageListTitle(),
          buildTranslationList(mCurrentSelectedModule),
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
        controller: translationListController,
        scrollDirection: Axis.horizontal,
        itemExtent: 210 * (languageList.length + 1),
        children: [
          ListView.builder(
            itemBuilder: (context, index) {
              return buildTranslationListItem(translationList[index]);
            },
            itemExtent: 42,
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

    return Container(
        height: 60,
        child: ListView(
          itemExtent: 210,
          children: widgetList,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          controller: titleController,
        ));
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
            handleTranslationEdit(result);
            // if (null != result && result.isNotEmpty) {
            //   for (Translation translation in result) {
            //     if (null != mCurrentSelectedModule) {
            //       int? moduleId = mCurrentSelectedModule?.moduleId;
            //       if (null != moduleId) {
            //         var translationKeyMap = translationRootMap[moduleId];
            //         if (null != translationKeyMap) {
            //           var translationKeyLanguageMap = translationKeyMap[translation.translationKey];
            //           if (null != translationKeyLanguageMap) {
            //             translationKeyLanguageMap[translation.languageId] = translation;
            //           }
            //         }
            //       }
            //     }
            //   }
            // }
            // addTranslationRemote(result, false);
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
          overflow: TextOverflow.ellipsis,
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

  Widget showTranslationEditDialog(String? translationKey, BuildContext context, Map<int, Translation>? translationIdContentMap) {
    String? titleText;
    if (translationKey == null) {
      titleText = "添加语言";
    } else {
      titleText = "编辑语言";
    }
    print(titleText);

    return AlertDialog(
      elevation: 10,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(titleText),
      content: SizedBox(
        width: 1000,
        child: EditTranslationDetailPage(project.projectId, mCurrentSelectedModule?.moduleId ?? 0, translationKey, translationIdContentMap, languageList),
      ),
    );
  }

  void handleTranslationEdit(Map<String, Map<int, String?>?>? translationContentMap) {
    if (null != translationContentMap) {
      String translationKey = translationContentMap.keys.first;
      Map<int, String?>? languageContentMapChange = translationContentMap.values.first;
      if (languageContentMapChange != null) {
        if (null != mCurrentSelectedModule) {
          int? moduleId = mCurrentSelectedModule?.moduleId;
          if (null != moduleId) {
            Map<int, Translation>? localTranslationKeyLanguageMap;
             List<Translation> translationList = [];
             localTranslationKeyLanguageMap = translationRootMap[moduleId]?[translationKey];
            if (null != localTranslationKeyLanguageMap) {
              for (Language language in languageList) {
                String? changeContent = languageContentMapChange[language.languageId];
                Translation? translation = localTranslationKeyLanguageMap[language.languageId];
                if (null != changeContent) {
                  if (null != translation) {
                    translation.translationContent = changeContent;
                    translation.forceAdd = true;
                  } else {
                    translation = Translation(translationKey, language.languageId ?? 0, changeContent, project.projectId, forceAdd: true, moduleId: mCurrentSelectedModule?.moduleId ?? 0);
                    localTranslationKeyLanguageMap[language.languageId ?? 0] = translation;
                  }
                  translationList.add(translation);
                }
              }
            } else {
              languageContentMapChange.keys.forEach((languageId) {
                Translation newTranslation =
                Translation(translationKey, languageId, languageContentMapChange[languageId] ?? "", project.projectId, forceAdd: true, moduleId: mCurrentSelectedModule?.moduleId ?? 0);
                translationList.add(newTranslation);
              });
            }
            addTranslationRemote(translationList, true);


            // else{
            //   languageContentMapChange.keys.forEach((languageId) {
            //     Translation newTranslation =
            //     Translation(translationKey, languageId, languageContentMapChange[languageId] ?? "", project.projectId, forceAdd: true, moduleId: mCurrentSelectedModule?.moduleId ?? 0);
            //     translationList.add(newTranslation);
            //   });
            // }
          }
        }
      }
    }
    // if (null != result && result.isNotEmpty) {
    //   for (Translation translation in result) {
    //     if (null != mCurrentSelectedModule) {
    //       int? moduleId = mCurrentSelectedModule?.moduleId;
    //       if (null != moduleId) {
    //         var translationKeyMap = translationRootMap[moduleId];
    //         if (null != translationKeyMap) {
    //           var localTranslationKeyLanguageMap = translationKeyMap[translation.translationKey];
    //           if (null != localTranslationKeyLanguageMap) {
    //             localTranslationKeyLanguageMap[translation.languageId] = translation;
    //           }
    //         }
    //       }
    //     }
    //   }
    // }
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

  void showSelectPlatformDialog(List<String> platforms, Function action) {
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

  void addTranslationRemote(List<Translation> translationList, bool reFetchData) {
    WJHttp().addTranslations(translationList).then((value) {
      if (value.code == 200) {
        print("添加翻译成功");
        // setState(() {});
        if (value.data.isNotEmpty) {
          toComparePage(value.data);
        } else {
          setState(() {
            if (reFetchData) {
              fetchTranslation();
            }
          });
        }
      } else {
        print("添加翻译失败，失败列表:${value.data.length}");
      }
      // fetchTranslation();
    });
  }

  void toComparePage(List<Translation> translationList) async {
    bool refresh = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => TranslationComparePage(translationList)));
    if (refresh) {
      fetchTranslation();
    }
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

  void importIOS(Language language) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      final fileBytes = result.files.first.bytes;
      if (null != fileBytes) {
        String content = utf8.decode(fileBytes);
        var split = content.split("\n");
        List<Translation> translations = [];
        for (String line in split) {
          var kv = line.split("=");
          if (kv.length == 2) {
            Translation translation = Translation(kv[0], language.languageId ?? 0, kv[1], project.projectId, moduleId: mCurrentSelectedModule?.moduleId ?? 0, forceAdd: false);
            translations.add(translation);
          }
        }
        addTranslationRemote(translations, true);
      }
    }
  }

  void importAndroid(Language language) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      final fileBytes = result.files.first.bytes;
      String xmlString;
      if (null != fileBytes) {
        xmlString = utf8.decode(fileBytes);
      } else {
        return;
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
            } else if (childElementName == "string-array" || childElementName == "integer-array") {
              String languageKey = childElement.attributes.first.value;
              StringBuffer translationContentBuilder = StringBuffer();
              for (int i = 0, j = childElement.childElements.length; i < j; i++) {
                var thirdChildElement = childElement.childElements.elementAt(i);
                translationContentBuilder.write(thirdChildElement.innerText);
                if (i != j - 1) {
                  translationContentBuilder.write("|");
                }
              }

              String translationContent = translationContentBuilder.toString();
              Translation translation = Translation(languageKey, language.languageId ?? 0, translationContent, project.projectId, moduleId: mCurrentSelectedModule?.moduleId ?? 0, forceAdd: false);
              translations.add(translation);
            }
          }
        }
      }
      addTranslationRemote(translations, true);
    }
  }

  void exportTranslationExcel() {
    print("exportTranslationExcel");
    Excel excel = Excel.createExcel();
    String? defaultSheet = excel.getDefaultSheet();
    List<CellValue> titleRow = List.empty(growable: true);
    titleRow.add(const TextCellValue("Key"));
    for (int i = 0; i < languageList.length; i++) {
      Language language = languageList[i];
      CellValue cellValue = TextCellValue("${language.languageName}(${language.languageDes})");
      titleRow.add(cellValue);
    }
    excel.appendRow(defaultSheet ?? "Sheet1", titleRow);

    for (Module module in modules) {
      Map<String, Map<int, Translation>>? translationListInModule = translationRootMap[module.moduleId];
      if (null != translationListInModule) {
        var keys = translationListInModule.keys;
        for (String key in keys) {
          Map<int, Translation>? translationLanguageContentMap = translationListInModule[key];
          if (translationLanguageContentMap != null) {
            List<CellValue> contentRow = List.empty(growable: true);
            contentRow.add(TextCellValue(key));
            for (int i = 0; i < languageList.length; i++) {
              Language language = languageList[i];
              Translation? translation = translationLanguageContentMap[language.languageId];
              if (translation != null) {
                contentRow.add(TextCellValue(translation.translationContent));
              }
            }
            excel.appendRow(defaultSheet ?? "Sheet1", contentRow);
          }
        }
        // for (Map<int, Translation> translationLanguageContentMap
        // in translationListInModule.values) {
        //
        // }
      }
    }

    var encode = excel.encode();
    if (null != encode) {
      var base64 = base64Encode(encode);
      var downloadName = "LongVisionFullTranslation.xlsx";

      final anchor = AnchorElement(href: 'data:application/octet-stream;charset=utf-8;base64,$base64')..target = 'blank';

      anchor.download = downloadName;
      var body = document.body;
      if (null != body) {
        body.append(anchor);
      }
      anchor.click();
      anchor.remove();
      print("exportTranslationExcel end");
    }
  }

  void exportTranslationAndroid() {
    WJHttp().exportTranslationZip(project.projectId, "android").then((value) {
      var base64 = base64Encode(value.bodyBytes);
      var downloadName = "LongVisionFullTranslation.zip";

      final anchor = AnchorElement(href: 'data:application/octet-stream;charset=utf-8;base64,$base64')..target = 'blank';

      anchor.download = downloadName;
      var body = document.body;
      if (null != body) {
        body.append(anchor);
      }
      anchor.click();
      anchor.remove();
      print("exportTranslationExcel end");
    });
    return;

    // var xmlDocument = exportTranslationXML();
    //
    // var string = xmlDocument.toXmlString();
    // var downloadName = "strings.xml";
    //
    // final anchor = AnchorElement(href: '''data:application/octet-stream;utf-8,$string''')..target = 'blank';
    //
    // anchor.download = downloadName;
    // var body = document.body;
    // if (null != body) {
    //   body.append(anchor);
    // }
    // anchor.click();
    // anchor.remove();
  }

  XmlDocument exportTranslationXML(Language language) {
    final builder = XmlBuilder(optimizeNamespaces: true);
    builder.processing('xml', 'version="1.0" encoding="utf-8"');
    builder.element('resources', nest: () {
      for (Module module in modules) {
        Map<String, Map<int, Translation>>? translationListInModule = translationRootMap[module.moduleId];
        if (null != translationListInModule) {
          for (Map<int, Translation> translationLanguageContentMap in translationListInModule.values) {
            Translation? translation = translationLanguageContentMap[language.languageId];
            if (translation != null) {
              if (translation.translationContent.contains("|")) {
                //数组
                var stringArray = translation.translationContent.split("|");
                builder.element("string-array", nest: () {
                  builder.attribute("name", translation.translationKey);
                  print(translation.translationKey);
                  for (int i = 0; i < stringArray.length; i++) {
                    String str = stringArray[i];
                    builder.element("item", nest: str);
                    print("$str");
                  }
                });
              } else {
                builder.element("string", nest: () {
                  builder.attribute("name", translation.translationKey);
                  builder.text(translation.translationContent);
                });
              }
            }
          }
        }
      }
    });
    final xmlDocument = builder.buildDocument();
    return xmlDocument;
  }

  void exportTranslationIOS(Language language) {
    StringBuffer sb = StringBuffer();
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
              for (int i = 0; i < stringArray.length; i++) {
                String str = stringArray[i];
                trans = '''"${translation.translationKey}"$i="$str"\n''';
                print("trans$trans");
              }
            } else {
              // trans = "\n\"$key\"=$content";
              trans = ''' "${translation.translationKey}"="${translation.translationContent}";\n''';
              print("trans$trans");
              sb.write(trans);
            }
          }
        }
      }
    }
    var string = sb.toString();
    var downloadName = "Localizable.strings";
    final anchor = AnchorElement(href: 'data:application/octet-stream;utf-8,$string')..target = 'blank';

    anchor.download = downloadName;
    var body = document.body;
    if (null != body) {
      body.append(anchor);
    }
    anchor.click();
    anchor.remove();
  }
}
