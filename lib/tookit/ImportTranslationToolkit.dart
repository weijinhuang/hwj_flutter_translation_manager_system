import 'dart:convert';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'package:hwj_translation_flutter/net.dart';
import 'package:file_picker/file_picker.dart';
import 'package:xml/xml.dart';
import 'package:excel/excel.dart';

class ImportTranslationToolkit {
  Future<CommonListResponse<Translation>> importAndroid(Language language, int moduleId) async {
    print("导入Android翻译");
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      final fileBytes = result.files.first.bytes;
      String xmlString;
      if (null != fileBytes) {
        xmlString = utf8.decode(fileBytes);
      } else {
        return CommonListResponse(-1, "解析文件失败", []);
      }
      var xmlDocument = XmlDocument.parse(xmlString);

      List<Translation> translations = [];
      for (var element in xmlDocument.childElements) {
        var elementName = element.name.toXmlString();
        // print(elementName);
        if (elementName == "resources") {
          for (var childElement in element.childElements) {
            var childElementName = childElement.name.toXmlString();
            // print(childElementName);
            if (childElementName == "string") {
              String languageKey = childElement.attributes.first.value;
              String translationContent = childElement.innerText;
              // print("$languageKey:$translationContent");
              Translation translation = Translation(languageKey, language.languageId ?? 0, translationContent, language.projectId, moduleId: moduleId, forceAdd: false);
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
              Translation translation = Translation(languageKey, language.languageId ?? 0, translationContent, language.projectId, moduleId: moduleId, forceAdd: false);
              translations.add(translation);
            }
          }
        }
      }
      return await WJHttp().addTranslationsV2(translations);
    } else {
      return CommonListResponse(-1, "未选择文件", []);
    }
  }

  Future<CommonListResponse<Translation>> importIOS(Language language, int moduleId) async {
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
            var key = kv[0].trim();
            key = key.substring(1, key.length - 1);
            var value = kv[1].trim();
            var lastIndex = value.lastIndexOf(";");
            if (lastIndex != -1) {
              value = value.substring(0, lastIndex);
            }
            value = value.substring(1, value.length - 1);
            Translation translation = Translation(key, language.languageId ?? 0, value, language.projectId, moduleId: moduleId, forceAdd: false);
            translations.add(translation);
          }
        }
        return await WJHttp().addTranslationsV2(translations);
      } else {
        return CommonListResponse(-1, "文件解析出错", []);
      }
    } else {
      return CommonListResponse(-1, "未选择文件", []);
    }
  }

  Future<CommonListResponse<Translation>> importExcel(List<Language> localLanguageList, String projectId, int moduleId) async {
    String? key;
    List<Translation> translationList = [];
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      var bytes = result.files.first.bytes;
      if (null != bytes) {
        Excel excel = Excel.decodeBytes(bytes);
        var sheets = excel.sheets;
        if (sheets.isNotEmpty) {
          var firstSheet = sheets.values.first;
          if (firstSheet.maxRows > 0) {
            var firstRow = firstSheet.rows.first;
            //解析语言
            List<Language> excelLanguageList = [];
            for (int firstRowPos = 1; firstRowPos < firstRow.length; firstRowPos++) {
              var firstRowElement = firstRow.elementAt(firstRowPos);
              if (null != firstRowElement) {
                var languageStr = firstRowElement.value?.toString();
                if (null != languageStr) {
                  var languageNameSplit = languageStr.split("(");
                  var languageName = languageNameSplit[0];
                  var languageDes = languageNameSplit[1];
                  Language language = Language(languageName, languageDes, projectId);
                  excelLanguageList.add(language);
                }
              }
            }
            if (excelLanguageList.isNotEmpty) {
              var result = await WJHttp().addLanguagesV2(excelLanguageList);
              if (result.code == 200 && result.data.isNotEmpty) {
                for (int i = 1; i < firstSheet.maxRows; i++) {
                  var row = firstSheet.row(i);
                  key = row.first?.value.toString();
                  if (key != null && key.isNotEmpty) {
                    for (int rowPos = 1; rowPos < row.length; rowPos++) {
                      if (rowPos - 1 < result.data.length) {
                        Language language = result.data[rowPos - 1];
                        String? translationContent = row.elementAt(rowPos)?.value.toString();
                        int? languageId = language.languageId;
                        if (translationContent != null && languageId != null) {
                          Translation translation = Translation(key, languageId, translationContent, projectId, moduleId: moduleId);
                          translationList.add(translation);
                        }
                      }
                    }
                  }
                }
              } else {
                print("添加语言失败：${result.msg}");
                return CommonListResponse(-1, result.msg, []);
              }
            } else {
              return CommonListResponse(-1, "文件解析出错，未解析到语言", []);
            }
          }
        }
        if (translationList.isNotEmpty) {
          var commonListResponse = await WJHttp().addTranslationsV2(translationList);
          return commonListResponse;
        } else {
          return CommonListResponse(-1, "未解析到翻译", []);
        }
      } else {
        return CommonListResponse(-1, "文件解析出错", []);
      }
    } else {
      return CommonListResponse(-1, "未选择文件", []);
    }
  }
}
