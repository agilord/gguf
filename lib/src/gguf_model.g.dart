// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gguf_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Gguf _$GgufFromJson(Map<String, dynamic> json) => Gguf(
  version: (json['version'] as num).toInt(),
  metadata: json['metadata'] as Map<String, dynamic>,
  tensors: (json['tensors'] as List<dynamic>)
      .map((e) => Tensor.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GgufToJson(Gguf instance) => <String, dynamic>{
  'version': instance.version,
  'metadata': instance.metadata,
  'tensors': instance.tensors.map((e) => e.toJson()).toList(),
};

Tensor _$TensorFromJson(Map<String, dynamic> json) => Tensor(
  name: json['name'] as String,
  dimensions: (json['dimensions'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
  typeCode: (json['typeCode'] as num).toInt(),
  offset: (json['offset'] as num).toInt(),
  length: (json['length'] as num).toInt(),
);

Map<String, dynamic> _$TensorToJson(Tensor instance) => <String, dynamic>{
  'name': instance.name,
  'dimensions': instance.dimensions,
  'typeCode': instance.typeCode,
  'offset': instance.offset,
  'length': instance.length,
};
