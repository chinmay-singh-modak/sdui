import 'dart:convert';
import 'dart:io';

import '../models/sdui_schema.dart';

class JsonEmitter {
  static const _encoder = JsonEncoder.withIndent('  ');

  /// Returns the schema as a pretty-printed JSON string. Pure — no IO.
  String emit(SduiSchema schema) => _encoder.convert(schema.toJson());

  /// Writes the schema JSON to [outputPath].
  Future<void> writeToFile(SduiSchema schema, String outputPath) async {
    final file = File(outputPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(emit(schema));
  }
}
