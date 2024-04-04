import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'package:hwj_translation_flutter/net.dart';
import 'dart:convert';
import 'dart:html';
import 'package:excel/excel.dart';

class ExportLanguagePage extends StatefulWidget {
  Project project;
  List<Language> languageList;
  List<Module> modules = [];
  Map<int, Map<String, Map<int, Translation>>> translationRootMap ;
  ExportLanguagePage(this.project,this.languageList, this.modules,this.translationRootMap,{super.key});

  @override
  State<ExportLanguagePage> createState() => _ExportLanguagePageState();
}

class _ExportLanguagePageState extends State<ExportLanguagePage> {
  Project mainProject = Project("", "");
  String? selectedPlatform = "android";

  List<Project> projectList = [];

  @override
  void initState() {
    super.initState();
    mainProject = widget.project;
    fetchProjects();
  }

  void fetchProjects() {
    WJHttp().fetchProjectsV2().then((projectsResult) {
      setState(() {
        if(null != projectsResult){
          projectList.clear();
          for (var element in projectsResult.data) {
            if (element.projectId != mainProject.projectId) {
              projectList.add(element);
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "导出翻译",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.project.projectId,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Container(
              margin: const EdgeInsets.only(top: 20, bottom: 20),
              child: Row(
                children: [
                  const Text("请选择目标平台：  "),
                  Radio(
                      value: "android",
                      activeColor: Colors.blue,
                      groupValue: selectedPlatform,
                      onChanged: (selected) {
                        setState(() {
                          selectedPlatform = selected;
                        });
                      }),
                  const Text("android   "),
                  Radio(
                      value: "ios",
                      activeColor: Colors.blue,
                      groupValue: selectedPlatform,
                      onChanged: (selected) {
                        setState(() {
                          selectedPlatform = selected;
                        });
                      }),
                  const Text("ios   "),
                  const Text("  excel"),
                  Radio(
                      activeColor: Colors.blue,
                      value: "excel",
                      groupValue: selectedPlatform,
                      onChanged: (selected) {
                        setState(() {
                          selectedPlatform = selected;
                        });
                      })
                ],

              ),
            ),
            const Text("合并其他项目导出（可选）",),
            const Text("以主项目的语言为基准，主项目没有的语言翻译不会合并,excel暂不支持合并导出"),
            Expanded(
              child: ListView.builder(
                  itemCount: projectList.length,
                  itemBuilder: (context, index) {
                    return buildProjectItem(projectList[index]);
                  }),
            ),
            Container(
              margin: const EdgeInsets.only(top: 30),
              padding: const EdgeInsets.only(left: 30, top: 10, right: 30, bottom: 10),
              decoration: const BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.all(Radius.circular(30))),
              child: TextButton(
                  onPressed: () {
                    if(selectedPlatform == "excel"){
                      exportTranslationExcel();
                    }else {
                      exportTranslationRemote();
                    }
                  },
                  child: const Text(
                    "确认",
                    style: TextStyle(color: Colors.white),
                  )),
            )
          ],
        ),
      ),
    );
  }

  void exportTranslationExcel() {
    print("exportTranslationExcel");
    Excel excel = Excel.createExcel();
    String? defaultSheet = excel.getDefaultSheet();
    List<CellValue> titleRow = List.empty(growable: true);
    titleRow.add(const TextCellValue("Key"));
    for (int i = 0; i < widget.languageList.length; i++) {
      Language language = widget.languageList[i];
      CellValue cellValue = TextCellValue("${language.languageName}(${language.languageDes})");
      titleRow.add(cellValue);
    }
    excel.appendRow(defaultSheet ?? "Sheet1", titleRow);

    for (Module module in widget.modules) {
      Map<String, Map<int, Translation>>? translationListInModule = widget.translationRootMap[module.moduleId];
      if (null != translationListInModule) {
        var keys = translationListInModule.keys;
        for (String key in keys) {
          Map<int, Translation>? translationLanguageContentMap = translationListInModule[key];
          if (translationLanguageContentMap != null) {
            List<CellValue> contentRow = List.empty(growable: true);
            contentRow.add(TextCellValue(key));
            for (int i = 0; i < widget.languageList.length; i++) {
              Language language = widget.languageList[i];
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

  void exportTranslationRemote() {
    ExportTranslationParam exportTranslationParam = ExportTranslationParam();
    exportTranslationParam.platform = selectedPlatform;
    exportTranslationParam.projectIdList = [];
    exportTranslationParam.projectIdList?.add(mainProject.projectId);
    for (var element in selectedProject) {
      exportTranslationParam.projectIdList?.add(element.projectId);
    }

    WJHttp().exportTranslationZip2(exportTranslationParam).then((value) {
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
      print("export  end");
    });
  }

  List<Project> selectedProject = [];

  Widget buildProjectItem(Project project) {
    return Row(
      children: [
        Checkbox(
            checkColor: Colors.blue,
            value: selectedProject.contains(project),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  selectedProject.add(project);
                } else {
                  selectedProject.remove(project);
                }
              });
            }),
        Text(project.projectId)
      ],
    );
  }
}
