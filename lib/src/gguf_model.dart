import 'package:json_annotation/json_annotation.dart';

part 'gguf_model.g.dart';

@JsonSerializable()
class Gguf {
  final int version;
  final Map<String, dynamic> metadata;
  final List<Tensor> tensors;

  Gguf({required this.version, required this.metadata, required this.tensors});

  factory Gguf.fromJson(Map<String, dynamic> json) => _$GgufFromJson(json);
  Map<String, dynamic> toJson() => _$GgufToJson(this);
}

@JsonSerializable()
class Tensor {
  final String name;
  final List<int> dimensions;
  final int typeCode;
  final int offset;

  Tensor({
    required this.name,
    required this.dimensions,
    required this.typeCode,
    required this.offset,
  });

  factory Tensor.fromJson(Map<String, dynamic> json) => _$TensorFromJson(json);
  Map<String, dynamic> toJson() => _$TensorToJson(this);
}
