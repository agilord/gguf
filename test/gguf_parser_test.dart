import 'dart:io';
import 'package:gguf/gguf.dart';
import 'package:huggingface_tools/huggingface_tools.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  group('LllamacppProcess', () {
    late File modelFile;

    setUp(() async {
      modelFile = File(
        path.join('.dart_tool', 'cached', 'model', 'gte-small.Q2_K.gguf'),
      ).absolute;
      if (!await modelFile.exists()) {
        await modelFile.parent.create(recursive: true);
        final model = await getModelInfo('ChristianAzinn/gte-small-gguf');

        final ggufFile = model.ggufModelFiles.firstWhere(
          (f) => f.filename == 'gte-small.Q2_K.gguf',
        );
        await downloadFile(ggufFile, targetFilePath: modelFile.path);
      }
    });

    test('gguf file parsing', () async {
      final gguf = await parseGgufFile(modelFile.path);
      expect(gguf.toJson(), {
        'version': 3,
        'metadata': {
          'general.architecture': 'bert',
          'general.name': 'gte-small',
          'bert.block_count': 12,
          'bert.context_length': 512,
          'bert.embedding_length': 384,
          'bert.feed_forward_length': 1536,
          'bert.attention.head_count': 12,
          'bert.attention.layer_norm_epsilon': isNotNull,
          'general.file_type': 10,
          'bert.attention.causal': false,
          'bert.pooling_type': 1,
          'tokenizer.ggml.token_type_count': 2,
          'tokenizer.ggml.bos_token_id': 101,
          'tokenizer.ggml.eos_token_id': 102,
          'tokenizer.ggml.model': 'bert',
          'tokenizer.ggml.tokens': isNotEmpty,
          'tokenizer.ggml.scores': isNotEmpty,
          'tokenizer.ggml.token_type': isNotEmpty,
          'tokenizer.ggml.unknown_token_id': 100,
          'tokenizer.ggml.seperator_token_id': 102,
          'tokenizer.ggml.padding_token_id': 0,
          'tokenizer.ggml.cls_token_id': 101,
          'tokenizer.ggml.mask_token_id': 103,
          'general.quantization_version': 2,
        },
        'tensors': hasLength(197),
      });
      expect(gguf.baseLayerCount, 1);
      expect(gguf.layerBlocksCount, 12);
      expect(
        gguf.tensors.fold(<int, int>{}, (sum, v) {
          sum[v.typeCode] = (sum[v.typeCode] ?? 0) + v.length;
          return sum;
        }),
        {0: 1032192, 8: 12452992, 20: 7962624, 11: 3802272},
      );
    });
  });
}
