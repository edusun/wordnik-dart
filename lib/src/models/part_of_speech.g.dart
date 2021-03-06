// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'part_of_speech.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartOfSpeech _$PartOfSpeechFromJson(Map<String, dynamic> json) {
  return new PartOfSpeech(
      allCategories: (json['allCategories'] as List)
              ?.map((e) => e == null
                  ? null
                  : new Category.fromJson(e as Map<String, dynamic>))
              ?.toList() ??
          [],
      roots: (json['roots'] as List)
              ?.map((e) => e == null
                  ? null
                  : new Root.fromJson(e as Map<String, dynamic>))
              ?.toList() ??
          [],
      storageAbbr:
          (json['storageAbbr'] as List)?.map((e) => e as String)?.toList() ??
              []);
}

Map<String, dynamic> _$PartOfSpeechToJson(PartOfSpeech instance) {
  var val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('allCategories', instance.allCategories);
  writeNotNull('roots', instance.roots);
  writeNotNull('storageAbbr', instance.storageAbbr);
  return val;
}
