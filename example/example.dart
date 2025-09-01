import 'package:gguf/gguf.dart';

void main() async {
  final gguf = await parseGgufFile('model.gguf');
  print('Version: ${gguf.version}');
  print('Tensors: ${gguf.tensors.length}');
  print('Metadata keys: ${gguf.metadata.keys}');
}
