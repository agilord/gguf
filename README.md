# GGUF Parser

A Dart library for parsing GGUF (GPT-Generated Unified Format) model files
(e.g. files that are run with llama.cpp).

## Usage

```dart
import 'package:gguf/gguf.dart';

final gguf = await parseGgufFile('model.gguf');
print('Version: ${gguf.version}');
print('Tensors: ${gguf.tensors.length}');
print('Metadata keys: ${gguf.metadata.keys}');
```

## Features

- Parse GGUF file headers and metadata
- Extract tensor information (dimensions, types, offsets)
