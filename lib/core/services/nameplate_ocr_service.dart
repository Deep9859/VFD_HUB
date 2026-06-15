import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'nameplate_parser_service.dart';

class NameplateOcrService {
  NameplateOcrService._();

  static final _picker = ImagePicker();
  static final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<NameplateSpecs?> scanFromCamera() async {
    if (!isSupported) return null;
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image == null) return null;
    return _recognizeFile(image.path);
  }

  static Future<NameplateSpecs?> scanFromGallery() async {
    if (!isSupported) return null;
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return null;
    return _recognizeFile(image.path);
  }

  static Future<NameplateSpecs?> _recognizeFile(String path) async {
    try {
      final input = InputImage.fromFilePath(path);
      final result = await _recognizer.processImage(input);
      final text = result.text.trim();
      if (text.isEmpty) return null;
      final specs = NameplateParserService.parse(text);
      return specs.hasAnyValue ? specs : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> dispose() async {
    await _recognizer.close();
  }
}
