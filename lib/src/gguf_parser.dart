import 'dart:io';
import 'dart:typed_data';

import 'gguf_model.dart';

// Parse the GGUF file.
Future<Gguf> parseGgufFile(String path) async {
  final file = File(path);
  final raf = await file.open(mode: FileMode.read);
  final fileLength = await raf.length();
  try {
    // read the header
    final magicBytes = await raf.read(4);
    final magic = String.fromCharCodes(magicBytes);
    if (magic != 'GGUF') {
      throw Exception('Not a GGUF file.');
    }
    final version = await _readUint32(raf);
    final tensorCount = await _readUint64(raf);
    final kvCount = await _readUint64(raf);

    // read the metadata
    final metadata = <String, dynamic>{};
    for (int i = 0; i < kvCount; i++) {
      final key = await _readString(raf);
      final type = await _readUint32(raf);

      Future<Object?> read(int type) async {
        switch (type) {
          case 0: // GGUF_TYPE_UINT8
            return await raf.readByte();
          case 1: // GGUF_TYPE_INT8
            return (await raf.readByte()).toSigned(8);
          case 2: // GGUF_TYPE_UINT16
            return await _readUint16(raf);
          case 3: // GGUF_TYPE_INT16
            return (await _readUint16(raf)).toSigned(16);
          case 4: // GGUF_TYPE_UINT32
            return await _readUint32(raf);
          case 5: // GGUF_TYPE_INT32
            return (await _readUint32(raf)).toSigned(32);
          case 6: // GGUF_TYPE_FLOAT32
            return await _readFloat32(raf);
          case 7: // GGUF_TYPE_BOOL
            return (await raf.readByte()) != 0;
          case 8: // GGUF_TYPE_STRING
            return await _readString(raf);
          case 9: // GGUF_TYPE_ARRAY
            final arrayType = await _readUint32(raf);
            final arrayLength = await _readUint64(raf);
            final list = [];
            for (var i = 0; i < arrayLength; i++) {
              list.add(await read(arrayType));
            }
            return list;
          case 10: // GGUF_TYPE_UINT64
            return await _readUint64(raf);
          case 11: // GGUF_TYPE_INT64
            final bytes = await raf.read(8);
            return ByteData.sublistView(
              Uint8List.fromList(bytes),
            ).getInt64(0, Endian.little);
          case 12: // GGUF_TYPE_FLOAT64
            final bytes = await raf.read(8);
            return ByteData.sublistView(
              Uint8List.fromList(bytes),
            ).getFloat64(0, Endian.little);
          default:
            throw Exception('Unknown type: $type');
        }
      }

      metadata[key] = await read(type);
    }

    // read tensors
    final tensorsWithoutLength = <Tensor>[];
    for (int i = 0; i < tensorCount; i++) {
      final name = await _readString(raf);
      final numDims = await _readUint32(raf);
      final dimensions = <int>[];
      for (int j = 0; j < numDims; j++) {
        dimensions.add(await _readUint64(raf));
      }
      final typeCode = await _readUint32(raf);
      final offset = await _readUint64(raf);

      tensorsWithoutLength.add(
        Tensor(
          name: name,
          dimensions: dimensions,
          typeCode: typeCode,
          offset: offset,
          length: 0,
        ),
      );
    }
    final tensors = <Tensor>[];
    for (var i = 0; i < tensorsWithoutLength.length; i++) {
      final nextOffset = i == tensorsWithoutLength.length - 1
          ? fileLength
          : tensorsWithoutLength[i + 1].offset;
      final t = tensorsWithoutLength[i];
      final length = nextOffset - t.offset;
      assert(length >= 0);
      tensors.add(
        Tensor(
          name: t.name,
          dimensions: t.dimensions,
          typeCode: t.typeCode,
          offset: t.offset,
          length: length,
        ),
      );
    }

    return Gguf(version: version, metadata: metadata, tensors: tensors);
  } finally {
    await raf.close();
  }
}

Future<String> _readString(RandomAccessFile file) async {
  final length = await _readUint64(file);
  if (length == 0) return '';
  final bytes = Uint8List(length);
  await file.readInto(bytes);
  return String.fromCharCodes(bytes);
}

Future<int> _readUint64(RandomAccessFile file) async {
  final bytes = await file.read(8);
  if (bytes.length < 8) {
    throw Exception('Unexpected end of file while reading uint64');
  }
  return ByteData.sublistView(
    Uint8List.fromList(bytes),
  ).getUint64(0, Endian.little);
}

Future<int> _readUint32(RandomAccessFile file) async {
  final bytes = await file.read(4);
  if (bytes.length < 4) {
    throw Exception('Unexpected end of file while reading uint32');
  }
  return ByteData.sublistView(
    Uint8List.fromList(bytes),
  ).getUint32(0, Endian.little);
}

Future<int> _readUint16(RandomAccessFile file) async {
  final bytes = await file.read(2);
  if (bytes.length < 2) {
    throw Exception('Unexpected end of file while reading uint16');
  }
  return ByteData.sublistView(
    Uint8List.fromList(bytes),
  ).getUint16(0, Endian.little);
}

Future<double> _readFloat32(RandomAccessFile file) async {
  final bytes = await file.read(4);
  if (bytes.length < 4) {
    throw Exception('Unexpected end of file while reading float32');
  }
  return ByteData.sublistView(
    Uint8List.fromList(bytes),
  ).getFloat32(0, Endian.little);
}
