import 'dart:convert';
import 'dart:math';

import 'package:hwj_translation_flutter/net.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';

class WJHttp {
  String baiduScreat = "kab0xQelR7tGlmlpWR5o";

  // String ip = "172.16.21.156";
  String ip = "192.168.3.168";

  Future<Map<String, dynamic>> sendRequest<PARAM, DATA>(CommonParam<PARAM> param) async {
    var dataJson = param.toJson();
    print("Request:http://$ip:80/translationSystem \n$dataJson");
    final response = await http.post(Uri.parse("http://$ip:80/translationSystem"),
        headers: <String, String>{"Access-Control-Allow-Origin": "*", 'Content-Type': 'application/json; charset=UTF-8', 'Accept': '*/*'}, body: jsonEncode(dataJson));
    print("response:${param.cmd}:${response.body}");
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("net error");
    }
  }

  Future<CommonResponse<void>> mergeTranslation(String mainTranslationKey, List<String> deleteTranslationKeyList, String projectId) async {
    MergeTranslationParam param = MergeTranslationParam(projectId, mainTranslationKey, deleteTranslationKeyList);
    CommonParam commonParam = CommonParam("mergeTranslation", data: param.toJson());
    return sendRequest(commonParam).then((value) => CommonResponse.fromJson(value, (json) {}));
  }

  Future<CommonListResponse<Project>?> fetchProjectsV2() async {
    CommonParam commonParam = CommonParam("getAllProjects");
    return sendRequest(commonParam).then((value) => CommonListResponse.fromJson(value, (json) => Project.fromJson(json)));
  }

  Future<CommonResponse<ThirdPartyTranslationResult?>> translateByGoogleV2(String sourceContent, String sourceLanguage, String targetLanguage) async {
    GoogleTranslationParam translationParam = GoogleTranslationParam(sourceLanguage, targetLanguage, sourceContent);
    CommonParam commonParam = CommonParam("translateByGoogle", data: translationParam.toJson());
    return sendRequest(commonParam).then((value) {
      return CommonResponse.fromJson(value, (json) {
        if (null != json) {
          return ThirdPartyTranslationResult.fromJson(json);
        } else {
          return null;
        }
      });
    });
  }

  Future<http.Response> exportTranslationZip2(ExportTranslationParam exportTranslationParam) async {
    final response = await http.post(Uri.parse("http://$ip:80/exportTranslation2"),
        headers: <String, String>{"Access-Control-Allow-Origin": "*", 'Content-Type': 'application/json; charset=UTF-8', 'Accept': '*/*'}, body: jsonEncode(exportTranslationParam.toJson()));
    return response;
  }

  Future<http.Response> exportTranslationZip(String projectId, String platform) async {
    final response = await http.get(Uri.parse("http://$ip:80/exportTranslation/$projectId/$platform"),
        headers: <String, String>{"Access-Control-Allow-Origin": "*", 'Content-Type': 'application/octet-stream', 'Accept': '*/*'});
    return response;
  }

  Future<CommonResponse<ThirdPartyTranslationResult?>> translateByBaiduV2(String sourceContent, String from, String to) async {
    var salt = Random().nextInt(100000).toString();
    var str = "20231209001905732$sourceContent$salt$baiduScreat";
    var content = Utf8Encoder().convert(str);
    var md5Str = hex.encode(md5.convert(content).bytes);
    print("MD5:$md5Str");
    BaiduTranslationParam translationParam = BaiduTranslationParam(sourceContent, from, to, "20231209001905732", salt, md5Str);
    translationParam.sign = md5Str;

    CommonParam commonParam = CommonParam("translateByBaidu", data: translationParam.toJson());

    return sendRequest(commonParam).then((value) {
      return CommonResponse.fromJson(value, (json) => ThirdPartyTranslationResult.fromJson(json));
    });
  }

  Future<CommonResponse<void>> deleteTranslationByKeyV2(String translationKey, String projectId) async {
    print("删除翻译");
    var params = {"translationKey": translationKey, "projectId": projectId};
    CommonParam commonParam = CommonParam("deleteTranslationByKey", data: params);
    return sendRequest(commonParam).then((value) => CommonResponse.fromJson(value, (json) {}));
  }

  Future<CommonListResponse<Language>> fetchLanguageListV2(String projectId) async {
    Map<String, String> params = {'projectId': projectId};

    CommonParam commonParam = CommonParam("getLanguageList", data: params);
    return sendRequest(commonParam).then((value) => CommonListResponse.fromJson(value, (json) => Language.fromJson(json)));
  }

  Future<CommonListResponse<Translation>> fetchTranslationV2(String projectId, {int? moduleId}) async {
    Map<String, dynamic> params;
    if (moduleId == null) {
      params = {'projectId': projectId};
    } else {
      params = {'projectId': projectId, 'moduleId': moduleId};
    }
    CommonParam commonParam = CommonParam("getAllTranslation", data: params);
    return sendRequest(commonParam).then((value) => CommonListResponse.fromJson(value, (json) => Translation.fromJson(json)));
  }

  Future<CommonResponse<void>> addProjectV2(Project project) async {
    CommonParam commonParam = CommonParam("addProject", data: project.toJson());
    return sendRequest(commonParam).then((value) {
      return CommonResponse.fromJson(value, (json) {});
    });
  }

  Future<CommonResponse<void>> deleteProjectV2(Project project) async {
    CommonParam commonParam = CommonParam("deleteProject", data: project.toJson());
    return sendRequest(commonParam).then((value) {
      return CommonResponse.fromJson(value, (json) {});
    });
  }

  Future<CommonResponse<void>> addModuleV2(Module module) async {
    CommonParam commonParam = CommonParam("addModule", data: module.toJson());
    return sendRequest(commonParam).then((value) {
      return CommonResponse.fromJson(value, (json) {});
    });
  }

  Future<CommonResponse<void>> deleteLanguageV2(Language language) async {
    CommonParam commonParam = CommonParam("deleteLanguage", data: language.toJson());
    return sendRequest(commonParam).then((value) {
      return CommonResponse.fromJson(value, (json) {});
    });
  }

  Future<CommonResponse<void>> deleteModuleV2(Module module) async {
    CommonParam commonParam = CommonParam("deleteModule", data: module.toJson());
    return sendRequest(commonParam).then((value) {
      return CommonResponse.fromJson(value, (json) {});
    });
  }

  Future<CommonListResponse<Module>> fetchModuleListV2(String projectId) async {
    CommonParam commonParam = CommonParam("getAllModules", data: projectId);
    return sendRequest(commonParam).then((value) {
      return CommonListResponse<Module>.fromJson(value, (json) => Module.fromJson(json));
    });
  }

  Future<CommonListResponse<Language>> addLanguagesV2(List<Language> languageList) async {
    var json = languageList.map((e) => e.toJson()).toList(growable: false);
    CommonParam commonParam = CommonParam("addLanguages", data: json);
    return sendRequest(commonParam).then((value) => CommonListResponse<Language>.fromJson(value, (json) {
          return Language.fromJson(json);
        }));
  }

  Future<CommonListResponse<Language>> updateLanguagesV2(List<Language> languageList) async {
    var json = languageList.map((e) => e.toJson()).toList(growable: false);
    CommonParam commonParam = CommonParam("updateLanguages", data: json);
    return sendRequest(commonParam).then((value) => CommonListResponse<Language>.fromJson(value, (json) {
          return Language.fromJson(json);
        }));
  }

  Future<CommonListResponse<Translation>> addTranslationsV2(List<Translation> translation) async {
    var json = translation.map((e) => e.toJson()).toList(growable: false);
    CommonParam commonParam = CommonParam("addTranslations", data: json);
    // return sendRequest(commonParam).then((value) => CommonListResponse<Translation>.fromJson(value, (json) => Translation.fromJson(json)));
    return sendRequest(commonParam).then((value) {
      return CommonListResponse<Translation>.fromJson(value, (json) {
        return Translation.fromJson(json);
      });
    });
  }

  Future<CommonResponse<void>> addTranslationsV3(List<Translation> translation) async {
    var json = translation.map((e) => e.toJson()).toList(growable: false);
    CommonParam commonParam = CommonParam("batchAddTranslation", data: json);
    // return sendRequest(commonParam).then((value) => CommonListResponse<Translation>.fromJson(value, (json) => Translation.fromJson(json)));
    return sendRequest(commonParam).then((value) {
      return CommonResponse.fromJson(value, (json) {});
    });
  }

  Future<CommonListResponse<Translation>> updateTranslationsV2(List<Translation> translation) async {
    var json = translation.map((e) => e.toJson()).toList(growable: false);
    CommonParam commonParam = CommonParam("updateTranslations", data: json);
    return sendRequest(commonParam).then((value) => CommonListResponse<Translation>.fromJson(value, (json) => Translation.fromJson(json)));
  }

  Future<CommonResponse<int?>> checkTranslationKey(CheckTranslationKeEnableParam param) async {
    var json = param.toJson();
    CommonParam commonParam = CommonParam("checkTranslationKey", data: json);
    return sendRequest(commonParam).then((value) => CommonResponse.fromJson(value, (json) => json as int));
  }
}
