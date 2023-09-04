import 'dart:convert';

import 'package:hwj_translation_flutter/net.dart';
import 'package:http/http.dart' as http;

class WJHttp {
  Future<CommonListResponse<Translation>> fetchTranslation(
      String projectId) async {
    final response = await http.get(Uri.parse("http://192.168.3"
        ".240:8080/getAllTranslation/$projectId"));
    print("拉取翻译列表${response.body}");
    if (response.statusCode == 200) {
      return CommonListResponse<Translation>.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
          (json) => Translation.fromJson(json));
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonListResponse<Project>> fetchProjects() async {
    final response = await http.get(Uri.parse("http://192.168.3"
        ".240:8080/getAllProjects"));
    print(response.body);
    if (response.statusCode == 200) {
      return CommonListResponse<Project>.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
          (json) => Project.fromJson(json));
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonResponse<void>> addProject(Project project) async {
    print("addProject");
    final response = await http.post(
        Uri.parse("http://192.168.3"
            ".240:8080/addProject"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(project.toJson()));
    if (response.statusCode == 200) {
      return CommonResponse<void>.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)), (json) {});
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonResponse<void>> addLanguage(Language language) async {
    print("addLanguage");
    final response = await http.post(
        Uri.parse("http://192.168.3"
            ".240:8080/addLanguage"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(language.toJson()));
    if (response.statusCode == 200) {
      return CommonResponse<void>.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)), (json) {});
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonResponse<void>> deleteLanguage(Language language) async {
    print("deleteLanguage");
    final response = await http.post(
        Uri.parse("http://192.168.3"
            ".240:8080/deleteLanguage"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(language.toJson()));
    if (response.statusCode == 200) {
      return CommonResponse<void>.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)), (json) {});
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonListResponse<Language>> fetchLanguageList(
      String projectId) async {
    final response = await http.get(Uri.parse("http://192.168.3"
        ".240:8080/getLanguageList/$projectId"));
    print("查询语言列表${response.body}");
    if (response.statusCode == 200) {
      return CommonListResponse<Language>.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
          (json) => Language.fromJson(json));
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonResponse<void>> addTranslation(Translation translation) async {
    print("添加翻译");
    final response = await http.post(
        Uri.parse("http://192.168.3"
            ".240:8080/addTranslation"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(translation.toJson()));
    if (response.statusCode == 200) {
      return CommonResponse<void>.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)), (json) {});
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonListResponse<Translation>> addTranslations(
      List<Translation> translation) async {
    String json =
        jsonEncode(translation.map((e) => e.toJson()).toList(growable: false));
    print("添加翻译列表:$json");
    final response = await http.post(
        Uri.parse("http://192.168.3"
            ".240:8080/addTranslations"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json);
    if (response.statusCode == 200) {
      return CommonListResponse<Translation>.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)), (json) {
        return Translation.fromJson(json);
      });
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonResponse<void>> deleteTranslationByKey(
      String translationKey, String projectId) async {
    print("删除翻译");
    Translation translation = Translation(
        translationKey,
        "languageId",
        "tran"
            "slationContent",
        projectId);
    final response = await http.post(
        Uri.parse("http://192.168.3"
            ".240:8080/deleteTranslationByKey"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(translation.toJson()));
    if (response.statusCode == 200) {
      return CommonResponse<void>.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)), (json) {});
    } else {
      throw Exception("net error");
    }
  }
}
