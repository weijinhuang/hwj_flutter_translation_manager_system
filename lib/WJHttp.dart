import 'dart:convert';
import 'dart:math';

import 'package:hwj_translation_flutter/net.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';

class WJHttp {
  String baiduScreat = "kab0xQelR7tGlmlpWR5o";

  String ip = "172.16.26.46";

  Future<http.Response> exportTranslationZip(String projectId, String platform) async {
    final response = await http.get(Uri.parse("http://$ip:80/exportTranslation/$projectId/$platform"),
        headers: <String, String>{"Access-Control-Allow-Origin": "*", 'Content-Type': 'application/octet-stream', 'Accept': '*/*'});
    return response;
  }

  Future<CommonResponse<ThirdPartyTranslationResult?>> translateByGoogle(String sourceContent, String sourceLanguage, String targetLanguage) async {
    GoogleTranslationParam translationParam = GoogleTranslationParam(sourceLanguage, targetLanguage, sourceContent);

    final response = await http.post(Uri.parse("http://$ip:80/translateByGoogle"),
        headers: <String, String>{"Access-Control-Allow-Origin": "*", 'Content-Type': 'application/json; charset=UTF-8', 'Accept': '*/*'}, body: jsonEncode(translationParam.toJson()));
    print("translateByGoogle${response.body}");
    if (response.statusCode == 200) {
      return CommonResponse<ThirdPartyTranslationResult?>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) {
        if (json != null) {
          return ThirdPartyTranslationResult.fromJson(json);
        } else {
          return null;
        }
      });
    } else {
      return CommonResponse(-1, "", null);
    }
  }

  Future<CommonResponse<ThirdPartyTranslationResult?>> translateByBaidu(String sourceContent, String from, String to) async {
    var salt = Random().nextInt(100000).toString();
    var str = "20231209001905732$sourceContent$salt$baiduScreat";

    var content = Utf8Encoder().convert(str);
    var md5Str = hex.encode(md5.convert(content).bytes);
    print("MD5:$md5Str");
    BaiduTranslationParam translationParam = BaiduTranslationParam(sourceContent, from, to, "20231209001905732", salt, md5Str);
    translationParam.sign = md5Str;
    final response = await http.post(Uri.parse("http://$ip:80/translateByBaidu2"),
        headers: <String, String>{"Access-Control-Allow-Origin": "*", 'Content-Type': 'application/json; charset=UTF-8', 'Accept': '*/*'}, body: jsonEncode(translationParam.toJson()));
    print("translateByBaidu${response.body}");
    if (response.statusCode == 200) {
      return CommonResponse<ThirdPartyTranslationResult?>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) {
        if (json != null) {
          return ThirdPartyTranslationResult.fromJson(json);
        } else {
          return null;
        }
      });
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonListResponse<Translation>> fetchTranslation(String projectId, {int? moduleId}) async {
    Map<String, dynamic> params;
    if (moduleId == null) {
      params = {'projectId': projectId};
    } else {
      params = {'projectId': projectId, 'moduleId': moduleId};
    }
    final response = await http.post(Uri.parse("http://$ip:80/getAllTranslation"),
        headers: <String, String>{"Access-Control-Allow-Origin": "*", 'Content-Type': 'application/json; charset=UTF-8', 'Accept': '*/*'}, body: jsonEncode(params));
    // print("拉取翻译列表${response.body}");
    if (response.statusCode == 200) {
      return CommonListResponse<Translation>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) => Translation.fromJson(json));
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonListResponse<Project>> fetchProjects() async {
    final response = await http.get(Uri.parse("http://$ip:80/getAllProjects"));
    print(response.body);
    if (response.statusCode == 200) {
      return CommonListResponse<Project>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) => Project.fromJson(json));
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonResponse<void>> addProject(Project project) async {
    print("addProject");
    final response = await http.post(Uri.parse("http://$ip:80/addProject"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(project.toJson()));
    if (response.statusCode == 200) {
      return CommonResponse<void>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) {});
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonResponse<void>> deleteProject(Project project) async {
    print("deleteProject");
    final response = await http.post(Uri.parse("http://$ip:80/deleteProject"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(project.toJson()));
    if (response.statusCode == 200) {
      return CommonResponse<void>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) {});
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonResponse<void>> addLanguage(Language language) async {
    print("addLanguage");
    final response = await http.post(Uri.parse("http://$ip:80/addLanguage"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(language.toJson()));
    if (response.statusCode == 200) {
      return CommonResponse<void>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) {});
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonListResponse<Language>> addLanguages(List<Language> translation) async {
    String json = jsonEncode(translation.map((e) => e.toJson()).toList(growable: false));
    print("添加语言列表:$json");
    final response = await http.post(Uri.parse("http://$ip:80/addLanguages"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json);
    if (response.statusCode == 200) {
      return CommonListResponse<Language>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) {
        return Language.fromJson(json);
      });
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonResponse<void>> addModule(Module module) async {
    print("addLanguage");
    final response = await http.post(Uri.parse("http://$ip:80/addModule"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(module.toJson()));
    if (response.statusCode == 200) {
      return CommonResponse<void>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) {});
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonResponse<void>> deleteLanguage(Language language) async {
    print("deleteLanguage");
    final response = await http.post(Uri.parse("http://$ip:80/deleteLanguage"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(language.toJson()));
    if (response.statusCode == 200) {
      return CommonResponse<void>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) {});
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonResponse<void>> deleteModule(Module module) async {
    print("deleteModule");
    final response = await http.post(Uri.parse("http://$ip:80/deleteModule"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(module.toJson()));
    if (response.statusCode == 200) {
      return CommonResponse<void>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) {});
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonListResponse<Language>> fetchLanguageList(String projectId) async {
    final response = await http.get(Uri.parse("http://$ip:80/getLanguageList/$projectId"));
    print("查询语言列表${response.body}");
    if (response.statusCode == 200) {
      return CommonListResponse<Language>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) => Language.fromJson(json));
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonListResponse<Module>> fetchModuleList(String projectId) async {
    final response = await http.get(Uri.parse("http://$ip:80/getAllModules/$projectId"));
    print("查询Module列表${response.body}");
    if (response.statusCode == 200) {
      return CommonListResponse<Module>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) => Module.fromJson(json));
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonResponse<void>> addTranslation(Translation translation) async {
    print("添加翻译");
    final response = await http.post(Uri.parse("http://$ip:80/addTranslation"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(translation.toJson()));
    if (response.statusCode == 200) {
      return CommonResponse<void>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) {});
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonListResponse<Translation>> addTranslations(List<Translation> translation) async {
    String json = jsonEncode(translation.map((e) => e.toJson()).toList(growable: false));
    print("添加翻译列表:$json");
    final response = await http.post(Uri.parse("http://$ip:80/addTranslations"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json);
    if (response.statusCode == 200) {
      return CommonListResponse<Translation>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) {
        return Translation.fromJson(json);
      });
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonListResponse<Translation>> updateTranslations(List<Translation> translation) async {
    String json = jsonEncode(translation.map((e) => e.toJson()).toList(growable: false));
    print("添加翻译列表:$json");
    final response = await http.post(Uri.parse("http://$ip:80/updateTranslations"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json);
    if (response.statusCode == 200) {
      return CommonListResponse<Translation>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) {
        return Translation.fromJson(json);
      });
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonResponse<void>> deleteTranslationByKey(String translationKey, String projectId) async {
    print("删除翻译");
    final response = await http.post(Uri.parse("http://$ip:80/deleteTranslationByKey"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"translationKey": translationKey, "projectId": projectId}));
    if (response.statusCode == 200) {
      return CommonResponse<void>.fromJson(jsonDecode(utf8.decode(response.bodyBytes)), (json) {});
    } else {
      throw Exception("net error");
    }
  }
}
