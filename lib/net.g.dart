// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommonResponse<DATA> _$CommonResponseFromJson<DATA>(
  Map<String, dynamic> json,
  DATA Function(Object? json) fromJsonDATA,
) =>
    CommonResponse<DATA>(
      json['code'] as int,
      json['msg'] as String,
      _$nullableGenericFromJson(json['data'], fromJsonDATA),
    );

Map<String, dynamic> _$CommonResponseToJson<DATA>(
  CommonResponse<DATA> instance,
  Object? Function(DATA value) toJsonDATA,
) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': _$nullableGenericToJson(instance.data, toJsonDATA),
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

CommonListResponse<DATA> _$CommonListResponseFromJson<DATA>(
  Map<String, dynamic> json,
  DATA Function(Object? json) fromJsonDATA,
) =>
    CommonListResponse<DATA>(
      json['code'] as int,
      json['msg'] as String?,
      (json['data'] as List<dynamic>).map(fromJsonDATA).toList(),
    );

Map<String, dynamic> _$CommonListResponseToJson<DATA>(
  CommonListResponse<DATA> instance,
  Object? Function(DATA value) toJsonDATA,
) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data.map(toJsonDATA).toList(),
    };

Translation _$TranslationFromJson(Map<String, dynamic> json) => Translation(
      json['translationKey'] as String,
      json['languageId'] as int,
      json['translationContent'] as String,
      json['projectId'] as String,
      translationId: json['translationId'] as int?,
      moduleId: json['moduleId'] as int?,
      forceAdd: json['forceAdd'] as bool?,
      oldTranslationContent: json['oldTranslationContent'] as String?,
      comment: json['comment'] as String?,
    )..selectedTranslationContent =
        json['selectedTranslationContent'] as String?;

Map<String, dynamic> _$TranslationToJson(Translation instance) =>
    <String, dynamic>{
      'translationId': instance.translationId,
      'translationKey': instance.translationKey,
      'languageId': instance.languageId,
      'translationContent': instance.translationContent,
      'projectId': instance.projectId,
      'moduleId': instance.moduleId,
      'forceAdd': instance.forceAdd,
      'oldTranslationContent': instance.oldTranslationContent,
      'selectedTranslationContent': instance.selectedTranslationContent,
      'comment': instance.comment,
    };

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      json['projectName'] as String?,
      json['projectId'] as String,
    )..copyFromProject = json['copyFromProject'] as String?;

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'projectName': instance.projectName,
      'projectId': instance.projectId,
      'copyFromProject': instance.copyFromProject,
    };

Language _$LanguageFromJson(Map<String, dynamic> json) => Language(
      json['languageName'] as String,
      json['languageDes'] as String,
      json['projectId'] as String,
      languageId: json['languageId'] as int?,
    )..color = json['color'] as int?;

Map<String, dynamic> _$LanguageToJson(Language instance) => <String, dynamic>{
      'languageId': instance.languageId,
      'languageName': instance.languageName,
      'languageDes': instance.languageDes,
      'projectId': instance.projectId,
      'color': instance.color,
    };

Module _$ModuleFromJson(Map<String, dynamic> json) => Module(
      json['moduleName'] as String,
      json['projectId'] as String,
      moduleId: json['moduleId'] as int?,
    );

Map<String, dynamic> _$ModuleToJson(Module instance) => <String, dynamic>{
      'moduleId': instance.moduleId,
      'moduleName': instance.moduleName,
      'projectId': instance.projectId,
    };

BaiduTranslationParam _$BaiduTranslationParamFromJson(
        Map<String, dynamic> json) =>
    BaiduTranslationParam(
      json['q'] as String,
      json['from'] as String,
      json['to'] as String,
      json['appid'] as String,
      json['salt'] as String,
      json['sign'] as String,
    );

Map<String, dynamic> _$BaiduTranslationParamToJson(
        BaiduTranslationParam instance) =>
    <String, dynamic>{
      'q': instance.q,
      'from': instance.from,
      'to': instance.to,
      'appid': instance.appid,
      'salt': instance.salt,
      'sign': instance.sign,
    };

BaiduTranslationResult _$BaiduTranslationResultFromJson(
        Map<String, dynamic> json) =>
    BaiduTranslationResult(
      json['from'] as String?,
      json['to'] as String?,
      (json['trans_result'] as List<dynamic>)
          .map((e) => e == null
              ? null
              : BaiduTranslation.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['error_code'] as String?,
    );

Map<String, dynamic> _$BaiduTranslationResultToJson(
        BaiduTranslationResult instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'trans_result': instance.trans_result.map((e) => e?.toJson()).toList(),
      'error_code': instance.error_code,
    };

ThirdPartyTranslationResult _$ThirdPartyTranslationResultFromJson(
        Map<String, dynamic> json) =>
    ThirdPartyTranslationResult(
      json['sourceLanguage'] as String?,
      json['targetLanguage'] as String?,
      json['transResult'] as String?,
      json['errorCode'] as int?,
    );

Map<String, dynamic> _$ThirdPartyTranslationResultToJson(
        ThirdPartyTranslationResult instance) =>
    <String, dynamic>{
      'sourceLanguage': instance.sourceLanguage,
      'targetLanguage': instance.targetLanguage,
      'transResult': instance.transResult,
      'errorCode': instance.errorCode,
    };

GoogleTranslationParam _$GoogleTranslationParamFromJson(
        Map<String, dynamic> json) =>
    GoogleTranslationParam(
      json['sourceLanguage'] as String?,
      json['targetLanguage'] as String?,
      json['content'] as String?,
    );

Map<String, dynamic> _$GoogleTranslationParamToJson(
        GoogleTranslationParam instance) =>
    <String, dynamic>{
      'sourceLanguage': instance.sourceLanguage,
      'targetLanguage': instance.targetLanguage,
      'content': instance.content,
    };

BaiduTranslation _$BaiduTranslationFromJson(Map<String, dynamic> json) =>
    BaiduTranslation()
      ..src = json['src'] as String?
      ..dst = json['dst'] as String?;

Map<String, dynamic> _$BaiduTranslationToJson(BaiduTranslation instance) =>
    <String, dynamic>{
      'src': instance.src,
      'dst': instance.dst,
    };

ExportTranslationParam _$ExportTranslationParamFromJson(
        Map<String, dynamic> json) =>
    ExportTranslationParam()
      ..projectIdList = (json['projectIdList'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList()
      ..platform = json['platform'] as String?;

Map<String, dynamic> _$ExportTranslationParamToJson(
        ExportTranslationParam instance) =>
    <String, dynamic>{
      'projectIdList': instance.projectIdList,
      'platform': instance.platform,
    };

MergeTranslationParam _$MergeTranslationParamFromJson(
        Map<String, dynamic> json) =>
    MergeTranslationParam(
      json['projectId'] as String,
      json['mainTranslationKey'] as String,
      (json['translationToBeHideKeyList'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MergeTranslationParamToJson(
        MergeTranslationParam instance) =>
    <String, dynamic>{
      'projectId': instance.projectId,
      'mainTranslationKey': instance.mainTranslationKey,
      'translationToBeHideKeyList': instance.translationToBeHideKeyList,
    };
