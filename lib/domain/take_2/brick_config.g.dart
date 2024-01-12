// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brick_config.dart';

// **************************************************************************
// AutoequalGenerator
// **************************************************************************

extension _$BrickConfigAutoequal on BrickConfig {
  List<Object?> get _$props => [
        name,
        source,
        brickConfig,
        files,
        directories,
        urls,
        partials,
        exclude,
      ];
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrickConfig _$BrickConfigFromJson(Map json) {
  $checkKeys(
    json,
    allowedKeys: const [
      'name',
      'source',
      'brick_config',
      'files',
      'dirs',
      'urls',
      'partials',
      'exclude'
    ],
  );
  return BrickConfig(
    name: json['name'] as String,
    source: json['source'] as String,
    brickConfig: json['brick_config'] as String?,
    files: (json['files'] as Map?)?.map(
      (k, e) => MapEntry(k as String, FileConfig.fromJson(e as Map)),
    ),
    directories: (json['dirs'] as Map?)?.map(
      (k, e) => MapEntry(k as String, DirectoryConfig.fromJson(e as Map)),
    ),
    urls: (json['urls'] as Map?)?.map(
      (k, e) => MapEntry(k as String, UrlConfig.fromJson(e as Map)),
    ),
    partials: (json['partials'] as Map?)?.map(
      (k, e) => MapEntry(k as String, PartialConfig.fromJson(e as Map)),
    ),
    exclude:
        (json['exclude'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$BrickConfigToJson(BrickConfig instance) {
  final val = <String, dynamic>{
    'name': instance.name,
    'source': instance.source,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('brick_config', instance.brickConfig);
  writeNotNull('files', instance.files?.map((k, e) => MapEntry(k, e.toJson())));
  writeNotNull(
      'dirs', instance.directories?.map((k, e) => MapEntry(k, e.toJson())));
  writeNotNull('urls', instance.urls?.map((k, e) => MapEntry(k, e.toJson())));
  writeNotNull(
      'partials', instance.partials?.map((k, e) => MapEntry(k, e.toJson())));
  writeNotNull('exclude', instance.exclude);
  return val;
}
