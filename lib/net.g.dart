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
      fromJsonDATA(json['data']),
    );

Map<String, dynamic> _$CommonResponseToJson<DATA>(
  CommonResponse<DATA> instance,
  Object? Function(DATA value) toJsonDATA,
) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': toJsonDATA(instance.data),
    };

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
      json['languageId'] as String,
      json['translationContent'] as String,
      json['projectId'] as String,
    );

Map<String, dynamic> _$TranslationToJson(Translation instance) =>
    <String, dynamic>{
      'translationKey': instance.translationKey,
      'languageId': instance.languageId,
      'translationContent': instance.translationContent,
      'projectId': instance.projectId,
    };

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      json['projectName'] as String,
      json['projectId'] as String,
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'projectName': instance.projectName,
      'projectId': instance.projectId,
    };

Language _$LanguageFromJson(Map<String, dynamic> json) => Language(
      json['languageId'] as String,
      json['languageName'] as String,
      json['projectId'] as String,
    );

Map<String, dynamic> _$LanguageToJson(Language instance) => <String, dynamic>{
      'languageId': instance.languageId,
      'languageName': instance.languageName,
      'projectId': instance.projectId,
    };
