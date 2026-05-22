import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/vfd_manual.dart';

class ManualManagerService {
  // Base directory for manuals
  static const String manualsFolder = 'manuals';

  // Get manuals directory path
  static Future<String> getManualsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final manualsDir = Directory('${appDir.path}/$manualsFolder');

    if (!manualsDir.existsSync()) {
      manualsDir.createSync(recursive: true);
    }

    return manualsDir.path;
  }

  // Get vendor-specific directory
  static Future<String> getVendorDirectory(String vendorName) async {
    final manualsDir = await getManualsDirectory();
    final vendorDir = Directory('$manualsDir/${vendorName.toLowerCase()}');

    if (!vendorDir.existsSync()) {
      vendorDir.createSync(recursive: true);
    }

    return vendorDir.path;
  }

  // Check if manual exists locally
  static Future<bool> manualExists(
      String vendorName, String modelName, String manualType) async {
    final vendorDir = await getVendorDirectory(vendorName);
    final fileName = _getManualFileName(modelName, manualType);
    final file = File('$vendorDir/$fileName');
    return file.existsSync();
  }

  // Get manual file path
  static Future<String?> getManualPath(
      String vendorName, String modelName, String manualType) async {
    final vendorDir = await getVendorDirectory(vendorName);
    final fileName = _getManualFileName(modelName, manualType);
    final file = File('$vendorDir/$fileName');

    if (file.existsSync()) {
      return file.path;
    }
    return null;
  }

  // Copy manual from external location to app directory
  static Future<String> importManual(String sourcePath, String vendorName,
      String modelName, String manualType) async {
    final vendorDir = await getVendorDirectory(vendorName);
    final fileName = _getManualFileName(modelName, manualType);
    final destPath = '$vendorDir/$fileName';

    final sourceFile = File(sourcePath);
    await sourceFile.copy(destPath);

    return destPath;
  }

  // Get all manuals for a vendor
  static Future<List<VfdManual>> getVendorManuals(String vendorName) async {
    final vendorDir = await getVendorDirectory(vendorName);
    final dir = Directory(vendorDir);

    if (!dir.existsSync()) {
      return [];
    }

    final List<VfdManual> manuals = [];
    for (var entity in dir.listSync()) {
      if (entity is File && entity.path.endsWith('.pdf')) {
        final fileName = entity.path.split(Platform.pathSeparator).last;
        final parts = fileName.replaceAll('.pdf', '').split('_');

        if (parts.length >= 2) {
          final modelName = parts[0];
          final manualType = parts.sublist(1).join(' ');

          manuals.add(VfdManual(
            id: manuals.length + 1,
            modelId: 0,
            title: '$modelName - $manualType',
            manualType: manualType,
            filePath: entity.path,
            language: 'en',
            version: 1,
          ));
        }
      }
    }

    return manuals;
  }

// Get all manuals for a specific model
  static Future<List<VfdManual>> getModelManuals(
      String vendorName, String modelName) async {
    final allManuals = await getVendorManuals(vendorName);
    return allManuals
        .where((m) => m.title.toLowerCase().contains(modelName.toLowerCase()))
        .toList();
  }

  // Delete manual
  static Future<bool> deleteManual(
      String vendorName, String modelName, String manualType) async {
    final vendorDir = await getVendorDirectory(vendorName);
    final fileName = _getManualFileName(modelName, manualType);
    final file = File('$vendorDir/$fileName');

    if (file.existsSync()) {
      file.deleteSync();
      return true;
    }
    return false;
  }

  // Generate manual file name
  static String _getManualFileName(String modelName, String manualType) {
    final cleanModel = modelName.replaceAll(' ', '_');
    final cleanType = manualType.replaceAll(' ', '_');
    return '${cleanModel}_$cleanType.pdf';
  }

  // Get manual storage info
  static Future<Map<String, dynamic>> getStorageInfo() async {
    final manualsDir = await getManualsDirectory();
    final dir = Directory(manualsDir);

    int totalFiles = 0;
    int totalSize = 0;

    if (dir.existsSync()) {
      for (var entity in dir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.pdf')) {
          totalFiles++;
          totalSize += entity.lengthSync();
        }
      }
    }

    return {
      'totalFiles': totalFiles,
      'totalSize': totalSize,
      'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'directory': manualsDir,
    };
  }
}
