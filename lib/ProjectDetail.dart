import 'dart:collection';
import 'dart:convert';
import 'dart:html';

import 'dart:io' as io;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/AddLanguagePage.dart';
import 'package:hwj_translation_flutter/EditTranslationDetailPage.dart';
import 'package:hwj_translation_flutter/ExportLanguagePage.dart';
import 'package:hwj_translation_flutter/MergeTranslationPage.dart';
import 'package:hwj_translation_flutter/ReorderLanguageListPage.dart';
import 'package:hwj_translation_flutter/TranslationComparePage.dart';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'package:hwj_translation_flutter/net.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hwj_translation_flutter/tookit/ImportTranslationToolkit.dart';
import 'package:xml/xml.dart';
import 'package:excel/excel.dart';
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

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

  List<Translation> originalTranslationList = List.empty();
  Map<int, Map<String, Map<int, Translation>>> translationRootMap = HashMap();

  Module? mCurrentSelectedModule;

  Project project;

  ScrollController titleController = ScrollController();
  ScrollController translationListController = ScrollController();

  bool titleScrolling = false;
  bool contentScrolling = false;

  bool fuzzySearch = true;

  @override
  void initState() {
    super.initState();
    fetchTranslation();
    titleController.addListener(() {});
    translationListController.addListener(() {
      if (titleScrolling) {
        return;
      }
      contentScrolling = true;
      // print("translationListController scroll ${translationListController.offset}");
      titleController.jumpTo(translationListController.offset);
    });
  }

  void fetchTranslation() {
    translationRootMap.clear();
    translationListShowing.clear();
    WJHttp http = WJHttp();
    http.fetchModuleListV2(project.projectId).then((moduleListWrapper) {
      if (moduleListWrapper.code == 200) {
        modules = moduleListWrapper.data;
        if (modules.isNotEmpty) {
          Module currentSelectedModule = modules[0];
          mCurrentSelectedModule = currentSelectedModule;
          http.fetchLanguageListV2(project.projectId).then((languageListWrapper) {
            if (languageListWrapper.code == 200) {
              languageList = languageListWrapper.data;
              languageList.sort((a, b) {
                return (a.languageOrder ?? 0) - (b.languageOrder ?? 0);
              });
              http.fetchTranslationV2(project.projectId, moduleId: mCurrentSelectedModule?.moduleId ?? -1).then((translationListWrapper) {
                originalTranslationList = translationListWrapper.data;
                translationListShowing.addAll(originalTranslationList);
                setState(() {
                  rebuildTranslationData();
                });
              });
            }
          });
        }
      }
    });
  }

  void rebuildTranslationData() {
    // if (translationListShowing.isNotEmpty) {
    translationRootMap.clear();
    for (var element in translationListShowing) {
      Map<String, Map<int, Translation>>? keyLanguageTranslationMap = translationRootMap[element.moduleId];
      if (keyLanguageTranslationMap == null) {
        keyLanguageTranslationMap = HashMap();
        translationRootMap[element.moduleId ?? -1] = keyLanguageTranslationMap;
      }

      Map<int, Translation>? languageTranslationMap = keyLanguageTranslationMap[element.translationKey];
      if (null == languageTranslationMap) {
        languageTranslationMap = HashMap();
        keyLanguageTranslationMap[element.translationKey] = languageTranslationMap;
      }
      languageTranslationMap[element.languageId] = element;
    }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var result = await showDialog(
                barrierDismissible: true,
                context: context,
                builder: (context) {
                  if (languageList.isNotEmpty) {
                    return buildTranslationEditDialog(null, context, null);
                  } else {
                    return AlertDialog(
                      elevation: 10,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text("请先添加语言"),
                    );
                  }
                });
            handleTranslationEdit(result, true);
          },
          enableFeedback: false,
          tooltip: "添加翻译",
          elevation: 30,
          child: const Icon(Icons.add),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            project.projectId ?? "",
            style: Theme.of(context).textTheme.displayLarge,
          ),
          actions: buildActions(),
        ),
        body: buildBody());
  }

  List<Widget> buildActions() {
    List<Widget> actions = [];
    actions.add(TextButton(
      onPressed: () {
        toAddLanguagePage();
      },
      child: const Text("新增语言"),
    ));
    actions.add(TextButton(
      key: importBtnKey,
      onPressed: () {
        List<String> platforms = ["android", "ios", "excel"];
        showSelectPlatformDialog(platforms, (platForm) {
          if (platForm == null) {
            return;
          }
          onValue(result) {
            if (result.code == -1) {
              showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text("导入翻译出错"),
                        content: Text(result.msg),
                      ));
            } else {
              var failedList = result.data;
              if (failedList.isNotEmpty) {
                print("有重复翻译");
                toComparePage(failedList);
              } else {
                print("导入成功");
                fetchTranslation();
              }
            }
          }

          if (platForm == "excel") {
            ImportTranslationToolkit().importExcel(languageList, project.projectId, mCurrentSelectedModule?.moduleId ?? 0).then(onValue);
          } else {
            buildImportLanguageDialog((language) {
              if (platForm == "android") {
                ImportTranslationToolkit().importAndroid(language, mCurrentSelectedModule?.moduleId ?? 0).then(onValue);
              } else if (platForm == "ios") {
                ImportTranslationToolkit().importIOS(language, mCurrentSelectedModule?.moduleId ?? 0).then(onValue);
              }
            });
          }
        });
      },
      child: const Text("导入"),
    ));
    actions.add(TextButton(
      onPressed: () {
        toExportPage();
      },
      child: const Text("导出"),
    ));
    actions.add(TextButton(
        onPressed: () {
          toMergeTranslationPage();
        },
        child: const Text("合并相似项")));
    return actions;
  }

  GlobalKey addLanguageKey = GlobalKey();
  GlobalKey importBtnKey = GlobalKey();
  GlobalKey languageTitleItemKey = GlobalKey();

  Widget buildBody() {
    return Container(
      // color: Colors.blueGrey,

      margin: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 80),
      child: Column(
        // physics: const NeverScrollableScrollPhysics(),
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 40,
            child: Container(
              decoration: const BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.all(Radius.circular(25.0))),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  buildDropDown(),
                  Expanded(
                    child: TextFormField(
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(border: InputBorder.none, filled: false, hintText: "输入key或翻译内容搜索"),
                      onChanged: (value) {
                        // project.projectName = value;
                      },
                      onFieldSubmitted: (value) {
                        searchTranslation(value);
                      },
                    ),
                  ),
                  const Text("模糊查找"),
                  Switch(
                    value: fuzzySearch,
                    onChanged: (bool value) {
                      setState(() {
                        fuzzySearch = value;
                      });
                    },
                    activeColor: Colors.blueAccent,
                  ),
                ],
              ),
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
      GestureDetector? gestureDetector;
      gestureDetector = GestureDetector(
          key: GlobalKey(debugLabel: language.languageName),
          child: textItem,
          onTap: () {
            showLanguageOptDialog(gestureDetector!, language);
            // showDialog(
            //     barrierDismissible: true,
            //     context: context,
            //     builder: (context) {
            //       return buildDeleteLanguageDialog(language);
            //     });
          });
      widgetList.add(gestureDetector);
    }

    return SizedBox(
        height: 60,
        child: ListView(
          itemExtent: 210,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          controller: titleController,
          children: widgetList,
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
                return buildDeleteTranslationDialog(translationKey);
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
                  return buildTranslationEditDialog(translationKey, context, languageTranslationMap);
                });
            handleTranslationEdit(result, false);
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

  Widget buildTranslationEditDialog(String? translationKey, BuildContext context, Map<int, Translation>? translationIdContentMap) {
    return AlertDialog(
      elevation: 10,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // title: Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //   children: [
      //     Text(titleText),
      //     Text("复制"),
      //   ],
      // ),
      content: SizedBox(
        width: 1000,
        child: EditTranslationDetailPage(project.projectId, mCurrentSelectedModule?.moduleId ?? 0, translationKey, translationIdContentMap, languageList),
      ),
    );
  }

  void handleTranslationEdit(Map<String, Map<int, Translation?>?>? translationContentMap, bool add) {
    if (null != translationContentMap) {
      String translationKey = translationContentMap.keys.first;
      print("编辑回调：$translationKey");
      Map<int, Translation?>? languageIdToTranslationMap = translationContentMap.values.first;
      if (languageIdToTranslationMap != null) {
        if (null != mCurrentSelectedModule) {
          int? moduleId = mCurrentSelectedModule?.moduleId;
          if (null != moduleId) {
            List<Translation> addTranslationList = [];
            List<Translation> updateTranslationList = [];
            for (Translation? translation in languageIdToTranslationMap.values) {
              if (translation != null) {
                if (translation.translationId == null) {
                  translation.moduleId = this.modules.first.moduleId;
                  translation.translationKey = translationKey;
                  var oldTranslationContent = translation.oldTranslationContent;
                  if (translation.translationContent.trim().isNotEmpty || (oldTranslationContent != null && oldTranslationContent.isNotEmpty)) {
                    print("新增翻译：${translation.toJson()}");
                    addTranslationList.add(translation);
                  }
                } else {
                  var oldTranslationContent = translation.oldTranslationContent;
                  if (translation.translationKey != translationKey || //是否修改过key
                          oldTranslationContent != null //是否修改过翻译
                      ) {
                    translation.translationKey = translationKey;
                    print("更新翻译：${translation.toJson()}");
                    updateTranslationList.add(translation);
                  }

                }
              }
            }
            if (addTranslationList.isNotEmpty) {
              addTranslationRemote(addTranslationList, add: true, reFetchData: true);
            }
            if (updateTranslationList.isNotEmpty) {
              addTranslationRemote(updateTranslationList, add: false, reFetchData: true);
            }

            // Map<int, Translation>? localTranslationKeyLanguageMap;
            // localTranslationKeyLanguageMap = translationRootMap[moduleId]?[translationKey];
            // if (null != localTranslationKeyLanguageMap) {
            //   for (Language language in languageList) {
            //     String? changeContent = languageContentMapChange[language.languageId];
            //     Translation? translation = localTranslationKeyLanguageMap[language.languageId];
            //     if (null != changeContent) {
            //       if (null != translation) {
            //         translation.translationContent = changeContent;
            //         translation.forceAdd = false;
            //       } else {
            //         translation = Translation(translationKey, language.languageId ?? 0, changeContent, project.projectId, forceAdd: true, moduleId: mCurrentSelectedModule?.moduleId ?? 0);
            //         localTranslationKeyLanguageMap[language.languageId ?? 0] = translation;
            //       }
            //       translationList.add(translation);
            //     }
            //   }
            // } else {
            //   languageContentMapChange.keys.forEach((languageId) {
            //     Translation newTranslation = Translation(translationKey, languageId, languageContentMapChange[languageId] ?? "", project.projectId, forceAdd: true, moduleId: mCurrentSelectedModule?.moduleId ?? 0);
            //     translationList.add(newTranslation);
            //   });
            // }
            // addTranslationRemote(translationList, add: add, reFetchData: true);
          }
        }
      }
    }
  }

  Language? importLanguageName = null;
  String? importPlatform = "";

  void buildImportLanguageDialog(Function action) {
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
        if (!mounted && null != value) return null;
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

  void buildLanguageOptDialog(GestureDetector gestureDetector, List<String> platforms, Function action) {
    Key? globalKey = gestureDetector.key;
    if (globalKey != null) {
      if (globalKey is GlobalKey) {
        RenderBox? button = globalKey.currentContext?.findRenderObject() as RenderBox?;
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
    }
  }

  void showLanguageOptDialog(GestureDetector gestureDetector, Language language) {
    List<String> optItemList = ["排序", "删除"];
    buildLanguageOptDialog(gestureDetector, optItemList, (optItem) {
      if (optItem == "排序") {
        toReorderLanguagePage();
      } else if (optItem == "删除") {
        showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) {
              return buildDeleteLanguageDialog(language);
            });
      }
    });
  }

  buildDeleteLanguageDialog(Language language) {
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

  buildDeleteTranslationDialog(String translationKey) {
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

  void addTranslationRemote(List<Translation> translationList, {bool reFetchData = true, bool add = true}) {
    onValue(value) {
      if (value.code == 200) {
        print("添加翻译成功");
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
    }

    if (add) {
      WJHttp().addTranslationsV2(translationList).then(onValue);
    } else {
      WJHttp().updateTranslationsV2(translationList).then(onValue);
    }
  }

  void toComparePage(List<Translation> translationList) async {
    bool refresh = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => TranslationComparePage(translationList)));
    if (refresh) {
      fetchTranslation();
    }
  }

  void toExportPage() async {
    List<Language>? newLangList = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ExportLanguagePage(project, languageList, modules, translationRootMap)));
    if (newLangList != null && newLangList.isNotEmpty) {
      // addLanguageRemote(newLangList);
    }
  }

  void toMergeTranslationPage() async {
    List<Language> showLanguageList = [];
    int count = 0;
    languageList.forEach((element) {
      if (count < 2) {
        showLanguageList.add(element);
        count++;
      }
    });
    bool refresh = await Navigator.of(context).push(MaterialPageRoute(builder: (content) => MergeTranslationPage(translationRootMap.values.first, showLanguageList)));
    if (refresh) {
      fetchTranslation();
    }
  }

  void toAddLanguagePage() async {
    List<Language>? newLangList = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddLanguagePage(project, languageList)));
    if (newLangList != null && newLangList.isNotEmpty) {
      addLanguageRemote(newLangList);
    }
  }

  void toReorderLanguagePage() async {
    List<Language>? newLangList = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ReorderLanguageListPage(project, languageList)));
    if (newLangList != null && newLangList.isNotEmpty) {
      setState(() {
        languageList = newLangList;
        rebuildTranslationData();
      });
    }
  }

  void addLanguageRemote(List<Language> languageList) {
    WJHttp().addLanguagesV2(languageList).then((value) {
      fetchTranslation();
      if (value.data.isNotEmpty) {
        var errorTipsBuffer = StringBuffer();
        for (var element in value.data) {
          errorTipsBuffer.write("${element.languageDes}(${element.languageName}),");
        }
        errorTipsBuffer.write("添加成功");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorTipsBuffer.toString())));
      }
    });
  }

  void deleteLanguageRemote(Language language) {
    print("deleteLanguageRemote");
    WJHttp().deleteLanguageV2(language).then((value) {
      if (value.code == 200) {
        languageList.remove(language);
      }
      setState(() {});
    });
  }

  void deleteTranslationRemote(String translationKey) {
    WJHttp().deleteTranslationByKeyV2(translationKey, project.projectId).then((value) {
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
    WJHttp().addTranslationsV2(translationSet.toList(growable: false)).then((value) {
      if (value.code == 200) {
        print("更新翻译成功");
      } else {
        print("更新翻译失败，失败列表:${value.data.length}");
      }
      fetchTranslation();
    });
  }

  void exportTranslationExcel() {
    print("exportTranslationExcel");
    Excel excel = Excel.createExcel();
    String? defaultSheet = excel.getDefaultSheet();
    List<CellValue> titleRow = List.empty(growable: true);
    titleRow.add(TextCellValue("Key"));
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

  void searchTranslation(String keyword) {
    if (keyword.isNotEmpty) {
      translationListShowing.clear();
      Map<String, Map<int, Translation>?> resultMap = HashMap();
      List<String> searchResultKey = [];
      originalTranslationList.forEach((element) {
        String? compareString;
        if (searchLanguageId == null) {
          compareString = element.translationKey;
        } else {
          if (element.languageId == searchLanguageId) {
            compareString = element.translationContent;
          }
        }
        if (compareString != null) {
          if (fuzzySearch) {
            var ratioValue = ratio(keyword, compareString);
            if (ratioValue > 20) {
              print("$compareString : $ratioValue");
              element.ratio = ratioValue;
              searchResultKey.add(element.translationKey);
            }
          } else {
            if (compareString.contains(keyword)) {
              searchResultKey.add(element.translationKey);
            }
          }
        }
      });
      translationListShowing.clear();
      originalTranslationList.forEach((element) {
        if (searchResultKey.contains(element.translationKey)) {
          translationListShowing.add(element);
        }
      });
    } else {
      translationListShowing.clear();
      translationListShowing.addAll(originalTranslationList);
    }
    translationListShowing.sort((t1, t2) {
      return (t2.ratio ?? 0) - (t1.ratio ?? 0);
    });
    print("sort");
    translationListShowing.forEach((element) {
      print("${element.translationContent} ${element.ratio}");
    });
    setState(() {
      rebuildTranslationData();
    });
  }

  String dropdownValue = 'Key';
  int? searchLanguageId;

  Widget buildDropDown() {
    List<String> searchType = [];
    searchType.add("Key");
    for (Language language in languageList) {
      searchType.add(language.languageName);
    }
    return DropdownMenu<String>(
      initialSelection: searchType.first,
      leadingIcon: const Icon(Icons.search),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
      ),
      onSelected: (String? value) {
        setState(() {
          if (value == 'Key') {
            searchLanguageId = null;
          } else {
            for (Language language in languageList) {
              if (language.languageName == value) {
                searchLanguageId = language.languageId;
                break;
              }
            }
          }
          dropdownValue = value!;
        });
      },
      dropdownMenuEntries: searchType.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );
  }
}
