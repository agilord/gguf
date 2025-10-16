import 'package:json_annotation/json_annotation.dart';

part 'gguf_model.g.dart';

@JsonSerializable()
/// The main GGUF content.
class Gguf {
  /// The GGUF format version.
  final int version;

  /// Model metadata.
  final Map<String, dynamic> metadata;

  /// The tensors data.
  final List<Tensor> tensors;

  Gguf({required this.version, required this.metadata, required this.tensors});

  /// Serializes the object from JSON.
  factory Gguf.fromJson(Map<String, dynamic> json) => _$GgufFromJson(json);

  /// Serializes the object to JSON.
  Map<String, dynamic> toJson() => _$GgufToJson(this);

  /// Gets the base layer count from standard layer names.
  int get baseLayerCount {
    const names = {'token_embd', 'pos_embd', 'output_norm', 'output'};
    return tensors.map((t) => t.layerName).where(names.contains).toSet().length;
  }

  /// Gets the layer blocks count from standard tensor names.
  int get layerBlocksCount {
    return tensors
        .where((t) => t.isBlock)
        .map((t) => t.layerName)
        .toSet()
        .length;
  }
}

/// The data of a single tensor.
@JsonSerializable()
class Tensor {
  /// The name of the tensor.
  final String name;

  /// The dimensions of the tensor.
  final List<int> dimensions;

  /// The type code of the tensor.
  final int typeCode;

  /// The byte offset where the tensor starts.
  final int offset;

  /// The byte length of the tensor data.
  final int length;

  Tensor({
    required this.name,
    required this.dimensions,
    required this.typeCode,
    required this.offset,
    required this.length,
  });

  /// Serializes the object from JSON.
  factory Tensor.fromJson(Map<String, dynamic> json) => _$TensorFromJson(json);

  /// Serializes the object to JSON.
  Map<String, dynamic> toJson() => _$TensorToJson(this);

  /// The tensor's base layer or layer block name( e.g. `output or `blk.2`)
  late final layerName = name.startsWith('blk.')
      ? name.split('.').take(2).join('.')
      : name.split('.').first;

  /// Whether the tensor is part of a layer block.
  late final isBlock = layerName.startsWith('blk.');
}
