import 'package:json_annotation/json_annotation.dart';

part 'net.g.dart';

/**
    flutter pub run build_runner build --delete-conflicting-outputs
 * */

@JsonSerializable(genericArgumentFactories: true)
class CommonResponse<DATA> {
  int code;
  String msg;
  DATA data;

  CommonResponse(this.code, this.msg, this.data);

  factory CommonResponse.fromJson(
    Map<String, dynamic> json,
    DATA Function(dynamic json) fromJsonDATA,
  ) =>
      _$CommonResponseFromJson<DATA>(json, fromJsonDATA);

  Map<String, dynamic> toJson(Object? Function(DATA data) toJsonDATA) =>
      _$CommonResponseToJson(this, toJsonDATA);
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

  Map<String, dynamic> toJson(Object? Function(DATA data) toJsonDATA) =>
      _$CommonListResponseToJson(this, toJsonDATA);
}

@JsonSerializable()
class Translation {
  int? translationId;
  String translationKey;
  int languageId;
  String translationContent;
  String projectId;
  int? moduleId;

  Translation(this.translationKey, this.languageId, this.translationContent,
      this.projectId,
      {this.translationId, this.moduleId});

  factory Translation.fromJson(Map<String, dynamic> json) =>
      _$TranslationFromJson(json);

  Map<String, dynamic> toJson() => _$TranslationToJson(this);
}

@JsonSerializable()
class Project {
  String projectName;
  String projectId;

  Project(this.projectName, this.projectId);

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

@JsonSerializable()
class Language {
  int? languageId;
  String languageName;
  String languageDes;
  String projectId;

  Language(this.languageName, this.languageDes, this.projectId,
      {this.languageId});

  factory Language.fromJson(Map<String, dynamic> json) =>
      _$LanguageFromJson(json);

  Map<String, dynamic> toJson() => _$LanguageToJson(this);
}

@JsonSerializable()
class Module {
  int? moduleId;

  String moduleName;

  String projectId;

  Module(this.moduleName, this.projectId, {this.moduleId});

  factory Module.fromJson(Map<String,dynamic> json) => _$ModuleFromJson(json);

  Map<String ,dynamic> toJson() => _$ModuleToJson(this);
}
