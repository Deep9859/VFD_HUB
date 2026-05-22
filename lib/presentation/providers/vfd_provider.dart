import 'dart:developer' as developer;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:vfd_param_app/core/exceptions/vfd_exceptions.dart';
import 'package:vfd_param_app/data/database/database_helper.dart';

import '../../data/models/protocol_model.dart';
import '../../data/models/vendor_model.dart';
import '../../data/models/vfd_model.dart';
import '../../presentation/screens/pdf_viewer_screen.dart';
import '../../data/models/vfd_drawing.dart';
import '../../data/models/vfd_fault.dart';
import '../../data/models/vfd_manual.dart';
import '../../data/models/vfd_parameter.dart';
import '../../data/datasources/vfd_static_data.dart';
import '../../core/services/widget_service.dart';

enum ConnectionType { communication, hardWire }

class VfdProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ── State ─────────────────────────────────────────────────────────
  List<Vendor> _vendors = [];
  List<String> _modelNames = [];
  List<double> _powerRatings = [];
  List<String> _voltages = [];
  List<VfdParameter> _parameters = [];
  List<VfdManual> _manuals = [];
  List<Protocol> _protocols = [];
  List<VfdParameter> _protocolParameters = [];
  List<VfdDrawing> _drawings = [];
  bool _useStaticFallback = false;

  Vendor? _selectedVendor;
  String? _selectedModelName;
  double? _selectedPowerRating;
  String? _selectedVoltage;
  VfdModel? _selectedModel;
  Protocol? _selectedProtocol;
  String? _selectedCommCard;
  ConnectionType _connectionType = ConnectionType.hardWire;
  bool _isLoading = false;
  String? _errorMessage;

  VfdProvider();

  // ── Getters ───────────────────────────────────────────────────────
  List<Vendor> get vendors => _vendors;
  List<String> get modelNames => _modelNames;
  List<double> get powerRatings => _powerRatings;
  List<String> get voltages => _voltages;
  List<VfdParameter> get parameters => _parameters;
  List<VfdManual> get manuals => _manuals;
  List<Protocol> get protocols => _protocols;
  List<VfdParameter> get protocolParameters => _protocolParameters;
  List<VfdDrawing> get drawings => _drawings;
  Vendor? get selectedVendor => _selectedVendor;
  String? get selectedModelName => _selectedModelName;
  double? get selectedPowerRating => _selectedPowerRating;
  String? get selectedVoltage => _selectedVoltage;
  VfdModel? get selectedModel => _selectedModel;
  Protocol? get selectedProtocol => _selectedProtocol;
  String? get selectedCommCard => _selectedCommCard;
  ConnectionType get connectionType => _connectionType;

  List<String> get commCardOptions {
    final vendorName = _selectedVendor?.name;
    final modelName = _selectedModelName;
    if (vendorName != null && modelName != null) {
      final modelCards =
          VfdStaticData.getCommunicationCards(vendorName, modelName);
      if (modelCards.isNotEmpty) {
        return modelCards;
      }
    }

    if (_selectedProtocol == null) return [];
    final card = _selectedProtocol!.commCard;
    const builtIn = 'Built-in (No Card Required)';
    if (card == null || card.trim().isEmpty) return [builtIn];
    return [
      builtIn,
      ...card.split(',').map((c) => c.trim()).where((c) => c.isNotEmpty)
    ];
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, List<VfdParameter>> get parametersByGroup {
    final Map<String, List<VfdParameter>> grouped = {};
    for (var param in _parameters) {
      grouped.putIfAbsent(param.groupName, () => []).add(param);
    }
    return grouped;
  }

  Map<String, List<VfdParameter>> get protocolParametersByGroup {
    final Map<String, List<VfdParameter>> grouped = {};
    for (var param in _protocolParameters) {
      grouped.putIfAbsent(param.groupName, () => []).add(param);
    }
    return grouped;
  }

  void setConnectionType(ConnectionType type) {
    _connectionType = type;
    if (type == ConnectionType.hardWire) {
      _selectedProtocol = null;
      _selectedCommCard = null;
      _protocolParameters = [];
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadVendors() async {
    _isLoading = true;
    _errorMessage = null;
    _useStaticFallback = false;
    notifyListeners();
    try {
      _vendors = await _dbHelper.getAllVendors();
      if (_vendors.isEmpty) {
        _loadStaticVendors();
      }
    } on DatabaseException catch (e) {
      _loadStaticVendors();
      _errorMessage = e.userMessage;
      e.log();
    } catch (e) {
      _loadStaticVendors();
      _errorMessage = 'An unexpected error occurred while loading vendors';
      developer.log('Unexpected error: $e', name: 'VfdProvider');
    }
    _isLoading = false;
    notifyListeners();
  }

  void _loadStaticVendors() {
    _vendors = VfdStaticData.vendorNames
        .asMap()
        .entries
        .map((entry) => Vendor(
              id: entry.key + 1,
              name: entry.value,
              logo: '',
              description: 'VFD Manufacturer',
            ))
        .toList();
    _useStaticFallback = true;
  }

  // ── Step 2: Select Vendor → load model names ──────────────────────
  Future<void> selectVendor(Vendor vendor) async {
    _selectedVendor = vendor;
    _selectedModelName = null;
    _selectedPowerRating = null;
    _selectedVoltage = null;
    _selectedModel = null;
    _selectedProtocol = null;
    _connectionType = ConnectionType.hardWire;
    _modelNames = [];
    _powerRatings = [];
    _voltages = [];
    _parameters = [];
    _manuals = [];
    _protocols = [];
    _protocolParameters = [];
    _drawings = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _modelNames = await _dbHelper.getDistinctModelNamesByVendor(vendor.id);
    } on DatabaseException catch (e) {
      _errorMessage = e.userMessage;
      e.log();
    } catch (e) {
      _errorMessage = 'Failed to load models for vendor ${vendor.name}';
      developer.log('Unexpected error: $e', name: 'VfdProvider');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── Step 3: Select Model Name → load power ratings (SORTED) ───────
  Future<void> selectModelName(String name) async {
    _selectedModelName = name;
    _selectedPowerRating = null;
    _selectedVoltage = null;
    _selectedModel = null;
    _selectedProtocol = null;
    _powerRatings = [];
    _voltages = [];
    _parameters = [];
    _manuals = [];
    _protocolParameters = [];
    _drawings = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _powerRatings = await _dbHelper.getPowerRatingsByVendorAndName(
          _selectedVendor!.id, name);
    } on DataNotFoundException catch (e) {
      // Fall back to static model data only if DB has no entry for this vendor/model.
      final vendorName = _selectedVendor?.name;
      if (vendorName != null) {
        _powerRatings = VfdStaticData.getPowerRatings(vendorName, name);
      }
      if (_powerRatings.isEmpty) {
        _errorMessage = 'No power ratings available for model: $name';
        e.log();
      }
    } on DatabaseException catch (e) {
      _errorMessage = e.userMessage;
      e.log();
    } catch (e) {
      _errorMessage = 'Failed to load specifications for model: $name';
      developer.log('Unexpected error: $e', name: 'VfdProvider');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── Step 4: Select Power Rating → load voltages ───────────────────
  Future<void> selectPowerRating(double power) async {
    _selectedPowerRating = power;
    _selectedVoltage = null;
    _selectedModel = null;
    _selectedProtocol = null;
    _voltages = [];
    _parameters = [];
    _manuals = [];
    _protocolParameters = [];
    _drawings = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _voltages = await _dbHelper.getVoltagesByFilter(
          _selectedVendor!.id, _selectedModelName!, power);
      // Auto-select if only one voltage option
      if (_voltages.length == 1) {
        await selectVoltage(_voltages.first);
        return;
      }
    } on DataNotFoundException catch (e) {
      _errorMessage = 'No voltage options available for $power kW model';
      e.log();
    } on DatabaseException catch (e) {
      _errorMessage = e.userMessage;
      e.log();
    } catch (e) {
      _errorMessage = 'Failed to load voltage options';
      developer.log('Unexpected error: $e', name: 'VfdProvider');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── Step 5: Select Voltage → resolve model + load protocols ──────
  Future<void> selectVoltage(String voltage) async {
    _selectedVoltage = voltage;
    _selectedModel = null;
    _selectedProtocol = null;
    _selectedCommCard = null;
    _connectionType = ConnectionType.hardWire; // Reset to default
    _parameters = [];
    _manuals = [];
    _protocolParameters = [];
    _drawings = [];
    _protocols = [];
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final model = await _dbHelper.getModelByFilter(_selectedVendor!.id,
          _selectedModelName!, _selectedPowerRating!, voltage);
      if (model != null) {
        _selectedModel = model;
        // Load model-specific protocols
        _protocols = await _dbHelper.getProtocolsByModel(model.id);
        await _loadModelData(model);
        _updateHomeWidget();
      } else if (_useStaticFallback) {
        _selectedModel = VfdModel(
          id: _selectedVendor!.id,
          vendorId: _selectedVendor!.id,
          name: _selectedModelName!,
          series: '',
          description: 'Static fallback model',
          powerRating: _selectedPowerRating ?? 0.0,
          voltage: voltage,
        );
        final protocolNames = VfdStaticData.getProtocols(
            _selectedVendor!.name, _selectedModelName!);
        _protocols = protocolNames
            .asMap()
            .entries
            .map((entry) => Protocol(
                  id: entry.key + 1,
                  vendorId: _selectedVendor!.id,
                  modelId: _selectedModel!.id,
                  name: entry.value,
                  type: entry.value.toLowerCase().contains('ethernet')
                      ? 'Ethernet'
                      : entry.value.toLowerCase().contains('modbus')
                          ? 'Serial'
                          : 'Direct',
                  description: 'Static fallback protocol',
                  commCard: VfdStaticData.getCommunicationCards(
                          _selectedVendor!.name, _selectedModelName!)
                      .join(', '),
                ))
            .toList();
      } else {
        throw DataNotFoundException(
          message: 'Model not found for the selected specifications',
          code: 'MODEL_NOT_FOUND',
        );
      }
    } on DataNotFoundException catch (e) {
      _errorMessage = 'Could not find model with selected specifications';
      e.log();
    } on VfdException catch (e) {
      _errorMessage = e.userMessage;
      e.log();
    } catch (e) {
      _errorMessage = 'Failed to load model details';
      developer.log('Unexpected error: $e', name: 'VfdProvider');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadModelData(VfdModel model) async {
    try {
      _parameters = await _dbHelper.getParametersByModel(model.id);
      _manuals = await _dbHelper.getManualsByModel(model.id);
      _drawings = await _dbHelper.getDrawingsByModel(model.id);

      final savedValues = await _dbHelper.getParameterValues(model.id);
      _parameters = _parameters.map((p) {
        return savedValues.containsKey(p.id)
            ? p.copyWith(userValue: savedValues[p.id])
            : p;
      }).toList();
    } on DatabaseException catch (e) {
      developer.log('Error loading model data: ${e.toString()}',
          name: 'VfdProvider');
      _errorMessage = e.userMessage;
      e.log();
    } catch (e) {
      developer.log('Unexpected error loading model data: $e',
          name: 'VfdProvider');
      _errorMessage = 'Failed to load model data';
    }
  }

  void _updateHomeWidget() {
    if (_selectedVendor == null || _selectedModelName == null) return;
    HomeScreenWidgetService.saveWidgetData(VFDWidgetData(
      vendorName: _selectedVendor!.name,
      modelName: _selectedModelName!,
      powerRating: _selectedPowerRating?.toStringAsFixed(1) ?? '',
      lastAccessed: DateTime.now(),
    ));
  }

  // ── Comm Card ─────────────────────────────────────────────────────
  void selectCommCard(String card) {
    _selectedCommCard = card;
    notifyListeners();
  }

  // ── Auto-fill parameters from drawing specs ────────────────────────
  Future<void> autoFillMotorSpecs({
    required double motorKw,
    required double motorVoltage,
    required double motorCurrent,
    required double motorSpeed,
    required double motorFrequency,
    required String connection,
  }) async {
    if (_selectedModel == null) return;
    final specMap = {
      'motor rated power': motorKw.toString(),
      'rated power': motorKw.toString(),
      'motor power': motorKw.toString(),
      'motor rated voltage': motorVoltage.toString(),
      'rated voltage': motorVoltage.toString(),
      'motor voltage': motorVoltage.toString(),
      'motor rated current': motorCurrent.toString(),
      'rated current': motorCurrent.toString(),
      'motor current': motorCurrent.toString(),
      'motor rated speed': motorSpeed.toString(),
      'rated speed': motorSpeed.toString(),
      'motor speed': motorSpeed.toString(),
      'motor rated frequency': motorFrequency.toString(),
      'rated frequency': motorFrequency.toString(),
      'base frequency': motorFrequency.toString(),
      'motor connection': connection,
      'connection type': connection,
    };

    for (int i = 0; i < _parameters.length; i++) {
      final p = _parameters[i];
      final key = p.paramName.toLowerCase();
      final match = specMap.entries.where((e) => key.contains(e.key)).toList();
      if (match.isNotEmpty) {
        final val = match.first.value;
        await _dbHelper.saveParameterValue(p.id, _selectedModel!.id, val);
        _parameters[i] = p.copyWith(userValue: val);
      }
    }
    notifyListeners();
  }

  // ── Protocol ──────────────────────────────────────────────────────
  Future<void> selectProtocol(Protocol protocol) async {
    _selectedProtocol = protocol;
    _selectedCommCard = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (_selectedModel == null) {
        throw DataNotFoundException(
          message: 'Model must be selected before choosing protocol',
          code: 'MODEL_REQUIRED',
        );
      }
      _protocolParameters = await _dbHelper.getProtocolParameters(protocol.id);
      final savedValues = await _dbHelper.getParameterValues(_selectedModel!.id);
      _protocolParameters = _protocolParameters.map((p) {
        return savedValues.containsKey(p.id)
            ? p.copyWith(userValue: savedValues[p.id])
            : p;
      }).toList();
    } on DataNotFoundException catch (e) {
      _errorMessage = e.userMessage;
      e.log();
    } on DatabaseException catch (e) {
      _errorMessage = e.userMessage;
      e.log();
    } catch (e) {
      _errorMessage = 'Failed to load protocol parameters';
      developer.log('Unexpected error: $e', name: 'VfdProvider');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── Parameter Values ──────────────────────────────────────────────
  Future<void> saveParameterValue(int parameterId, String value) async {
    if (_selectedModel == null) return;
    try {
      await _dbHelper.saveParameterValue(
          parameterId, _selectedModel!.id, value);
      final idx = _parameters.indexWhere((p) => p.id == parameterId);
      if (idx != -1) {
        _parameters[idx] = _parameters[idx].copyWith(userValue: value);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to save value: $e';
      notifyListeners();
    }
  }

  String? getParameterValue(int parameterId) {
    final param = _parameters.firstWhere(
      (p) => p.id == parameterId,
      orElse: () => throw StateError('Parameter $parameterId not found'),
    );
    return param.userValue ?? param.defaultValue;
  }

  String? getProtocolParameterValue(int parameterId) {
    final param = _protocolParameters.firstWhere(
      (p) => p.id == parameterId,
      orElse: () => throw StateError('Protocol parameter $parameterId not found'),
    );
    return param.userValue ?? param.defaultValue;
  }

  Future<void> saveProtocolParameterValue(int parameterId, String value) async {
    if (_selectedProtocol == null || _selectedModel == null) return;
    try {
      await _dbHelper.saveParameterValue(parameterId, _selectedModel!.id, value);
      final idx = _protocolParameters.indexWhere((p) => p.id == parameterId);
      if (idx != -1) {
        _protocolParameters[idx] =
            _protocolParameters[idx].copyWith(userValue: value);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to save value: $e';
      notifyListeners();
    }
  }

  Future<void> clearAllParameterValues() async {
    if (_selectedModel == null) return;
    try {
      await _dbHelper.clearParameterValues(_selectedModel!.id);
      _parameters = _parameters.map((p) => p.copyWith(userValue: null)).toList();
      _protocolParameters = _protocolParameters.map((p) => p.copyWith(userValue: null)).toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to clear values: $e';
      notifyListeners();
    }
  }

  Map<String, dynamic> exportConfiguration() {
    return {
      'vendor': _selectedVendor?.name,
      'model': _selectedModelName,
      'powerRating': _selectedPowerRating,
      'voltage': _selectedVoltage,
      'connectionType': _connectionType.name,
      'protocol': _selectedProtocol?.name,
      'commCard': _selectedCommCard,
      'parameters': _parameters.map((p) => {
        'id': p.id,
        'name': p.paramName,
        'value': p.userValue ?? p.defaultValue,
      }).toList(),
    };
  }

  // ── File Operations ───────────────────────────────────────────────
  Future<String?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
      );
      return result?.files.single.path;
    } catch (e) {
      _errorMessage = 'Could not pick file: $e';
      notifyListeners();
      return null;
    }
  }

  Future<String?> pickAndUploadManual(VfdManual manual) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
      );
      if (result == null || result.files.single.path == null) return null;
      final filePath = result.files.single.path!;
      await _dbHelper.updateManualFilePath(manual.id, filePath);
      final idx = _manuals.indexWhere((m) => m.id == manual.id);
      if (idx != -1) {
        _manuals[idx] = manual.copyWith(filePath: filePath);
      }
      notifyListeners();
      return filePath;
    } catch (e) {
      _errorMessage = 'Upload failed: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> addNewManual(
      String title, String manualType, String filePath) async {
    if (_selectedModel == null) return;
    try {
      final newManual = VfdManual(
        id: 0,
        modelId: _selectedModel!.id,
        title: title,
        manualType: manualType,
        filePath: filePath,
        language: 'English',
        version: 1,
      );
      final id = await _dbHelper.insertManual(newManual);
      _manuals.add(newManual.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Could not add manual: $e';
      notifyListeners();
    }
  }

  Future<void> openManualFile(BuildContext context, VfdManual manual) async {
    if (manual.filePath.isEmpty) {
      // Show upload prompt
      final shouldUpload = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No PDF Uploaded'),
          content: const Text(
              'This manual does not have a PDF file. Would you like to upload one now?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Upload'),
            ),
          ],
        ),
      );
      if (shouldUpload == true) {
        await pickAndUploadManual(manual);
      }
      return;
    }

    final filePath = manual.filePath;

    // Check if the filePath is actually a URL (http/https)
    if (filePath.startsWith('http://') || filePath.startsWith('https://')) {
      final uri = Uri.parse(filePath);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _errorMessage = 'Could not open link: $filePath';
        notifyListeners();
      }
      return;
    }

    // Navigate to in-app PDF viewer for local files
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(manual: manual),
      ),
    );
  }

  // ── Fault Code Operations ──────────────────────────────────────────

  Future<List<VfdFault>> getFaultCodesByVendor(String vendorId) async {
    try {
      return await _dbHelper.getFaultCodesByVendor(vendorId);
    } catch (e) {
      _errorMessage = 'Could not load fault codes: $e';
      notifyListeners();
      return [];
    }
  }

  Future<List<VfdFault>> searchFaultCodes(String vendorId, String query) async {
    try {
      return await _dbHelper.searchFaultCodes(vendorId, query);
    } catch (e) {
      _errorMessage = 'Could not search fault codes: $e';
      notifyListeners();
      return [];
    }
  }

  Future<VfdFault?> getFaultCode(String vendorId, String errorCode) async {
    try {
      return await _dbHelper.getFaultCode(vendorId, errorCode);
    } catch (e) {
      _errorMessage = 'Could not get fault code: $e';
      notifyListeners();
      return null;
    }
  }

  // ── Drawing Operations ────────────────────────────────────────────
  Future<bool> uploadDrawing() async {
    if (_selectedModel == null) return false;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.single.path == null) return false;
      final file = result.files.single;
      final drawing = VfdDrawing(
        id: 0,
        modelId: _selectedModel!.id,
        name: file.name,
        filePath: file.path!,
        fileType: file.extension ?? '',
        uploadedAt: DateTime.now(),
      );
      final id = await _dbHelper.insertDrawing(drawing);
      _drawings.add(drawing.copyWith(id: id));
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to upload drawing: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> deleteDrawing(VfdDrawing drawing) async {
    try {
      await _dbHelper.deleteDrawing(drawing.id);
      _drawings.removeWhere((d) => d.id == drawing.id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete drawing: $e';
      notifyListeners();
    }
  }

  Future<void> openDrawing(VfdDrawing drawing) async {
    if (drawing.filePath.isEmpty) return;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final result = await OpenFile.open(drawing.filePath);
        if (result.type != ResultType.done) {
          _errorMessage = 'Could not open drawing: ${result.message}';
          notifyListeners();
        }
      } else if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', drawing.filePath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [drawing.filePath]);
      } else {
        await Process.run('xdg-open', [drawing.filePath]);
      }
    } catch (e) {
      _errorMessage = 'Could not open drawing: $e';
      notifyListeners();
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────
  void clearSelection() {
    _selectedVendor = null;
    _selectedModelName = null;
    _selectedPowerRating = null;
    _selectedVoltage = null;
    _selectedModel = null;
    _selectedProtocol = null;
    _modelNames = [];
    _powerRatings = [];
    _voltages = [];
    _parameters = [];
    _protocolParameters = [];
    _manuals = [];
    _protocols = [];
    _drawings = [];
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_selectedVoltage != null) {
      await selectVoltage(_selectedVoltage!);
    } else if (_selectedPowerRating != null) {
      await selectPowerRating(_selectedPowerRating!);
    } else if (_selectedModelName != null) {
      await selectModelName(_selectedModelName!);
    } else if (_selectedVendor != null) {
      await selectVendor(_selectedVendor!);
    } else {
      await loadVendors();
    }
  }
}
