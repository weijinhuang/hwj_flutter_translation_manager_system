import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'net.g.dart';

/**
    flutter pub run build_runner build --delete-conflicting-outputs
 * */

class CommonParam<DATA> {
  String cmd;
  Object? data;

  CommonParam(this.cmd, {this.data});

  Map<String, dynamic> toJson() => _$CommonParamToJson(this, data);
}

Map<String, dynamic> _$CommonParamToJson<DATA>(
  CommonParam<DATA> instance,
  Object? data,
) =>
    <String, dynamic>{
      'cmd': instance.cmd,
      'data': data,
    };

@JsonSerializable(genericArgumentFactories: true)
class CommonResponse<DATA> {
  int code;
  String msg;
  DATA? data;

  CommonResponse(this.code, this.msg, this.data);

  factory CommonResponse.fromJson(
    Map<String, dynamic> json,
    DATA Function(dynamic json) fromJsonDATA,
  ) =>
      _$CommonResponseFromJson<DATA>(json, fromJsonDATA);

  Map<String, dynamic> toJson(Object? Function(DATA data) toJsonDATA) => _$CommonResponseToJson(this, toJsonDATA);
}

@JsonSerializable(genericArgumentFactories: true)
class CommonListResponse<DATA> {
  int code;
  String? msg;
  List<DATA> data;

  CommonListResponse(this.code, this.msg, this.data);

  factory CommonListResponse.fromJson(
    Map<String, dynamic> json,
    DATA Function(dynamic json) fromJsonDATA,
  ) =>
      _$CommonListResponseFromJson<DATA>(json, fromJsonDATA);

  Map<String, dynamic> toJson(Object? Function(DATA data) toJsonDATA) => _$CommonListResponseToJson(this, toJsonDATA);
}

@JsonSerializable()
class Translation {
  int? translationId;
  String translationKey;
  int languageId;
  String translationContent;
  String projectId;
  int? moduleId;
  bool? forceAdd = false;
  String? oldTranslationContent;
  String? selectedTranslationContent;
  String? comment;
  int? ratio = 0;

  Translation(this.translationKey, this.languageId, this.translationContent, this.projectId, {this.translationId, this.moduleId, this.forceAdd, this.oldTranslationContent, this.comment,this.ratio});

  factory Translation.fromJson(Map<String, dynamic> json) => _$TranslationFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationToJson(this);

  @override
  String toString() {
    return 'Translation{translationId: $translationId, translationKey: $translationKey, languageId: $languageId, translationContent: $translationContent, projectId: $projectId, moduleId: $moduleId, forceAdd: $forceAdd, oldTranslationContent: $oldTranslationContent, selectedTranslationContent: $selectedTranslationContent}';
  }
}

@JsonSerializable()
class Project {
  String? projectName;
  String projectId;
  String? copyFromProject;

  Project(this.projectName, this.projectId);

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

@JsonSerializable()
class Language {
  int? languageId;
  String languageName;
  String languageDes;
  String projectId;
  int? color = Colors.white.value;
  int? languageOrder = 0;

  Language(this.languageName, this.languageDes, this.projectId, {this.languageId,this.languageOrder});

  factory Language.fromJson(Map<String, dynamic> json) => _$LanguageFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageToJson(this);

  @override
  String toString() {
    return "$languageName($languageDes)";
  }
}

@JsonSerializable()
class Module {
  int? moduleId;

  String moduleName;

  String projectId;

  Module(this.moduleName, this.projectId, {this.moduleId});

  factory Module.fromJson(Map<String, dynamic> json) => _$ModuleFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleToJson(this);
}

@JsonSerializable()
class BaiduTranslationParam {
  String q;
  String from;
  String to;
  String appid = "20231209001905732";
  String salt;
  String sign;

  BaiduTranslationParam(this.q, this.from, this.to, this.appid, this.salt, this.sign);

  factory BaiduTranslationParam.fromJson(Map<String, dynamic> json) => _$BaiduTranslationParamFromJson(json);

  Map<String, dynamic> toJson() => _$BaiduTranslationParamToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BaiduTranslationResult {
  String? from;
  String? to;
  List<BaiduTranslation?> trans_result;
  String? error_code;

  BaiduTranslationResult(this.from, this.to, this.trans_result, this.error_code);

  factory BaiduTranslationResult.fromJson(Map<String, dynamic> json) => _$BaiduTranslationResultFromJson(json);

  Map<String, dynamic> toJson() => _$BaiduTranslationResultToJson(this);
}

@JsonSerializable()
class ThirdPartyTranslationResult {
  String? sourceLanguage;
  String? targetLanguage;
  String? transResult;
  int? errorCode;

  ThirdPartyTranslationResult(this.sourceLanguage, this.targetLanguage, this.transResult, this.errorCode);

  factory ThirdPartyTranslationResult.fromJson(Map<String, dynamic> json) => _$ThirdPartyTranslationResultFromJson(json);

  Map<String, dynamic> toJson() => _$ThirdPartyTranslationResultToJson(this);
}

@JsonSerializable()
class GoogleTranslationParam {
  String? sourceLanguage;
  String? targetLanguage;
  String? content;

  GoogleTranslationParam(this.sourceLanguage, this.targetLanguage, this.content);

  factory GoogleTranslationParam.fromJson(Map<String, dynamic> json) => _$GoogleTranslationParamFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleTranslationParamToJson(this);
}

@JsonSerializable()
class BaiduTranslation {
  String? src;

  String? dst;

  BaiduTranslation();

  factory BaiduTranslation.fromJson(Map<String, dynamic> json) => _$BaiduTranslationFromJson(json);

  Map<String, dynamic> toJson() => _$BaiduTranslationToJson(this);
}

@JsonSerializable()
class ExportTranslationParam {
  List<String>? projectIdList;

  String? platform;

  ExportTranslationParam();

  factory ExportTranslationParam.fromJson(Map<String, dynamic> json) => _$ExportTranslationParamFromJson(json);

  Map<String, dynamic> toJson() => _$ExportTranslationParamToJson(this);
}

@JsonSerializable()
class MergeTranslationParam {
  String projectId;
  String mainTranslationKey;
  List<String> translationToBeHideKeyList;

  MergeTranslationParam(this.projectId, this.mainTranslationKey, this.translationToBeHideKeyList);

  factory MergeTranslationParam.fromJson(Map<String, dynamic> json) => _$MergeTranslationParamFromJson(json);

  Map<String, dynamic> toJson() => _$MergeTranslationParamToJson(this);
}
