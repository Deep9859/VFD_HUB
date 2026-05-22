import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:path/path.dart';
import '../datasources/vendor_ratings_data.dart';
import '../datasources/vendor_models_data.dart';
import '../datasources/fault_codes_data.dart';
import '../datasources/abb_manual_links.dart';
import '../datasources/schneider_manual_links.dart';
import '../datasources/parker_manual_links.dart';
import '../datasources/yaskawa_manual_links.dart';
import '../datasources/danfoss_manual_links.dart';
import '../datasources/delta_manual_links.dart';
import '../datasources/fuji_manual_links.dart';
import '../datasources/hitachi_manual_links.dart';
import '../datasources/mitsubishi_manual_links.dart';
import '../datasources/nidec_manual_links.dart';
import '../datasources/toshiba_manual_links.dart';
import '../datasources/weg_manual_links.dart';
import '../datasources/ls_manual_links.dart';
import '../datasources/lenze_manual_links.dart';
import '../datasources/omron_manual_links.dart';
import '../datasources/inovance_manual_links.dart';
import '../datasources/invt_manual_links.dart';
import '../datasources/keb_manual_links.dart';
import '../datasources/lt_manual_links.dart';
import '../../core/exceptions/vfd_exceptions.dart'
    show
        VfdException,
        DatabaseException,
        DataNotFoundException,
        ValidationException;
import '../../core/services/logging_service.dart';
import '../models/vendor_model.dart';
import '../models/vfd_model.dart';
import '../models/vfd_parameter.dart';
import '../models/vfd_manual.dart';
import '../models/protocol_model.dart';
import '../models/vfd_drawing.dart';
import '../models/vfd_fault.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vfd_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 33,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to initialize database: $e',
        code: 'INIT_ERROR',
        originalException: e,
      );
    }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await _createSchema(db);

    if (oldVersion < 8) {
      await _seedIfEmpty(db);
    }
    if (oldVersion < 9) {
      await _seedStandardRatings(db);
    }
    if (oldVersion < 10) {
      await _seedVendorModels(db);
    }
    if (oldVersion < 12) {
      await _seedMissingSchneiderParams(db);
    }
    if (oldVersion < 13) {
      await _seedMissingAbbParams(db);
    }
    if (oldVersion < 14) {
      await _seedAbbManualLinks(db);
    }
    if (oldVersion < 15) {
      await _seedSchneiderManualLinks(db);
    }
    if (oldVersion < 16) {
      await _seedParkerManualLinks(db);
    }
    if (oldVersion < 17) {
      await _seedYaskawaManualLinks(db);
    }
    if (oldVersion < 18) {
      await _seedDanfossManualLinks(db);
    }
    if (oldVersion < 19) {
      await _seedDeltaManualLinks(db);
    }
    if (oldVersion < 20) {
      await _seedFujiManualLinks(db);
    }
    if (oldVersion < 21) {
      await _seedHitachiManualLinks(db);
    }
    if (oldVersion < 22) {
      await _seedMitsubishiManualLinks(db);
    }
    if (oldVersion < 23) {
      await _seedNidecManualLinks(db);
    }
    if (oldVersion < 24) {
      await _seedToshibaManualLinks(db);
    }
    if (oldVersion < 25) {
      await _seedWegManualLinks(db);
    }
    if (oldVersion < 26) {
      await _seedLsManualLinks(db);
    }
    if (oldVersion < 27) {
      await _seedLenzeManualLinks(db);
    }
    if (oldVersion < 28) {
      await _seedOmronManualLinks(db);
    }
    if (oldVersion < 29) {
      await _seedInovanceManualLinks(db);
    }
    if (oldVersion < 30) {
      await _seedInvtManualLinks(db);
    }
    if (oldVersion < 31) {
      await _seedKebManualLinks(db);
    }
    if (oldVersion < 32) {
      await _seedLtManualLinks(db);
    }
    if (oldVersion < 33) {
      await _migrateToModelSpecificProtocols(db);
    }
  }

  Future<void> _seedMissingSchneiderParams(Database db) async {
    final models = {
      'ATV320': <String, dynamic>{},
      'ATV340': <String, dynamic>{},
      'ATV610': <String, dynamic>{}
    };
    for (final name in models.keys) {
      final rows = await db.query('vfd_models',
          where: 'name = ?', whereArgs: [name], limit: 1);
      if (rows.isNotEmpty) models[name] = rows.first;
    }

    Future<void> seedIfEmpty(int modelId, List<List<String>> params) async {
      final existing = await db.query('vfd_parameters',
          where: 'modelId = ?', whereArgs: [modelId], limit: 1);
      if (existing.isEmpty) await _insertParams(db, modelId, params);
    }

    final atv320Row = models['ATV320'];
    if (atv320Row != null && atv320Row.isNotEmpty) {
      await seedIfEmpty(atv320Row['id'] as int, [
        [
          'bFr',
          'Standard Frequency',
          '50Hz or 60Hz grid standard',
          '50',
          '50',
          '60',
          'Motor Control'
        ],
        [
          'UnS',
          'Nominal Motor Voltage',
          'Motor nameplate voltage (V)',
          '400',
          '100',
          '500',
          'Motor'
        ],
        [
          'FrS',
          'Nominal Motor Frequency',
          'Motor nameplate frequency (Hz)',
          '50',
          '10',
          '500',
          'Motor'
        ],
        [
          'nCr',
          'Rated Motor Current',
          'Motor nameplate current (A)',
          '3.0',
          '0.1',
          '65535',
          'Motor'
        ],
        [
          'nSP',
          'Nominal Motor Speed',
          'Motor nameplate speed (RPM)',
          '1450',
          '0',
          '65535',
          'Motor'
        ],
        [
          'nPr',
          'Nominal Motor Power',
          'Motor nameplate power (kW)',
          '1.5',
          '0.1',
          '65535',
          'Motor'
        ],
        [
          'ACC',
          'Acceleration Ramp',
          'Acceleration time 0→nominal (s)',
          '3.0',
          '0.1',
          '999.9',
          'Ramp'
        ],
        [
          'dEC',
          'Deceleration Ramp',
          'Deceleration time nominal→0 (s)',
          '3.0',
          '0.1',
          '999.9',
          'Ramp'
        ],
        [
          'LSP',
          'Low Speed',
          'Minimum output frequency (Hz)',
          '0.0',
          '0.0',
          '500.0',
          'Speed Limits'
        ],
        [
          'HSP',
          'High Speed',
          'Maximum output frequency (Hz)',
          '50.0',
          '0.0',
          '500.0',
          'Speed Limits'
        ],
        [
          'ItH',
          'Motor Thermal Current',
          'Motor thermal protection current (A)',
          '3.0',
          '0.0',
          '65535',
          'Protection'
        ],
        [
          'SFr',
          'Switching Frequency',
          'PWM switching frequency (kHz)',
          '4',
          '2',
          '16',
          'Motor Control'
        ],
        [
          'tCC',
          'Control Type',
          '2C=2-wire, 3C=3-wire',
          '2C',
          '2C',
          '3C',
          'Control'
        ],
      ]);
    }

    final atv340Row = models['ATV340'];
    if (atv340Row != null && atv340Row.isNotEmpty) {
      await seedIfEmpty(atv340Row['id'] as int, [
        [
          'bFr',
          'Standard Frequency',
          '50Hz or 60Hz grid standard',
          '50',
          '50',
          '60',
          'Motor Control'
        ],
        [
          'UnS',
          'Nominal Motor Voltage',
          'Motor nameplate voltage (V)',
          '400',
          '100',
          '690',
          'Motor'
        ],
        [
          'FrS',
          'Nominal Motor Frequency',
          'Motor nameplate frequency (Hz)',
          '50',
          '10',
          '500',
          'Motor'
        ],
        [
          'nCr',
          'Rated Motor Current',
          'Motor nameplate current (A)',
          '8.0',
          '0.1',
          '65535',
          'Motor'
        ],
        [
          'nSP',
          'Nominal Motor Speed',
          'Motor nameplate speed (RPM)',
          '1450',
          '0',
          '65535',
          'Motor'
        ],
        [
          'nPr',
          'Nominal Motor Power',
          'Motor nameplate power (kW)',
          '4.0',
          '0.1',
          '65535',
          'Motor'
        ],
        [
          'COS',
          'Motor Power Factor',
          'Motor nameplate cos phi',
          '0.85',
          '0.5',
          '1.0',
          'Motor'
        ],
        [
          'ACC',
          'Acceleration Ramp',
          'Acceleration time 0→nominal (s)',
          '3.0',
          '0.01',
          '999.9',
          'Ramp'
        ],
        [
          'dEC',
          'Deceleration Ramp',
          'Deceleration time nominal→0 (s)',
          '3.0',
          '0.01',
          '999.9',
          'Ramp'
        ],
        [
          'LSP',
          'Low Speed',
          'Minimum output frequency (Hz)',
          '0.0',
          '0.0',
          '500.0',
          'Speed Limits'
        ],
        [
          'HSP',
          'High Speed',
          'Maximum output frequency (Hz)',
          '50.0',
          '0.0',
          '500.0',
          'Speed Limits'
        ],
        [
          'ItH',
          'Motor Thermal Current',
          'Motor thermal protection current (A)',
          '8.0',
          '0.0',
          '65535',
          'Protection'
        ],
        [
          'tHt',
          'Motor Thermal Type',
          '1=Self-cooled, 2=Force-cooled',
          '1',
          '1',
          '2',
          'Protection'
        ],
        [
          'SFr',
          'Switching Frequency',
          'PWM switching frequency (kHz)',
          '4',
          '2',
          '16',
          'Motor Control'
        ],
        [
          'rPG',
          'Speed Loop P Gain',
          'Speed loop proportional gain',
          '10',
          '1',
          '10000',
          'Motor Control'
        ],
        [
          'rIG',
          'Speed Loop I Gain',
          'Speed loop integral gain (ms)',
          '100',
          '1',
          '65535',
          'Motor Control'
        ],
        [
          'tCC',
          'Control Type',
          '2C=2-wire, 3C=3-wire',
          '2C',
          '2C',
          '3C',
          'Control'
        ],
        [
          'Ctd',
          'Control Mode',
          '0=Local, 1=Remote (fieldbus)',
          '0',
          '0',
          '1',
          'Control'
        ],
        ['rSF', 'Auto Fault Reset', '0=No, 1=Yes', '0', '0', '1', 'Protection'],
        [
          'Frt',
          'Fault Reset Attempts',
          'Number of auto-reset attempts',
          '3',
          '0',
          '10',
          'Protection'
        ],
      ]);
    }

    final atv610Row = models['ATV610'];
    if (atv610Row != null && atv610Row.isNotEmpty) {
      await seedIfEmpty(atv610Row['id'] as int, [
        [
          'bFr',
          'Standard Frequency',
          '50Hz or 60Hz grid standard',
          '50',
          '50',
          '60',
          'Motor Control'
        ],
        [
          'UnS',
          'Nominal Motor Voltage',
          'Motor nameplate voltage (V)',
          '400',
          '100',
          '690',
          'Motor'
        ],
        [
          'FrS',
          'Nominal Motor Frequency',
          'Motor nameplate frequency (Hz)',
          '50',
          '10',
          '500',
          'Motor'
        ],
        [
          'nCr',
          'Rated Motor Current',
          'Motor nameplate current (A)',
          '17.0',
          '0.1',
          '65535',
          'Motor'
        ],
        [
          'nSP',
          'Nominal Motor Speed',
          'Motor nameplate speed (RPM)',
          '1450',
          '0',
          '65535',
          'Motor'
        ],
        [
          'nPr',
          'Nominal Motor Power',
          'Motor nameplate power (kW)',
          '7.5',
          '0.1',
          '65535',
          'Motor'
        ],
        [
          'ACC',
          'Acceleration Ramp',
          'Acceleration time 0→nominal (s)',
          '5.0',
          '0.01',
          '6000.0',
          'Ramp'
        ],
        [
          'dEC',
          'Deceleration Ramp',
          'Deceleration time nominal→0 (s)',
          '5.0',
          '0.01',
          '6000.0',
          'Ramp'
        ],
        [
          'LSP',
          'Low Speed',
          'Minimum output frequency (Hz)',
          '0.0',
          '0.0',
          '500.0',
          'Speed Limits'
        ],
        [
          'HSP',
          'High Speed',
          'Maximum output frequency (Hz)',
          '50.0',
          '0.0',
          '500.0',
          'Speed Limits'
        ],
        [
          'ItH',
          'Motor Thermal Current',
          'Motor thermal protection current (A)',
          '17.0',
          '0.0',
          '65535',
          'Protection'
        ],
        [
          'SFr',
          'Switching Frequency',
          'PWM switching frequency (kHz)',
          '4',
          '2',
          '12',
          'Motor Control'
        ],
        [
          'tCC',
          'Control Type',
          '2C=2-wire, 3C=3-wire',
          '2C',
          '2C',
          '3C',
          'Control'
        ],
      ]);
    }
  }

  Future<void> _seedMissingAbbParams(Database db) async {
    Future<void> seedIfEmpty(int modelId, List<List<String>> params) async {
      final existing = await db.query('vfd_parameters',
          where: 'modelId = ?', whereArgs: [modelId], limit: 1);
      if (existing.isEmpty) await _insertParams(db, modelId, params);
    }

    // ── ACS880 ───────────────────────────────────────────────────────
    final acs880Rows = await db.query('vfd_models',
        where: 'name = ?', whereArgs: ['ACS880'], limit: 1);
    if (acs880Rows.isNotEmpty) {
      await seedIfEmpty(acs880Rows.first['id'] as int, [
        [
          '99.04',
          'Motor Ctrl Mode',
          '0=DTC, 1=Scalar',
          '0',
          '0',
          '1',
          'Start-up Data'
        ],
        [
          '99.06',
          'Motor Nominal Current',
          'Motor nameplate current (A)',
          '9.0',
          '0.0',
          '6400.0',
          'Start-up Data'
        ],
        [
          '99.07',
          'Motor Nominal Voltage',
          'Motor nameplate voltage (V)',
          '400',
          '1',
          '690',
          'Start-up Data'
        ],
        [
          '99.08',
          'Motor Nominal Frequency',
          'Motor nameplate frequency (Hz)',
          '50.0',
          '8.0',
          '300.0',
          'Start-up Data'
        ],
        [
          '99.09',
          'Motor Nominal Speed',
          'Motor nameplate speed (RPM)',
          '1450',
          '1',
          '30000',
          'Start-up Data'
        ],
        [
          '99.10',
          'Motor Nominal Power',
          'Motor nameplate power (kW)',
          '15.0',
          '0.0',
          '10000.0',
          'Start-up Data'
        ],
        [
          '20.01',
          'Speed Scaling',
          'Maximum speed used as 100% reference (RPM)',
          '1500',
          '0',
          '30000',
          'Limits'
        ],
        [
          '30.11',
          'Minimum Speed',
          'Minimum speed limit (RPM)',
          '0',
          '-30000',
          '30000',
          'Limits'
        ],
        [
          '30.12',
          'Maximum Speed',
          'Maximum speed limit (RPM)',
          '1500',
          '-30000',
          '30000',
          'Limits'
        ],
        [
          '30.17',
          'Maximum Current',
          'Maximum output current (A)',
          '100.0',
          '0.0',
          '6400.0',
          'Limits'
        ],
        [
          '23.12',
          'Acceleration Time 1',
          'Acceleration ramp time 0 to max speed (s)',
          '20.0',
          '0.0',
          '1800.0',
          'Ramp'
        ],
        [
          '23.13',
          'Deceleration Time 1',
          'Deceleration ramp time max speed to 0 (s)',
          '20.0',
          '0.0',
          '1800.0',
          'Ramp'
        ],
        [
          '23.14',
          'Acceleration Time 2',
          'Acceleration ramp set 2 (s)',
          '60.0',
          '0.0',
          '1800.0',
          'Ramp'
        ],
        [
          '23.15',
          'Deceleration Time 2',
          'Deceleration ramp set 2 (s)',
          '60.0',
          '0.0',
          '1800.0',
          'Ramp'
        ],
        [
          '22.11',
          'Speed Ref 1 Source',
          '0=Zero, 1=AI1, 2=AI2, 3=Fieldbus Ref 1',
          '1',
          '0',
          '3',
          'Speed Reference'
        ],
        [
          '20.06',
          'Start/Stop/Dir Source',
          'Control source selection',
          '1',
          '0',
          '5',
          'Start/Stop'
        ],
        [
          '96.04',
          'Macro Select',
          '0=Factory, 1=Hand/Auto, 2=PID, 3=Fieldbus',
          '0',
          '0',
          '5',
          'Configuration'
        ],
        [
          '96.06',
          'Factory Reset',
          '62=Restore all parameters to factory defaults',
          '0',
          '0',
          '62',
          'Configuration'
        ],
        [
          '31.01',
          'External Fault 1 Source',
          'Digital input for external fault 1',
          '0',
          '0',
          '255',
          'Protection'
        ],
        [
          '31.11',
          'Automatic Fault Reset',
          '0=Disabled, 1=Enabled',
          '0',
          '0',
          '1',
          'Protection'
        ],
      ]);
    }

    // ── ACS580 ───────────────────────────────────────────────────────
    final acs580Rows = await db.query('vfd_models',
        where: 'name = ?', whereArgs: ['ACS580'], limit: 1);
    if (acs580Rows.isNotEmpty) {
      await seedIfEmpty(acs580Rows.first['id'] as int, [
        [
          '99.04',
          'Motor Ctrl Mode',
          '0=Scalar, 1=Vector',
          '0',
          '0',
          '1',
          'Start-up Data'
        ],
        [
          '99.06',
          'Motor Nominal Current',
          'Motor nameplate current (A)',
          '9.0',
          '0.0',
          '6400.0',
          'Start-up Data'
        ],
        [
          '99.07',
          'Motor Nominal Voltage',
          'Motor nameplate voltage (V)',
          '380',
          '1',
          '690',
          'Start-up Data'
        ],
        [
          '99.08',
          'Motor Nominal Frequency',
          'Motor nameplate frequency (Hz)',
          '50.0',
          '8.0',
          '300.0',
          'Start-up Data'
        ],
        [
          '99.09',
          'Motor Nominal Speed',
          'Motor nameplate speed (RPM)',
          '1450',
          '1',
          '18000',
          'Start-up Data'
        ],
        [
          '99.10',
          'Motor Nominal Power',
          'Motor nameplate power (kW)',
          '4.0',
          '0.0',
          '10000.0',
          'Start-up Data'
        ],
        [
          '30.11',
          'Minimum Speed',
          'Minimum speed limit (RPM)',
          '0',
          '-18000',
          '18000',
          'Limits'
        ],
        [
          '30.12',
          'Maximum Speed',
          'Maximum speed limit (RPM)',
          '1500',
          '-18000',
          '18000',
          'Limits'
        ],
        [
          '30.17',
          'Maximum Current',
          'Maximum output current (A)',
          '10.0',
          '0.0',
          '6400.0',
          'Limits'
        ],
        [
          '23.12',
          'Acceleration Time 1',
          'Acceleration ramp time (s)',
          '20.0',
          '0.0',
          '1800.0',
          'Ramp'
        ],
        [
          '23.13',
          'Deceleration Time 1',
          'Deceleration ramp time (s)',
          '20.0',
          '0.0',
          '1800.0',
          'Ramp'
        ],
        [
          '22.11',
          'Speed Ref 1 Source',
          '0=Zero, 1=AI1, 2=AI2, 3=Fieldbus Ref 1',
          '1',
          '0',
          '3',
          'Speed Reference'
        ],
        [
          '20.01',
          'Ext1 Commands',
          'Start/stop command source for EXT1',
          '1',
          '0',
          '5',
          'Start/Stop'
        ],
        [
          '19.11',
          'Ext1/Ext2 Selection',
          '0=EXT1, 1=EXT2',
          '0',
          '0',
          '1',
          'Control'
        ],
        [
          '96.04',
          'Macro Select',
          '0=Factory, 1=Hand/Auto, 2=PID',
          '0',
          '0',
          '4',
          'Configuration'
        ],
        [
          '96.06',
          'Factory Reset',
          '62=Restore factory defaults',
          '0',
          '0',
          '62',
          'Configuration'
        ],
        [
          '31.11',
          'Automatic Fault Reset',
          '0=Disabled, 1=Enabled',
          '0',
          '0',
          '1',
          'Protection'
        ],
        [
          '31.01',
          'External Fault 1 Source',
          'Digital input for external fault',
          '0',
          '0',
          '255',
          'Protection'
        ],
      ]);
    }

    // ── ACS355 ───────────────────────────────────────────────────────
    final acs355Rows = await db.query('vfd_models',
        where: 'name = ?', whereArgs: ['ACS355'], limit: 1);
    if (acs355Rows.isNotEmpty) {
      await seedIfEmpty(acs355Rows.first['id'] as int, [
        [
          '9904',
          'Motor Ctrl Mode',
          '1=Scalar, 2=Vector',
          '1',
          '1',
          '2',
          'Motor Setup'
        ],
        [
          '9905',
          'Motor Nominal Voltage',
          'Motor nameplate voltage (V)',
          '380',
          '1',
          '690',
          'Motor Setup'
        ],
        [
          '9906',
          'Motor Nominal Current',
          'Motor nameplate current (A)',
          '2.0',
          '0.0',
          '6400.0',
          'Motor Setup'
        ],
        [
          '9907',
          'Motor Nominal Frequency',
          'Motor nameplate frequency (Hz)',
          '50.0',
          '8.0',
          '300.0',
          'Motor Setup'
        ],
        [
          '9908',
          'Motor Nominal Speed',
          'Motor nameplate speed (RPM)',
          '1450',
          '1',
          '18000',
          'Motor Setup'
        ],
        [
          '9909',
          'Motor Nominal Power',
          'Motor nameplate power (kW)',
          '0.75',
          '0.0',
          '10000.0',
          'Motor Setup'
        ],
        [
          '2001',
          'Min Speed',
          'Minimum speed reference (RPM)',
          '0',
          '-18000',
          '18000',
          'Limits'
        ],
        [
          '2002',
          'Max Speed',
          'Maximum speed reference (RPM)',
          '1500',
          '-18000',
          '18000',
          'Limits'
        ],
        [
          '2003',
          'Max Current',
          'Maximum output current (A)',
          '5.0',
          '0.0',
          '6400.0',
          'Limits'
        ],
        [
          '2202',
          'Accel Time 1',
          'Acceleration time 0 to max speed (s)',
          '20.0',
          '0.1',
          '1800.0',
          'Ramp'
        ],
        [
          '2203',
          'Decel Time 1',
          'Deceleration time max speed to 0 (s)',
          '20.0',
          '0.1',
          '1800.0',
          'Ramp'
        ],
        [
          '1001',
          'Ext1 Strt/Stp/Dir',
          'EXT1 start/stop/direction source',
          '1',
          '0',
          '12',
          'Start/Stop'
        ],
        [
          '1101',
          'Keypad Ref Sel',
          'Keypad reference selection',
          '1',
          '1',
          '2',
          'Reference'
        ],
        [
          '1301',
          'AI1 Min',
          'AI1 minimum input (V or mA)',
          '0.0',
          '0.0',
          '10.0',
          'Analog I/O'
        ],
        [
          '1302',
          'AI1 Max',
          'AI1 maximum input (V or mA)',
          '10.0',
          '0.0',
          '10.0',
          'Analog I/O'
        ],
        [
          '1601',
          'Run Enable',
          '0=Stop, 1=Run enabled (DI source)',
          '1',
          '0',
          '1',
          'Control'
        ],
        [
          '1604',
          'Fault Reset Select',
          'Source for fault reset command',
          '1',
          '0',
          '12',
          'Control'
        ],
        [
          '3001',
          'Auto Restart Tries',
          'Number of automatic restart attempts',
          '0',
          '0',
          '5',
          'Protection'
        ],
      ]);
    }

    // ── ACS150 ───────────────────────────────────────────────────────
    // Multiple rows exist for ACS150 — seed first occurrence only
    final acs150Rows = await db.query('vfd_models',
        where: 'name = ?', whereArgs: ['ACS150'], limit: 1);
    if (acs150Rows.isNotEmpty) {
      await seedIfEmpty(acs150Rows.first['id'] as int, [
        [
          '9904',
          'Motor Ctrl Mode',
          '1=Scalar (V/Hz)',
          '1',
          '1',
          '1',
          'Motor Setup'
        ],
        [
          '9905',
          'Motor Nominal Voltage',
          'Motor nameplate voltage (V)',
          '230',
          '1',
          '500',
          'Motor Setup'
        ],
        [
          '9906',
          'Motor Nominal Current',
          'Motor nameplate current (A)',
          '1.5',
          '0.0',
          '6400.0',
          'Motor Setup'
        ],
        [
          '9907',
          'Motor Nominal Frequency',
          'Motor nameplate frequency (Hz)',
          '50.0',
          '10.0',
          '500.0',
          'Motor Setup'
        ],
        [
          '9908',
          'Motor Nominal Speed',
          'Motor nameplate speed (RPM)',
          '1450',
          '1',
          '18000',
          'Motor Setup'
        ],
        [
          '2001',
          'Min Freq',
          'Minimum output frequency (Hz)',
          '0.0',
          '0.0',
          '500.0',
          'Limits'
        ],
        [
          '2002',
          'Max Freq',
          'Maximum output frequency (Hz)',
          '50.0',
          '0.0',
          '500.0',
          'Limits'
        ],
        [
          '2202',
          'Accel Time 1',
          'Acceleration time (s)',
          '30.0',
          '0.1',
          '1800.0',
          'Ramp'
        ],
        [
          '2203',
          'Decel Time 1',
          'Deceleration time (s)',
          '30.0',
          '0.1',
          '1800.0',
          'Ramp'
        ],
        [
          '1001',
          'Ext1 Strt/Stp/Dir',
          'Start/stop source selection',
          '1',
          '0',
          '12',
          'Start/Stop'
        ],
        [
          '1301',
          'AI1 Min',
          'AI1 minimum input value',
          '0.0',
          '0.0',
          '10.0',
          'Analog I/O'
        ],
        [
          '1302',
          'AI1 Max',
          'AI1 maximum input value',
          '10.0',
          '0.0',
          '10.0',
          'Analog I/O'
        ],
        ['1601', 'Run Enable', 'Run enable source', '1', '0', '1', 'Control'],
        [
          '3001',
          'Auto Restart Tries',
          'Auto restart attempts on fault',
          '0',
          '0',
          '5',
          'Protection'
        ],
      ]);
    }

    // ── ACS380 ───────────────────────────────────────────────────────
    final acs380Rows = await db.query('vfd_models',
        where: 'name = ?', whereArgs: ['ACS380'], limit: 1);
    if (acs380Rows.isNotEmpty) {
      await seedIfEmpty(acs380Rows.first['id'] as int, [
        [
          '99.04',
          'Motor Ctrl Mode',
          '0=Scalar, 1=Vector',
          '0',
          '0',
          '1',
          'Start-up Data'
        ],
        [
          '99.06',
          'Motor Nominal Current',
          'Motor nameplate current (A)',
          '2.0',
          '0.0',
          '6400.0',
          'Start-up Data'
        ],
        [
          '99.07',
          'Motor Nominal Voltage',
          'Motor nameplate voltage (V)',
          '230',
          '1',
          '500',
          'Start-up Data'
        ],
        [
          '99.08',
          'Motor Nominal Frequency',
          'Motor nameplate frequency (Hz)',
          '50.0',
          '8.0',
          '300.0',
          'Start-up Data'
        ],
        [
          '99.09',
          'Motor Nominal Speed',
          'Motor nameplate speed (RPM)',
          '1450',
          '1',
          '18000',
          'Start-up Data'
        ],
        [
          '99.10',
          'Motor Nominal Power',
          'Motor nameplate power (kW)',
          '0.75',
          '0.0',
          '10000.0',
          'Start-up Data'
        ],
        [
          '30.11',
          'Minimum Speed',
          'Minimum speed limit (RPM)',
          '0',
          '-18000',
          '18000',
          'Limits'
        ],
        [
          '30.12',
          'Maximum Speed',
          'Maximum speed limit (RPM)',
          '1500',
          '-18000',
          '18000',
          'Limits'
        ],
        [
          '30.17',
          'Maximum Current',
          'Maximum output current (A)',
          '5.0',
          '0.0',
          '6400.0',
          'Limits'
        ],
        [
          '23.12',
          'Acceleration Time 1',
          'Acceleration ramp time (s)',
          '20.0',
          '0.0',
          '1800.0',
          'Ramp'
        ],
        [
          '23.13',
          'Deceleration Time 1',
          'Deceleration ramp time (s)',
          '20.0',
          '0.0',
          '1800.0',
          'Ramp'
        ],
        [
          '20.01',
          'Ext1 Commands',
          'EXT1 start/stop source',
          '1',
          '0',
          '5',
          'Start/Stop'
        ],
        [
          '96.04',
          'Macro Select',
          '0=Factory, 1=Hand/Auto',
          '0',
          '0',
          '3',
          'Configuration'
        ],
        [
          '31.11',
          'Auto Fault Reset',
          '0=Disabled, 1=Enabled',
          '0',
          '0',
          '1',
          'Protection'
        ],
      ]);
    }

    // ── ACS480 ───────────────────────────────────────────────────────
    final acs480Rows = await db.query('vfd_models',
        where: 'name = ?', whereArgs: ['ACS480'], limit: 1);
    if (acs480Rows.isNotEmpty) {
      await seedIfEmpty(acs480Rows.first['id'] as int, [
        [
          '99.04',
          'Motor Ctrl Mode',
          '0=Scalar, 1=Vector',
          '0',
          '0',
          '1',
          'Start-up Data'
        ],
        [
          '99.06',
          'Motor Nominal Current',
          'Motor nameplate current (A)',
          '4.0',
          '0.0',
          '6400.0',
          'Start-up Data'
        ],
        [
          '99.07',
          'Motor Nominal Voltage',
          'Motor nameplate voltage (V)',
          '400',
          '1',
          '690',
          'Start-up Data'
        ],
        [
          '99.08',
          'Motor Nominal Frequency',
          'Motor nameplate frequency (Hz)',
          '50.0',
          '8.0',
          '300.0',
          'Start-up Data'
        ],
        [
          '99.09',
          'Motor Nominal Speed',
          'Motor nameplate speed (RPM)',
          '1450',
          '1',
          '18000',
          'Start-up Data'
        ],
        [
          '99.10',
          'Motor Nominal Power',
          'Motor nameplate power (kW)',
          '1.5',
          '0.0',
          '10000.0',
          'Start-up Data'
        ],
        [
          '30.11',
          'Minimum Speed',
          'Minimum speed limit (RPM)',
          '0',
          '-18000',
          '18000',
          'Limits'
        ],
        [
          '30.12',
          'Maximum Speed',
          'Maximum speed limit (RPM)',
          '1500',
          '-18000',
          '18000',
          'Limits'
        ],
        [
          '30.17',
          'Maximum Current',
          'Maximum output current (A)',
          '7.0',
          '0.0',
          '6400.0',
          'Limits'
        ],
        [
          '23.12',
          'Acceleration Time 1',
          'Acceleration ramp time (s)',
          '20.0',
          '0.0',
          '1800.0',
          'Ramp'
        ],
        [
          '23.13',
          'Deceleration Time 1',
          'Deceleration ramp time (s)',
          '20.0',
          '0.0',
          '1800.0',
          'Ramp'
        ],
        [
          '20.01',
          'Ext1 Commands',
          'EXT1 start/stop source',
          '1',
          '0',
          '5',
          'Start/Stop'
        ],
        [
          '96.04',
          'Macro Select',
          '0=Factory, 1=Hand/Auto, 2=PID',
          '0',
          '0',
          '4',
          'Configuration'
        ],
        [
          '96.06',
          'Factory Reset',
          '62=Restore factory defaults',
          '0',
          '0',
          '62',
          'Configuration'
        ],
        [
          '31.11',
          'Auto Fault Reset',
          '0=Disabled, 1=Enabled',
          '0',
          '0',
          '1',
          'Protection'
        ],
      ]);
    }

    // ── ACS850 ───────────────────────────────────────────────────────
    final acs850Rows = await db.query('vfd_models',
        where: 'name = ?', whereArgs: ['ACS850'], limit: 1);
    if (acs850Rows.isNotEmpty) {
      await seedIfEmpty(acs850Rows.first['id'] as int, [
        [
          '99.04',
          'Motor Ctrl Mode',
          '0=DTC, 1=Scalar',
          '0',
          '0',
          '1',
          'Start-up Data'
        ],
        [
          '99.06',
          'Motor Nominal Current',
          'Motor nameplate current (A)',
          '12.0',
          '0.0',
          '6400.0',
          'Start-up Data'
        ],
        [
          '99.07',
          'Motor Nominal Voltage',
          'Motor nameplate voltage (V)',
          '400',
          '1',
          '690',
          'Start-up Data'
        ],
        [
          '99.08',
          'Motor Nominal Frequency',
          'Motor nameplate frequency (Hz)',
          '50.0',
          '8.0',
          '300.0',
          'Start-up Data'
        ],
        [
          '99.09',
          'Motor Nominal Speed',
          'Motor nameplate speed (RPM)',
          '1450',
          '1',
          '18000',
          'Start-up Data'
        ],
        [
          '99.10',
          'Motor Nominal Power',
          'Motor nameplate power (kW)',
          '5.5',
          '0.0',
          '10000.0',
          'Start-up Data'
        ],
        [
          '30.11',
          'Minimum Speed',
          'Minimum speed limit (RPM)',
          '0',
          '-18000',
          '18000',
          'Limits'
        ],
        [
          '30.12',
          'Maximum Speed',
          'Maximum speed limit (RPM)',
          '1500',
          '-18000',
          '18000',
          'Limits'
        ],
        [
          '30.17',
          'Maximum Current',
          'Maximum output current (A)',
          '15.0',
          '0.0',
          '6400.0',
          'Limits'
        ],
        [
          '23.12',
          'Acceleration Time 1',
          'Acceleration ramp time (s)',
          '20.0',
          '0.0',
          '1800.0',
          'Ramp'
        ],
        [
          '23.13',
          'Deceleration Time 1',
          'Deceleration ramp time (s)',
          '20.0',
          '0.0',
          '1800.0',
          'Ramp'
        ],
        [
          '22.11',
          'Speed Ref 1 Source',
          '0=Zero, 1=AI1, 2=AI2, 3=Fieldbus',
          '1',
          '0',
          '3',
          'Speed Reference'
        ],
        [
          '20.01',
          'Ext1 Commands',
          'EXT1 start/stop source',
          '1',
          '0',
          '5',
          'Start/Stop'
        ],
        [
          '96.04',
          'Macro Select',
          '0=Factory, 1=Hand/Auto, 2=PID',
          '0',
          '0',
          '4',
          'Configuration'
        ],
        [
          '31.11',
          'Auto Fault Reset',
          '0=Disabled, 1=Enabled',
          '0',
          '0',
          '1',
          'Protection'
        ],
      ]);
    }
  }

  Future<void> _seedAbbManualLinks(Database db) async {
    // Get ABB vendor ID
    final abbVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['ABB'],
    );
    if (abbVendorRows.isEmpty) return;
    final abbId = abbVendorRows.first['id'] as int;

    for (final link in AbbManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [abbId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedSchneiderManualLinks(Database db) async {
    final schneiderVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['Schneider'],
    );
    if (schneiderVendorRows.isEmpty) return;
    final schneiderId = schneiderVendorRows.first['id'] as int;

    for (final link in SchneiderManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [schneiderId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedParkerManualLinks(Database db) async {
    final parkerVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['Parker'],
    );
    if (parkerVendorRows.isEmpty) return;
    final parkerId = parkerVendorRows.first['id'] as int;

    for (final link in ParkerManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [parkerId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedYaskawaManualLinks(Database db) async {
    final yaskawaVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['Yaskawa'],
    );
    if (yaskawaVendorRows.isEmpty) return;
    final yaskawaId = yaskawaVendorRows.first['id'] as int;

    for (final link in YaskawaManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [yaskawaId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedDanfossManualLinks(Database db) async {
    final danfossVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['Danfoss'],
    );
    if (danfossVendorRows.isEmpty) return;
    final danfossId = danfossVendorRows.first['id'] as int;

    for (final link in DanfossManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [danfossId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedDeltaManualLinks(Database db) async {
    final deltaVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['Delta'],
    );
    if (deltaVendorRows.isEmpty) return;
    final deltaId = deltaVendorRows.first['id'] as int;

    for (final link in DeltaManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [deltaId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedFujiManualLinks(Database db) async {
    final fujiVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['Fuji'],
    );
    if (fujiVendorRows.isEmpty) return;
    final fujiId = fujiVendorRows.first['id'] as int;

    for (final link in FujiManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [fujiId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedHitachiManualLinks(Database db) async {
    final hitachiVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['Hitachi'],
    );
    if (hitachiVendorRows.isEmpty) return;
    final hitachiId = hitachiVendorRows.first['id'] as int;

    for (final link in HitachiManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [hitachiId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedMitsubishiManualLinks(Database db) async {
    final mitsubishiVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['Mitsubishi'],
    );
    if (mitsubishiVendorRows.isEmpty) return;
    final mitsubishiId = mitsubishiVendorRows.first['id'] as int;

    for (final link in MitsubishiManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [mitsubishiId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedNidecManualLinks(Database db) async {
    final nidecVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['Nidec'],
    );
    if (nidecVendorRows.isEmpty) return;
    final nidecId = nidecVendorRows.first['id'] as int;

    for (final link in NidecManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [nidecId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedToshibaManualLinks(Database db) async {
    final toshibaVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['Toshiba'],
    );
    if (toshibaVendorRows.isEmpty) return;
    final toshibaId = toshibaVendorRows.first['id'] as int;

    for (final link in ToshibaManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [toshibaId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedWegManualLinks(Database db) async {
    final wegVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['WEG'],
    );
    if (wegVendorRows.isEmpty) return;
    final wegId = wegVendorRows.first['id'] as int;

    for (final link in WEGManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [wegId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedLsManualLinks(Database db) async {
    final lsVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['LS'],
    );
    if (lsVendorRows.isEmpty) return;
    final lsId = lsVendorRows.first['id'] as int;

    for (final link in LSManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [lsId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedLenzeManualLinks(Database db) async {
    final lenzeVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['Lenze'],
    );
    if (lenzeVendorRows.isEmpty) return;
    final lenzeId = lenzeVendorRows.first['id'] as int;

    for (final link in LenzeManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [lenzeId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedOmronManualLinks(Database db) async {
    final omronVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['Omron'],
    );
    if (omronVendorRows.isEmpty) return;
    final omronId = omronVendorRows.first['id'] as int;

    for (final link in OmronManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [omronId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedInovanceManualLinks(Database db) async {
    final inovanceVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['Inovance'],
    );
    if (inovanceVendorRows.isEmpty) return;
    final inovanceId = inovanceVendorRows.first['id'] as int;

    for (final link in InovanceManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [inovanceId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedInvtManualLinks(Database db) async {
    final invtVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['INVT'],
    );
    if (invtVendorRows.isEmpty) return;
    final invtId = invtVendorRows.first['id'] as int;

    for (final link in INVTManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [invtId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedKebManualLinks(Database db) async {
    final kebVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['KEB'],
    );
    if (kebVendorRows.isEmpty) return;
    final kebId = kebVendorRows.first['id'] as int;

    for (final link in KEBManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [kebId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _seedLtManualLinks(Database db) async {
    final ltVendorRows = await db.query(
      'vendors',
      where: 'name = ?',
      whereArgs: ['L&T'],
    );
    if (ltVendorRows.isEmpty) return;
    final ltId = ltVendorRows.first['id'] as int;

    for (final link in LTManualLinks.all) {
      final modelRows = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ?',
        whereArgs: [ltId, link.modelName],
        limit: 1,
      );
      if (modelRows.isEmpty) continue;
      final modelId = modelRows.first['id'] as int;

      await db.update(
        'vfd_manuals',
        {'filePath': link.url},
        where: 'modelId = ? AND manualType = ? AND filePath = ?',
        whereArgs: [modelId, link.manualType, ''],
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await _createSchema(db);
    await _seedIfEmpty(db);
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS vendors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        logo TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS vfd_models (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vendorId INTEGER NOT NULL,
        name TEXT NOT NULL,
        series TEXT,
        description TEXT,
        powerRating REAL,
        voltage TEXT,
        FOREIGN KEY (vendorId) REFERENCES vendors (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS vfd_parameters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        modelId INTEGER NOT NULL,
        paramCode TEXT NOT NULL,
        paramName TEXT NOT NULL,
        description TEXT,
        defaultValue TEXT,
        minValue TEXT,
        maxValue TEXT,
        groupName TEXT,
        FOREIGN KEY (modelId) REFERENCES vfd_models (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS vfd_manuals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        modelId INTEGER NOT NULL,
        title TEXT NOT NULL,
        manualType TEXT NOT NULL,
        filePath TEXT,
        language TEXT,
        version INTEGER,
        FOREIGN KEY (modelId) REFERENCES vfd_models (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS protocols (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vendorId INTEGER NOT NULL,
        modelId INTEGER,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        commCard TEXT,
        FOREIGN KEY (vendorId) REFERENCES vendors (id),
        FOREIGN KEY (modelId) REFERENCES vfd_models (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS protocol_parameters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        protocolId INTEGER NOT NULL,
        paramCode TEXT NOT NULL,
        paramName TEXT NOT NULL,
        description TEXT,
        defaultValue TEXT,
        minValue TEXT,
        maxValue TEXT,
        groupName TEXT,
        FOREIGN KEY (protocolId) REFERENCES protocols (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS vfd_drawings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        modelId INTEGER NOT NULL,
        name TEXT NOT NULL,
        filePath TEXT,
        fileType TEXT,
        uploadedAt TEXT NOT NULL,
        FOREIGN KEY (modelId) REFERENCES vfd_models (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS fault_codes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vendorId TEXT NOT NULL,
        errorCode TEXT NOT NULL,
        description TEXT NOT NULL,
        solution TEXT NOT NULL,
        severity TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS parameter_values (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parameterId INTEGER NOT NULL,
        modelId INTEGER NOT NULL,
        value TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (parameterId) REFERENCES vfd_parameters (id),
        FOREIGN KEY (modelId) REFERENCES vfd_models (id)
      )
    ''');
  }

  Future<void> _seedIfEmpty(Database db) async {
    final existingVendors = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM vendors'),
    );

    if ((existingVendors ?? 0) == 0) {
      await insertSampleData(db);
      await _seedStandardRatings(db);
      await _seedVendorModels(db);
      await _seedFaultCodes(db);
      await _seedAbbManualLinks(db);
      await _seedSchneiderManualLinks(db);
      await _seedParkerManualLinks(db);
      await _seedYaskawaManualLinks(db);
      await _seedDanfossManualLinks(db);
      await _seedDeltaManualLinks(db);
      await _seedFujiManualLinks(db);
      await _seedHitachiManualLinks(db);
      await _seedMitsubishiManualLinks(db);
      await _seedNidecManualLinks(db);
      await _seedToshibaManualLinks(db);
      await _seedWegManualLinks(db);
      await _seedLsManualLinks(db);
      await _seedLenzeManualLinks(db);
      await _seedOmronManualLinks(db);
      await _seedInovanceManualLinks(db);
      await _seedInvtManualLinks(db);
      await _seedKebManualLinks(db);
      await _seedLtManualLinks(db);
    }
  }

  Future<void> _seedStandardRatings(Database db) async {
    final vendorRows = await db.query('vendors', columns: ['id', 'name']);
    for (final row in vendorRows) {
      final vendorId = row['id'] as int;
      final vendorName = row['name'] as String;
      final ratingList = VendorRatingsData.ratings[vendorName];
      if (ratingList == null) continue;

      final seriesName =
          VendorRatingsData.vendorSeriesName[vendorName] ?? 'Standard Range';

      // Per-vendor check — skip only if THIS vendor already has its Range model
      final alreadySeeded = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM vfd_models WHERE vendorId = ? AND name = ?',
        [vendorId, seriesName],
      ));
      if ((alreadySeeded ?? 0) > 0) continue;

      for (final entry in ratingList) {
        final voltages = VendorRatingsData.voltagesForKw(entry.kw);
        for (final voltage in voltages) {
          await db.insert('vfd_models', {
            'vendorId': vendorId,
            'name': seriesName,
            'series': seriesName,
            'description': '${entry.note} — ${entry.kw} kW / ${entry.hp} HP',
            'powerRating': entry.kw,
            'voltage': voltage,
          });
        }
      }
    }
  }

  Future<void> _seedVendorModels(Database db) async {
    final vendorRows = await db.query('vendors', columns: ['id', 'name']);
    for (final row in vendorRows) {
      final vendorId = row['id'] as int;
      final vendorName = row['name'] as String;
      final modelList = VendorModelsData.models[vendorName];
      if (modelList == null) continue;

      final allVendorRatings = VendorRatingsData.ratings[vendorName] ?? [];

      for (final modelInfo in modelList) {
        // Check if model already exists
        final existing = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM vfd_models WHERE vendorId=? AND name=?',
          [vendorId, modelInfo.name],
        ));
        if ((existing ?? 0) > 0) continue;

        // Filter vendor ratings to this model's power range
        final applicableRatings = allVendorRatings
            .where((r) => r.kw >= modelInfo.minKw && r.kw <= modelInfo.maxKw)
            .toList();

        if (applicableRatings.isEmpty) {
          // Seed at least one entry with min kW if no ratings match
          final voltages = VendorRatingsData.voltagesForKw(modelInfo.minKw);
          for (final voltage in voltages) {
            await db.insert('vfd_models', {
              'vendorId': vendorId,
              'name': modelInfo.name,
              'series': modelInfo.series,
              'description': modelInfo.description,
              'powerRating': modelInfo.minKw,
              'voltage': voltage,
            });
          }
        } else {
          for (final entry in applicableRatings) {
            final voltages = VendorRatingsData.voltagesForKw(entry.kw);
            for (final voltage in voltages) {
              await db.insert('vfd_models', {
                'vendorId': vendorId,
                'name': modelInfo.name,
                'series': modelInfo.series,
                'description': modelInfo.description,
                'powerRating': entry.kw,
                'voltage': voltage,
              });
            }
          }
        }

        // Seed empty manual entries for this model
        final modelId = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT id FROM vfd_models WHERE vendorId=? AND name=? LIMIT 1',
          [vendorId, modelInfo.name],
        ));
        if (modelId != null) {
          for (final manualType in VendorModelsData.defaultManualTypes) {
            await db.insert('vfd_manuals', {
              'modelId': modelId,
              'title': '${modelInfo.name} $manualType',
              'manualType': manualType,
              'filePath': '',
              'language': 'English',
              'version': 1,
            });
          }
        }
      }
    }
  }

  Future<void> _seedFaultCodes(Database db) async {
    for (final faultData in FaultCodesData.defaultFaultCodes) {
      await db.insert('fault_codes', faultData);
    }
  }

  Future<void> insertSampleData(Database db) async {
    // ── Vendors (from click2electro.com) ──────────────────────────────
    final int deltaId = await db.insert('vendors', {
      'name': 'Delta',
      'logo':
          'https://www.delta.com.tw/en/wp-content/uploads/2023/04/delta-logo-white.png',
      'description': 'Delta Electronics VFD Drives'
    });
    final int siemensId = await db.insert('vendors', {
      'name': 'Siemens',
      'logo':
          'https://upload.wikimedia.org/wikipedia/commons/5/5f/Siemens-logo.svg',
      'description': 'Siemens Variable Frequency Drives'
    });
    final int abbId = await db.insert('vendors', {
      'name': 'ABB',
      'logo':
          'https://upload.wikimedia.org/wikipedia/commons/4/4b/ABB_logo.svg',
      'description': 'ABB ACS Series VFD'
    });
    final int schneiderId = await db.insert('vendors', {
      'name': 'Schneider',
      'logo':
          'https://upload.wikimedia.org/wikipedia/commons/3/3c/Schneider_Electric_logo.svg',
      'description': 'Schneider Altivar VFD'
    });
    final int hitachiId = await db.insert('vendors', {
      'name': 'Hitachi',
      'logo':
          'https://upload.wikimedia.org/wikipedia/commons/f/ff/Hitachi_logo.svg',
      'description': 'Hitachi WJ & SJ Series VFD'
    });
    final int mitsubishiId = await db.insert('vendors', {
      'name': 'Mitsubishi',
      'logo':
          'https://upload.wikimedia.org/wikipedia/commons/5/5c/Mitsubishi_Electric_logo.svg',
      'description': 'Mitsubishi FR Series VFD'
    });
    final int yaskawaId = await db.insert('vendors', {
      'name': 'Yaskawa',
      'logo':
          'https://upload.wikimedia.org/wikipedia/commons/3/3d/YASKAWA_ELETRIC_CORPORATION_logo.svg',
      'description': 'Yaskawa AC Drive Series'
    });
    final int danfossId = await db.insert('vendors', {
      'name': 'Danfoss',
      'logo': '',
      'description': 'Danfoss VLT Series VFD'
    });
    final int allenBradleyId = await db.insert('vendors', {
      'name': 'Allen Bradley',
      'logo': '',
      'description': 'Allen Bradley PowerFlex VFD'
    });
    final int toshibaId = await db.insert('vendors', {
      'name': 'Toshiba',
      'logo': '',
      'description': 'Toshiba VF-AS Series VFD'
    });
    final int wegId = await db.insert('vendors',
        {'name': 'WEG', 'logo': '', 'description': 'WEG CFW Series VFD'});
    final int lsId = await db.insert('vendors',
        {'name': 'LS', 'logo': '', 'description': 'LS iG5A iV5A VFD'});
    final int lenzeId = await db.insert('vendors',
        {'name': 'Lenze', 'logo': '', 'description': 'Lenze i700 i500 VFD'});
    final int omronId = await db.insert('vendors',
        {'name': 'Omron', 'logo': '', 'description': 'Omron MX2 VFD'});
    final int inovanceId = await db.insert('vendors', {
      'name': 'Inovance',
      'logo': '',
      'description': 'Inovance HV Series VFD'
    });
    final int invtId = await db.insert('vendors',
        {'name': 'INVT', 'logo': '', 'description': 'INVT GD Series VFD'});
    final int kebId = await db.insert('vendors',
        {'name': 'KEB', 'logo': '', 'description': 'KEB COMBIVERT VFD'});
    final int parkerId = await db.insert('vendors', {
      'name': 'Parker',
      'logo': '',
      'description': 'Parker AC Drive Series'
    });
    final int fujiId = await db.insert('vendors',
        {'name': 'Fuji', 'logo': '', 'description': 'Fuji FRENIC-Mini VFD'});
    final int ltId = await db.insert('vendors',
        {'name': 'L&T', 'logo': '', 'description': 'L&T Type 2 VFD'});
    final int nidecId = await db.insert('vendors', {
      'name': 'Nidec',
      'logo': '',
      'description': 'Nidec Control Techniques VFD'
    });

    // ── Delta Models ─────────────────────────────────────────────────
    // VFD-S variants
    final int vfdSId = await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-S',
      'series': 'S Series',
      'description': 'Compact Low-Cost General-Purpose AC Motor Drive',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-S',
      'series': 'S Series',
      'description': 'Compact Low-Cost General-Purpose AC Motor Drive',
      'powerRating': 1.5,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-S',
      'series': 'S Series',
      'description': 'Compact Low-Cost General-Purpose AC Motor Drive',
      'powerRating': 2.2,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-S',
      'series': 'S Series',
      'description': 'Compact Low-Cost General-Purpose AC Motor Drive',
      'powerRating': 0.75,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-S',
      'series': 'S Series',
      'description': 'Compact Low-Cost General-Purpose AC Motor Drive',
      'powerRating': 1.5,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-S',
      'series': 'S Series',
      'description': 'Compact Low-Cost General-Purpose AC Motor Drive',
      'powerRating': 2.2,
      'voltage': '380V'
    });

    // VFD-L variants
    final int vfdLId = await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-L',
      'series': 'L Series',
      'description': 'Pump and Fan Application VFD',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-L',
      'series': 'L Series',
      'description': 'Pump and Fan Application VFD',
      'powerRating': 1.5,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-L',
      'series': 'L Series',
      'description': 'Pump and Fan Application VFD',
      'powerRating': 0.75,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-L',
      'series': 'L Series',
      'description': 'Pump and Fan Application VFD',
      'powerRating': 1.5,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-L',
      'series': 'L Series',
      'description': 'Pump and Fan Application VFD',
      'powerRating': 2.2,
      'voltage': '380V'
    });

    // VFD-E variants
    final int vfdEId = await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-E',
      'series': 'E Series',
      'description': 'High-Performance General Purpose VFD',
      'powerRating': 1.5,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-E',
      'series': 'E Series',
      'description': 'High-Performance General Purpose VFD',
      'powerRating': 2.2,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-E',
      'series': 'E Series',
      'description': 'High-Performance General Purpose VFD',
      'powerRating': 3.7,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-E',
      'series': 'E Series',
      'description': 'High-Performance General Purpose VFD',
      'powerRating': 1.5,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-E',
      'series': 'E Series',
      'description': 'High-Performance General Purpose VFD',
      'powerRating': 2.2,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-E',
      'series': 'E Series',
      'description': 'High-Performance General Purpose VFD',
      'powerRating': 3.7,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-E',
      'series': 'E Series',
      'description': 'High-Performance General Purpose VFD',
      'powerRating': 5.5,
      'voltage': '380V'
    });
    final int vfdMId = await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-M',
      'series': 'M Series',
      'description': 'Mini Compact VFD for Simple Applications',
      'powerRating': 0.4,
      'voltage': '230V'
    });
    final int vfdC200Id = await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-C200',
      'series': 'C200 Series',
      'description': 'Closed-Loop Vector Control Drive',
      'powerRating': 3.7,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-VJ',
      'series': 'VJ Series',
      'description': 'Jet Pump Controller',
      'powerRating': 2.2,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'CH2000',
      'series': 'CH2000 Series',
      'description': 'Heavy Duty VFD for Crane and Hoist',
      'powerRating': 7.5,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-VE',
      'series': 'VE Series',
      'description': 'High Performance Vector Control VFD',
      'powerRating': 3.7,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'CT2000',
      'series': 'CT2000 Series',
      'description': 'Cement Industry VFD',
      'powerRating': 11.0,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'CPF2000 PLUS',
      'series': 'CPF2000 Series',
      'description': 'Plus Series Compressor VFD',
      'powerRating': 5.5,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'CP2000',
      'series': 'CP2000 Series',
      'description': 'HVAC Pump Fan VFD',
      'powerRating': 4.0,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'IED',
      'series': 'IED Series',
      'description': 'Integrated Drive for Elevator',
      'powerRating': 7.5,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'ME300',
      'series': 'ME300 Series',
      'description': 'Compact General Purpose VFD',
      'powerRating': 2.2,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'MH300',
      'series': 'MH300 Series',
      'description': 'High Performance Compact VFD',
      'powerRating': 2.2,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'MS300',
      'series': 'MS300 Series',
      'description': 'Standard Compact VFD',
      'powerRating': 1.5,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'REG2000',
      'series': 'REG2000 Series',
      'description': 'Regenerative Drive',
      'powerRating': 5.5,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-B',
      'series': 'B Series',
      'description': 'General Purpose VFD',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-EL',
      'series': 'EL Series',
      'description': 'Economical Mini VFD',
      'powerRating': 0.4,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-ED',
      'series': 'ED Series',
      'description': 'Elevator Door VFD',
      'powerRating': 1.5,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-EL-W',
      'series': 'EL-W Series',
      'description': 'Water Pump VFD',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'VFD-V',
      'series': 'V Series',
      'description': 'Vector Control VFD',
      'powerRating': 2.2,
      'voltage': '380V'
    });

    // ── Additional Delta Servo Drives ─────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'ASDA-A3',
      'series': 'ASDA-A3 Series',
      'description': 'High Performance Servo Drive',
      'powerRating': 1.5,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'ASDA-A2',
      'series': 'ASDA-A2 Series',
      'description': 'Advanced Servo Drive',
      'powerRating': 1.5,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'ASDA-B2',
      'series': 'ASDA-B2 Series',
      'description': 'Economical Servo Drive',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': deltaId,
      'name': 'ASDA-B3',
      'series': 'ASDA-B3 Series',
      'description': 'Standard Servo Drive',
      'powerRating': 0.75,
      'voltage': '230V'
    });

    // ── Siemens Models ───────────────────────────────────────────
    final int sed2Id = await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'SED2',
      'series': 'SED2',
      'description': 'Siemens SED2 Variable Frequency Drive for HVAC',
      'powerRating': 0.5,
      'voltage': '380V'
    });
    final int g120Id = await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'SINAMICS G120',
      'series': 'G120',
      'description': 'Modular Drive System for Pumps, Fans, Compressors',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    final int mm440Id = await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'MICROMASTER 440',
      'series': 'MM440',
      'description': 'Universal Inverter for Complex Drive Tasks',
      'powerRating': 7.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'SINAMICS G120P',
      'series': 'G120P',
      'description': 'Drive for Pumps, Fans and Compressors',
      'powerRating': 3.0,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'SINAMICS V20',
      'series': 'V20',
      'description': 'Basic Performance Drive',
      'powerRating': 0.75,
      'voltage': '380V'
    });

    // ── ABB Models ───────────────────────────────────────────────
    final int acs550Id = await db.insert('vfd_models', {
      'vendorId': abbId,
      'name': 'ACS550',
      'series': 'ACS550',
      'description': 'General Purpose Drive for HVAC and Water/Wastewater',
      'powerRating': 4.0,
      'voltage': '400V'
    });
    final int acs310Id = await db.insert('vfd_models', {
      'vendorId': abbId,
      'name': 'ACS310',
      'series': 'ACS310',
      'description': 'Dedicated Drive for Pump and Fan Applications',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': abbId,
      'name': 'ACS580',
      'series': 'ACS580',
      'description': 'General Purpose ABB Drive',
      'powerRating': 4.0,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': abbId,
      'name': 'ACS355',
      'series': 'ACS355',
      'description': 'Micro Drive for Simple Machines',
      'powerRating': 0.75,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': abbId,
      'name': 'ACS880',
      'series': 'ACS880',
      'description': 'Industrial Drive for All Applications',
      'powerRating': 15.0,
      'voltage': '400V'
    });

    // ── Schneider Models ─────────────────────────────────────────
    final int atv312Id = await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV312',
      'series': 'Altivar 312',
      'description': 'Simple Drive for Simple Machines',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    final int atv630Id = await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV630',
      'series': 'Altivar Process 630',
      'description': 'Process Drive for Pump, Fan, Compressor',
      'powerRating': 15.0,
      'voltage': '400V'
    });
    final int atv320Id = await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV320',
      'series': 'Altivar 320',
      'description': 'Variable Speed Drive for Machines',
      'powerRating': 1.5,
      'voltage': '380V'
    });
    final int atv340Id = await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV340',
      'series': 'Altivar 340',
      'description': 'High Performance Drive for Machines',
      'powerRating': 4.0,
      'voltage': '380V'
    });
    final int atv610Id = await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV610',
      'series': 'Altivar Process 610',
      'description': 'Advanced Process Drive',
      'powerRating': 7.5,
      'voltage': '400V'
    });

    // ── Hitachi Models ───────────────────────────────────────────
    final int wj200Id = await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'WJ200',
      'series': 'WJ200',
      'description': 'Compact Sensorless Vector Drive',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    final int sj700Id = await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'SJ700',
      'series': 'SJ700',
      'description': 'High-Performance Sensorless Vector Drive',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'SJ100',
      'series': 'SJ100',
      'description': 'Standard VFD for General Application',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'P300',
      'series': 'P300',
      'description': 'High Performance Vector Drive',
      'powerRating': 5.5,
      'voltage': '380V'
    });

    // ── Mitsubishi Models ────────────────────────────────────────
    final int frD700Id = await db.insert('vfd_models', {
      'vendorId': mitsubishiId,
      'name': 'FR-D700',
      'series': 'D700',
      'description': 'Compact Economical Inverter',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    final int frE700Id = await db.insert('vfd_models', {
      'vendorId': mitsubishiId,
      'name': 'FR-E700',
      'series': 'E700',
      'description': 'Advanced Sensorless Vector Inverter',
      'powerRating': 2.2,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': mitsubishiId,
      'name': 'FR-A700',
      'series': 'A700',
      'description': 'High Performance Vector Control Inverter',
      'powerRating': 5.5,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': mitsubishiId,
      'name': 'FR-F700',
      'series': 'F700',
      'description': 'HVAC Inverter for Fan Pump',
      'powerRating': 4.0,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': mitsubishiId,
      'name': 'FR-G7',
      'series': 'G7',
      'description': 'High Performance General Purpose Inverter',
      'powerRating': 5.5,
      'voltage': '380V'
    });

    // ── Yaskawa Models ───────────────────────────────────────────
    final int v1000Id = await db.insert('vfd_models', {
      'vendorId': yaskawaId,
      'name': 'V1000',
      'series': 'V1000',
      'description': 'Compact Vector Control Drive',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    final int a1000Id = await db.insert('vfd_models', {
      'vendorId': yaskawaId,
      'name': 'A1000',
      'series': 'A1000',
      'description': 'High-Performance Vector Control Drive',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': yaskawaId,
      'name': 'J1000',
      'series': 'J1000',
      'description': 'Compact Simple VFD',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': yaskawaId,
      'name': 'D1000',
      'series': 'D1000',
      'description': 'Drive for cranes and hoists',
      'powerRating': 7.5,
      'voltage': '380V'
    });

    // ── Danfoss Models ───────────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'VLT2800',
      'series': 'VLT2800',
      'description': 'VLT Micro Drive',
      'powerRating': 0.75,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'VLT2900',
      'series': 'VLT2900',
      'description': 'VLT HVAC Drive',
      'powerRating': 1.5,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'VLT300',
      'series': 'VLT300',
      'description': 'HVAC Drive FC100',
      'powerRating': 4.0,
      'voltage': '380V'
    });

    // ── Allen Bradley Models ─────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 525',
      'series': 'PowerFlex 525',
      'description': 'Integrated Motion VFD',
      'powerRating': 2.2,
      'voltage': '480V'
    });
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 527',
      'series': 'PowerFlex 527',
      'description': 'Dual Port EtherNet/IP VFD',
      'powerRating': 2.2,
      'voltage': '480V'
    });
    final int powerFlex40Id = await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 40',
      'series': 'PowerFlex 40',
      'description': 'VFD for Commercial Applications',
      'powerRating': 0.75,
      'voltage': '480V'
    });

    // ── Omron Models ─────────────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': omronId,
      'name': 'MX2',
      'series': 'MX2',
      'description': 'High Performance VFD',
      'powerRating': 1.5,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': omronId,
      'name': 'MX3',
      'series': 'MX3',
      'description': 'Advanced Vector VFD',
      'powerRating': 2.2,
      'voltage': '380V'
    });

    // ── Lenze Models ─────────────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': lenzeId,
      'name': 'i500',
      'series': 'i500',
      'description': 'Standard Inverter',
      'powerRating': 2.2,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': lenzeId,
      'name': 'i700',
      'series': 'i700',
      'description': 'Servo Inverter',
      'powerRating': 3.0,
      'voltage': '380V'
    });

    // ── INVT Models ─────────────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': invtId,
      'name': 'GD20',
      'series': 'GD20',
      'description': 'General Purpose VFD',
      'powerRating': 1.5,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': invtId,
      'name': 'GD35',
      'series': 'GD35',
      'description': 'High Performance VFD',
      'powerRating': 4.0,
      'voltage': '380V'
    });

    // ── WEG Models ─────────────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': wegId,
      'name': 'CFW08',
      'series': 'CFW08',
      'description': 'Compact VFD',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': wegId,
      'name': 'CFW300',
      'series': 'CFW300',
      'description': 'General Purpose VFD',
      'powerRating': 1.5,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': wegId,
      'name': 'CFW500',
      'series': 'CFW500',
      'description': 'High Performance VFD',
      'powerRating': 4.0,
      'voltage': '380V'
    });

    // ── LS Models ─────────────────────────────────────────────
    final int ig5AId = await db.insert('vfd_models', {
      'vendorId': lsId,
      'name': 'iG5A',
      'series': 'iG5A',
      'description': 'VFD for General Application',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': lsId,
      'name': 'iV5A',
      'series': 'iV5A',
      'description': 'High Performance VFD',
      'powerRating': 2.2,
      'voltage': '380V'
    });

    // ── Inovance Models ─────────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': inovanceId,
      'name': 'HV100',
      'series': 'HV100',
      'description': 'High Performance VFD',
      'powerRating': 4.0,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': inovanceId,
      'name': 'MD200',
      'series': 'MD200',
      'description': 'Mini VFD',
      'powerRating': 0.75,
      'voltage': '230V'
    });

    // ── Parameters: Delta VFD-S (full set) ───────────────────────
    await _insertParams(db, vfdSId, [
      [
        '00-00',
        'Identity Code',
        'Identity Code of AC Motor Drive',
        'Read-only',
        '',
        '',
        'User Parameters'
      ],
      [
        '00-01',
        'Rated Current',
        'Display Rated Current of the Drive',
        'Read-only',
        '',
        '',
        'User Parameters'
      ],
      [
        '00-02',
        'Parameter Reset',
        'Reset Parameters to Factory Setting',
        '0',
        '0',
        '10',
        'User Parameters'
      ],
      [
        '01-00',
        'Maximum Output Frequency',
        'Maximum Output Frequency Setting',
        '60.0',
        '50.0',
        '400.0',
        'Basic Parameters'
      ],
      [
        '01-01',
        'Maximum Voltage',
        'Maximum Output Voltage',
        '220.0',
        '2.0',
        '255.0',
        'Basic Parameters'
      ],
      [
        '01-02',
        'Mid-Point Frequency',
        'Mid-Point Frequency of V/F Curve',
        '1.5',
        '1.0',
        '400.0',
        'Basic Parameters'
      ],
      [
        '01-03',
        'Mid-Point Voltage',
        'Mid-Point Voltage of V/F Curve',
        '15.0',
        '2.0',
        '255.0',
        'Basic Parameters'
      ],
      [
        '01-04',
        'Minimum Output Frequency',
        'Minimum Output Frequency',
        '1.0',
        '1.0',
        '60.0',
        'Basic Parameters'
      ],
      [
        '01-09',
        'Acceleration Time 1',
        'Time to accelerate from 0 to Max Freq',
        '10.0',
        '0.1',
        '600.0',
        'Basic Parameters'
      ],
      [
        '01-10',
        'Deceleration Time 1',
        'Time to decelerate from Max to 0',
        '10.0',
        '0.1',
        '600.0',
        'Basic Parameters'
      ],
      [
        '02-00',
        'Source of Frequency Command',
        'Frequency Command Source Selection',
        '0',
        '0',
        '5',
        'Operation Method'
      ],
      [
        '02-01',
        'Operation Command Source',
        'Run/Stop Command Source',
        '0',
        '0',
        '4',
        'Operation Method'
      ],
      [
        '02-02',
        'Stop Method',
        'Stop Method Selection (Ramp/Coast)',
        '0',
        '0',
        '2',
        'Operation Method'
      ],
      [
        '06-00',
        'Over-Voltage Stall Prevention',
        'Over-Voltage Stall Prevention Level',
        '390',
        '350',
        '410',
        'Protection Parameters'
      ],
      [
        '06-01',
        'Over-Current Stall Prevention',
        'Over-Current Stall Prevention Level (%)',
        '170',
        '20',
        '200',
        'Protection Parameters'
      ],
    ]);

    // ── Parameters: Delta VFD-L ───────────────────────────────────
    await _insertParams(db, vfdLId, [
      [
        'P0.00',
        'Control Mode',
        'V/F or Sensorless Vector Control',
        '0',
        '0',
        '1',
        'Basic Setup'
      ],
      [
        'P1.00',
        'Max Frequency',
        'Maximum Output Frequency (Hz)',
        '50.0',
        '10.0',
        '400.0',
        'Basic Setup'
      ],
      [
        'P1.01',
        'Rated Motor Frequency',
        'Motor Nameplate Frequency',
        '50.0',
        '10.0',
        '400.0',
        'Motor Parameters'
      ],
      [
        'P1.02',
        'Rated Motor Voltage',
        'Motor Nameplate Voltage (V)',
        '220.0',
        '1.0',
        '500.0',
        'Motor Parameters'
      ],
      [
        'P1.03',
        'Rated Motor Current',
        'Motor Nameplate Current (A)',
        '3.5',
        '0.1',
        '200.0',
        'Motor Parameters'
      ],
      [
        'P2.00',
        'Accel Time',
        'Acceleration Time 0→Max Hz (s)',
        '10.0',
        '0.1',
        '3600.0',
        'Ramp Control'
      ],
      [
        'P2.01',
        'Decel Time',
        'Deceleration Time Max�? Hz (s)',
        '10.0',
        '0.1',
        '3600.0',
        'Ramp Control'
      ],
    ]);

    // ── Parameters: Delta VFD-E ───────────────────────────────────
    await _insertParams(db, vfdEId, [
      [
        '00-00',
        'Drive Model',
        'Displays Drive Model Code',
        'Read-only',
        '',
        '',
        'System'
      ],
      [
        '00-10',
        'Control Mode',
        '0=V/F, 1=Vector without PG, 2=Vector with PG',
        '0',
        '0',
        '2',
        'System'
      ],
      [
        '01-00',
        'Max Output Frequency',
        'Maximum Output Frequency (Hz)',
        '60.0',
        '50.0',
        '400.0',
        'Frequency'
      ],
      [
        '01-01',
        'Base Frequency',
        'Motor Rated Frequency (Hz)',
        '60.0',
        '0.1',
        '400.0',
        'Frequency'
      ],
      [
        '01-08',
        'Accel Time 1',
        'Acceleration Time 1 (s)',
        '10.0',
        '0.01',
        '600.0',
        'Ramp'
      ],
      [
        '01-09',
        'Decel Time 1',
        'Deceleration Time 1 (s)',
        '10.0',
        '0.01',
        '600.0',
        'Ramp'
      ],
      [
        '02-00',
        'Freq Command Source',
        '0=Keypad, 1=Analog, 2=RS485',
        '0',
        '0',
        '5',
        'Command'
      ],
      [
        '04-00',
        'Motor Rated Current',
        'Motor Rated Current (A)',
        '5.0',
        '0.1',
        '600.0',
        'Motor'
      ],
      [
        '04-01',
        'Motor Rated Power',
        'Motor Rated Power (kW)',
        '1.5',
        '0.1',
        '75.0',
        'Motor'
      ],
    ]);

    // ── Parameters: Delta VFD-M ───────────────────────────────────
    await _insertParams(db, vfdMId, [
      [
        'Pr.00',
        'Max Frequency',
        'Maximum Output Frequency (Hz)',
        '60.0',
        '10.0',
        '400.0',
        'Basic'
      ],
      [
        'Pr.01',
        'Min Frequency',
        'Minimum Output Frequency (Hz)',
        '1.0',
        '0.0',
        '20.0',
        'Basic'
      ],
      [
        'Pr.02',
        'Accel Time',
        'Acceleration Time (s)',
        '5.0',
        '0.1',
        '999.9',
        'Basic'
      ],
      [
        'Pr.03',
        'Decel Time',
        'Deceleration Time (s)',
        '5.0',
        '0.1',
        '999.9',
        'Basic'
      ],
      [
        'Pr.04',
        'DC Braking Voltage',
        'DC Injection Braking Voltage (%)',
        '5',
        '0',
        '20',
        'Braking'
      ],
      [
        'Pr.05',
        'DC Braking Time',
        'DC Injection Braking Time (s)',
        '0.5',
        '0.0',
        '25.0',
        'Braking'
      ],
    ]);

    // ── Parameters: Delta VFD-C200 ────────────────────────────────
    await _insertParams(db, vfdC200Id, [
      [
        '00-04',
        'Control Mode',
        '0=V/F, 2=SVC, 3=FOC',
        '0',
        '0',
        '3',
        'Control'
      ],
      [
        '01-00',
        'Max Output Freq',
        'Maximum Output Frequency (Hz)',
        '60.0',
        '0.0',
        '600.0',
        'Frequency'
      ],
      [
        '01-01',
        'Motor Rated Freq',
        'Motor Nameplate Frequency (Hz)',
        '60.0',
        '0.0',
        '600.0',
        'Motor Setup'
      ],
      [
        '01-02',
        'Motor Rated Voltage',
        'Motor Nameplate Voltage (V)',
        '380.0',
        '0.0',
        '480.0',
        'Motor Setup'
      ],
      [
        '01-03',
        'Motor Rated Current',
        'Motor Nameplate Current (A)',
        '8.0',
        '0.0',
        '600.0',
        'Motor Setup'
      ],
      [
        '01-04',
        'Motor Rated RPM',
        'Motor Nameplate Speed (RPM)',
        '1750',
        '0',
        '60000',
        'Motor Setup'
      ],
      [
        '02-10',
        'Carrier Frequency',
        'PWM Carrier Frequency (kHz)',
        '8',
        '1',
        '15',
        'Advanced'
      ],
    ]);

    // ── Parameters: Siemens SED2 ──────────────────────────────────
    await _insertParams(db, sed2Id, [
      [
        'P0.00',
        'Access Level',
        '1=Standard, 2=Extended, 3=Expert',
        '1',
        '0',
        '3',
        'General'
      ],
      [
        'P1.00',
        'Motor Rated Voltage',
        'Motor Nameplate Voltage (V)',
        '380',
        '10',
        '2000',
        'Motor Data'
      ],
      [
        'P1.01',
        'Motor Rated Current',
        'Motor Nameplate Current (A)',
        '3.25',
        '0.01',
        '10000',
        'Motor Data'
      ],
      [
        'P1.02',
        'Motor Rated Power',
        'Motor Rated Power (kW)',
        '1.1',
        '0.12',
        '2000',
        'Motor Data'
      ],
      [
        'P1.03',
        'Motor Rated Frequency',
        'Motor Nameplate Frequency (Hz)',
        '50.0',
        '12.0',
        '650.0',
        'Motor Data'
      ],
      [
        'P1.08',
        'Motor Rated Speed',
        'Motor Nameplate Speed (RPM)',
        '1395',
        '0',
        '40000',
        'Motor Data'
      ],
      [
        'P2.00',
        'Min Frequency',
        'Minimum Frequency Setpoint (Hz)',
        '0.0',
        '0.0',
        '650.0',
        'Setpoints'
      ],
      [
        'P2.01',
        'Max Frequency',
        'Maximum Frequency Setpoint (Hz)',
        '50.0',
        '0.0',
        '650.0',
        'Setpoints'
      ],
    ]);

    // ── Parameters: Siemens G120 ──────────────────────────────────
    await _insertParams(db, g120Id, [
      ['P0.010', 'Control Mode', '1=V/f, 20=Vector', '1', '1', '20', 'Control'],
      [
        'P0.300',
        'Motor Rated Voltage',
        'Motor Nameplate Voltage (V)',
        '400',
        '1',
        '2000',
        'Motor Data'
      ],
      [
        'P0.304',
        'Motor Rated Current',
        'Motor Nameplate Current (A)',
        '13.0',
        '0.01',
        '10000',
        'Motor Data'
      ],
      [
        'P0.305',
        'Motor Rated Power',
        'Motor Rated Power (kW)',
        '5.5',
        '0.01',
        '2000',
        'Motor Data'
      ],
      [
        'P1.082',
        'Max Speed',
        'Maximum Speed (RPM)',
        '1500',
        '0',
        '40000',
        'Limits'
      ],
      [
        'P1.120',
        'Ramp-up Time',
        'Acceleration Time (s)',
        '10.0',
        '0.0',
        '650.0',
        'Ramp'
      ],
      [
        'P1.121',
        'Ramp-down Time',
        'Deceleration Time (s)',
        '10.0',
        '0.0',
        '650.0',
        'Ramp'
      ],
    ]);

    // ── Parameters: Siemens MM440 ─────────────────────────────────
    await _insertParams(db, mm440Id, [
      [
        'P0.003',
        'Access Level',
        '1=Standard, 2=Extended, 3=Expert',
        '1',
        '1',
        '4',
        'General'
      ],
      [
        'P0.300',
        'Motor Type',
        '1=Induction, 2=Synchronous',
        '1',
        '1',
        '2',
        'Motor'
      ],
      [
        'P0.304',
        'Rated Motor Voltage',
        'Motor Nameplate Voltage (V)',
        '400',
        '10',
        '2000',
        'Motor'
      ],
      [
        'P0.305',
        'Rated Motor Current',
        'Motor Nameplate Current (A)',
        '16.0',
        '0.01',
        '10000',
        'Motor'
      ],
      [
        'P0.307',
        'Rated Motor Power',
        'Motor Nameplate Power (kW)',
        '7.5',
        '0.01',
        '2000',
        'Motor'
      ],
      [
        'P1.000',
        'Frequency Setpoint',
        'Frequency Reference (Hz)',
        '0.0',
        '0.0',
        '650.0',
        'Setpoints'
      ],
      [
        'P1.120',
        'Ramp Up Time',
        'Acceleration Time 0→Max (s)',
        '10.0',
        '0.0',
        '650.0',
        'Ramp'
      ],
      [
        'P1.121',
        'Ramp Down Time',
        'Deceleration Time Max�? (s)',
        '10.0',
        '0.0',
        '650.0',
        'Ramp'
      ],
    ]);

    // ── Parameters: ABB ACS550 ────────────────────────────────────
    await _insertParams(db, acs550Id, [
      [
        '99.04',
        'Motor Ctrl Mode',
        '0=Scalar, 1=Vector',
        '0',
        '0',
        '3',
        'Start-up Data'
      ],
      [
        '99.05',
        'Motor Nominal Voltage',
        'Motor Nameplate Voltage (V)',
        '400',
        '1',
        '690',
        'Start-up Data'
      ],
      [
        '99.06',
        'Motor Nominal Current',
        'Motor Nameplate Current (A)',
        '9.0',
        '0.0',
        '6400',
        'Start-up Data'
      ],
      [
        '99.07',
        'Motor Nominal Frequency',
        'Motor Nameplate Frequency (Hz)',
        '50.0',
        '8.0',
        '300.0',
        'Start-up Data'
      ],
      [
        '99.08',
        'Motor Nominal Speed',
        'Motor Nameplate Speed (RPM)',
        '1450',
        '1',
        '18000',
        'Start-up Data'
      ],
      [
        '99.09',
        'Motor Nominal Power',
        'Motor Nameplate Power (kW)',
        '4.0',
        '0.0',
        '10000',
        'Start-up Data'
      ],
      [
        '20.01',
        'Minimum Speed',
        'Minimum Speed Ref (RPM)',
        '0',
        '-18000',
        '18000',
        'Limits'
      ],
      [
        '20.02',
        'Maximum Speed',
        'Maximum Speed Ref (RPM)',
        '1500',
        '-18000',
        '18000',
        'Limits'
      ],
    ]);

    // ── Parameters: ABB ACS310 ────────────────────────────────────
    await _insertParams(db, acs310Id, [
      [
        '9904',
        'Motor Ctrl Mode',
        '1=Scalar, 2=Vector',
        '1',
        '1',
        '2',
        'Motor Setup'
      ],
      [
        '9905',
        'Motor Nominal Voltage',
        'Motor Nameplate Voltage (V)',
        '400',
        '1',
        '690',
        'Motor Setup'
      ],
      [
        '9906',
        'Motor Nominal Current',
        'Motor Nameplate Current (A)',
        '5.0',
        '0.0',
        '6400',
        'Motor Setup'
      ],
      [
        '9907',
        'Motor Nominal Frequency',
        'Motor Nominal Frequency (Hz)',
        '50.0',
        '8.0',
        '300.0',
        'Motor Setup'
      ],
      [
        '2001',
        'Speed Min',
        'Minimum Speed Reference (RPM)',
        '0',
        '-18000',
        '18000',
        'Limits'
      ],
      [
        '2002',
        'Speed Max',
        'Maximum Speed Reference (RPM)',
        '1500',
        '-18000',
        '18000',
        'Limits'
      ],
      [
        '2202',
        'Accel Time 1',
        'Acceleration Time (s)',
        '20.0',
        '0.1',
        '1800.0',
        'Ramp'
      ],
      [
        '2203',
        'Decel Time 1',
        'Deceleration Time (s)',
        '20.0',
        '0.1',
        '1800.0',
        'Ramp'
      ],
    ]);

    // ── Parameters: Schneider ATV312 ──────────────────────────────
    await _insertParams(db, atv312Id, [
      [
        'bFr',
        'Standard Frequency',
        '50Hz or 60Hz grid standard',
        '50',
        '50',
        '60',
        'Motor Control'
      ],
      [
        'ACC',
        'Acceleration Ramp',
        'Acceleration time 0→nominal (s)',
        '3.0',
        '0.1',
        '999.9',
        'Ramp'
      ],
      [
        'dEC',
        'Deceleration Ramp',
        'Deceleration time nominal�? (s)',
        '3.0',
        '0.1',
        '999.9',
        'Ramp'
      ],
      [
        'LSP',
        'Low Speed',
        'Motor Frequency at Low Speed (Hz)',
        '0.0',
        '0.0',
        '500.0',
        'Speed Limits'
      ],
      [
        'HSP',
        'High Speed',
        'Motor Frequency at High Speed (Hz)',
        '50.0',
        '0.0',
        '500.0',
        'Speed Limits'
      ],
      [
        'ItH',
        'Motor Thermal Current',
        'Motor Thermal Protection Current (A)',
        '2.0',
        '0.0',
        '65535',
        'Protection'
      ],
    ]);

    // ── Parameters: Schneider ATV630 ─────────────────────────────
    await _insertParams(db, atv630Id, [
      [
        'CrL1',
        'Low Current Threshold',
        'Low Current Warning Threshold (A)',
        '0.0',
        '0.0',
        '65535',
        'Monitoring'
      ],
      [
        'ACC',
        'Acceleration',
        'Acceleration Ramp Time (s)',
        '5.0',
        '0.01',
        '6000.0',
        'Ramp'
      ],
      [
        'dEC',
        'Deceleration',
        'Deceleration Ramp Time (s)',
        '5.0',
        '0.01',
        '6000.0',
        'Ramp'
      ],
      [
        'LSP',
        'Low Speed',
        'Low Speed Frequency (Hz)',
        '0.0',
        '0.0',
        '599.0',
        'Limits'
      ],
      [
        'HSP',
        'High Speed',
        'High Speed Frequency (Hz)',
        '50.0',
        '0.0',
        '599.0',
        'Limits'
      ],
      [
        'nPr',
        'Motor Nominal Power',
        'Motor Rated Power (kW)',
        '15.0',
        '0.0',
        '75000',
        'Motor'
      ],
      [
        'UnS',
        'Motor Rated Voltage',
        'Motor Nameplate Voltage (V)',
        '400',
        '100',
        '690',
        'Motor'
      ],
      [
        'nCr',
        'Motor Rated Current',
        'Motor Nameplate Current (A)',
        '29.0',
        '0.0',
        '65535',
        'Motor'
      ],
    ]);

    // ── Parameters: Schneider ATV320 ─────────────────────────────
    await _insertParams(db, atv320Id, [
      [
        'bFr',
        'Standard Frequency',
        '50Hz or 60Hz grid standard',
        '50',
        '50',
        '60',
        'Motor Control'
      ],
      [
        'UnS',
        'Nominal Motor Voltage',
        'Motor nameplate voltage (V)',
        '400',
        '100',
        '500',
        'Motor'
      ],
      [
        'FrS',
        'Nominal Motor Frequency',
        'Motor nameplate frequency (Hz)',
        '50',
        '10',
        '500',
        'Motor'
      ],
      [
        'nCr',
        'Rated Motor Current',
        'Motor nameplate current (A)',
        '3.0',
        '0.1',
        '65535',
        'Motor'
      ],
      [
        'nSP',
        'Nominal Motor Speed',
        'Motor nameplate speed (RPM)',
        '1450',
        '0',
        '65535',
        'Motor'
      ],
      [
        'nPr',
        'Nominal Motor Power',
        'Motor nameplate power (kW)',
        '1.5',
        '0.1',
        '65535',
        'Motor'
      ],
      [
        'ACC',
        'Acceleration Ramp',
        'Acceleration time 0→nominal (s)',
        '3.0',
        '0.1',
        '999.9',
        'Ramp'
      ],
      [
        'dEC',
        'Deceleration Ramp',
        'Deceleration time nominal→0 (s)',
        '3.0',
        '0.1',
        '999.9',
        'Ramp'
      ],
      [
        'LSP',
        'Low Speed',
        'Minimum output frequency (Hz)',
        '0.0',
        '0.0',
        '500.0',
        'Speed Limits'
      ],
      [
        'HSP',
        'High Speed',
        'Maximum output frequency (Hz)',
        '50.0',
        '0.0',
        '500.0',
        'Speed Limits'
      ],
      [
        'ItH',
        'Motor Thermal Current',
        'Motor thermal protection current (A)',
        '3.0',
        '0.0',
        '65535',
        'Protection'
      ],
      [
        'SFr',
        'Switching Frequency',
        'PWM switching frequency (kHz)',
        '4',
        '2',
        '16',
        'Motor Control'
      ],
      [
        'tCC',
        'Control Type',
        '2C=2-wire, 3C=3-wire',
        '2C',
        '2C',
        '3C',
        'Control'
      ],
      ['Ctd', 'Control Mode', '0=Local, 1=Remote', '0', '0', '1', 'Control'],
    ]);

    // ── Parameters: Schneider ATV340 ─────────────────────────────
    await _insertParams(db, atv340Id, [
      [
        'bFr',
        'Standard Frequency',
        '50Hz or 60Hz grid standard',
        '50',
        '50',
        '60',
        'Motor Control'
      ],
      [
        'UnS',
        'Nominal Motor Voltage',
        'Motor nameplate voltage (V)',
        '400',
        '100',
        '690',
        'Motor'
      ],
      [
        'FrS',
        'Nominal Motor Frequency',
        'Motor nameplate frequency (Hz)',
        '50',
        '10',
        '500',
        'Motor'
      ],
      [
        'nCr',
        'Rated Motor Current',
        'Motor nameplate current (A)',
        '8.0',
        '0.1',
        '65535',
        'Motor'
      ],
      [
        'nSP',
        'Nominal Motor Speed',
        'Motor nameplate speed (RPM)',
        '1450',
        '0',
        '65535',
        'Motor'
      ],
      [
        'nPr',
        'Nominal Motor Power',
        'Motor nameplate power (kW)',
        '4.0',
        '0.1',
        '65535',
        'Motor'
      ],
      [
        'COS',
        'Motor Power Factor',
        'Motor nameplate cos phi',
        '0.85',
        '0.5',
        '1.0',
        'Motor'
      ],
      [
        'ACC',
        'Acceleration Ramp',
        'Acceleration time 0→nominal (s)',
        '3.0',
        '0.01',
        '999.9',
        'Ramp'
      ],
      [
        'dEC',
        'Deceleration Ramp',
        'Deceleration time nominal→0 (s)',
        '3.0',
        '0.01',
        '999.9',
        'Ramp'
      ],
      [
        'LSP',
        'Low Speed',
        'Minimum output frequency (Hz)',
        '0.0',
        '0.0',
        '500.0',
        'Speed Limits'
      ],
      [
        'HSP',
        'High Speed',
        'Maximum output frequency (Hz)',
        '50.0',
        '0.0',
        '500.0',
        'Speed Limits'
      ],
      [
        'ItH',
        'Motor Thermal Current',
        'Motor thermal protection current (A)',
        '8.0',
        '0.0',
        '65535',
        'Protection'
      ],
      [
        'tHt',
        'Motor Thermal Type',
        '1=Self-cooled, 2=Force-cooled',
        '1',
        '1',
        '2',
        'Protection'
      ],
      [
        'SFr',
        'Switching Frequency',
        'PWM switching frequency (kHz)',
        '4',
        '2',
        '16',
        'Motor Control'
      ],
      [
        'rPG',
        'Speed Loop P Gain',
        'Speed loop proportional gain',
        '10',
        '1',
        '10000',
        'Motor Control'
      ],
      [
        'rIG',
        'Speed Loop I Gain',
        'Speed loop integral gain (ms)',
        '100',
        '1',
        '65535',
        'Motor Control'
      ],
      [
        'tCC',
        'Control Type',
        '2C=2-wire, 3C=3-wire',
        '2C',
        '2C',
        '3C',
        'Control'
      ],
      [
        'Ctd',
        'Control Mode',
        '0=Local, 1=Remote (fieldbus)',
        '0',
        '0',
        '1',
        'Control'
      ],
      ['rSF', 'Auto Fault Reset', '0=No, 1=Yes', '0', '0', '1', 'Protection'],
      [
        'Frt',
        'Fault Reset Attempts',
        'Number of auto-reset attempts',
        '3',
        '0',
        '10',
        'Protection'
      ],
    ]);

    // ── Parameters: Schneider ATV610 ─────────────────────────────
    await _insertParams(db, atv610Id, [
      [
        'bFr',
        'Standard Frequency',
        '50Hz or 60Hz grid standard',
        '50',
        '50',
        '60',
        'Motor Control'
      ],
      [
        'UnS',
        'Nominal Motor Voltage',
        'Motor nameplate voltage (V)',
        '400',
        '100',
        '690',
        'Motor'
      ],
      [
        'FrS',
        'Nominal Motor Frequency',
        'Motor nameplate frequency (Hz)',
        '50',
        '10',
        '500',
        'Motor'
      ],
      [
        'nCr',
        'Rated Motor Current',
        'Motor nameplate current (A)',
        '17.0',
        '0.1',
        '65535',
        'Motor'
      ],
      [
        'nSP',
        'Nominal Motor Speed',
        'Motor nameplate speed (RPM)',
        '1450',
        '0',
        '65535',
        'Motor'
      ],
      [
        'nPr',
        'Nominal Motor Power',
        'Motor nameplate power (kW)',
        '7.5',
        '0.1',
        '65535',
        'Motor'
      ],
      [
        'ACC',
        'Acceleration Ramp',
        'Acceleration time 0→nominal (s)',
        '5.0',
        '0.01',
        '6000.0',
        'Ramp'
      ],
      [
        'dEC',
        'Deceleration Ramp',
        'Deceleration time nominal→0 (s)',
        '5.0',
        '0.01',
        '6000.0',
        'Ramp'
      ],
      [
        'LSP',
        'Low Speed',
        'Minimum output frequency (Hz)',
        '0.0',
        '0.0',
        '500.0',
        'Speed Limits'
      ],
      [
        'HSP',
        'High Speed',
        'Maximum output frequency (Hz)',
        '50.0',
        '0.0',
        '500.0',
        'Speed Limits'
      ],
      [
        'ItH',
        'Motor Thermal Current',
        'Motor thermal protection current (A)',
        '17.0',
        '0.0',
        '65535',
        'Protection'
      ],
      [
        'SFr',
        'Switching Frequency',
        'PWM switching frequency (kHz)',
        '4',
        '2',
        '12',
        'Motor Control'
      ],
      [
        'PFC',
        'PI Feedback',
        'Process PI feedback source',
        '0',
        '0',
        '5',
        'Process Control'
      ],
      [
        'rPG',
        'PI Proportional Gain',
        'PI loop proportional gain',
        '1.0',
        '0.01',
        '100.0',
        'Process Control'
      ],
      [
        'rIG',
        'PI Integral Gain',
        'PI loop integral time (s)',
        '1.0',
        '0.01',
        '1000.0',
        'Process Control'
      ],
      [
        'tCC',
        'Control Type',
        '2C=2-wire, 3C=3-wire',
        '2C',
        '2C',
        '3C',
        'Control'
      ],
    ]);

    // ── Parameters: Hitachi WJ200 ─────────────────────────────────
    await _insertParams(db, wj200Id, [
      [
        'A001',
        'Freq Source',
        '00=Keypad, 01=Analog, 02=RS485',
        '02',
        '00',
        '10',
        'Command Source'
      ],
      [
        'A002',
        'Run Source',
        '01=Keypad, 02=Digital Input, 03=RS485',
        '02',
        '01',
        '10',
        'Command Source'
      ],
      [
        'A004',
        'Max Frequency',
        'Maximum Frequency Setting (Hz)',
        '50.0',
        '30.0',
        '400.0',
        'Frequency'
      ],
      [
        'A020',
        'Accel Time 1',
        'Acceleration Time 1 (s)',
        '10.0',
        '0.01',
        '3600.0',
        'Ramp'
      ],
      [
        'A021',
        'Decel Time 1',
        'Deceleration Time 1 (s)',
        '10.0',
        '0.01',
        '3600.0',
        'Ramp'
      ],
      [
        'H003',
        'Motor Poles',
        'Number of Motor Poles',
        '4',
        '2',
        '48',
        'Motor Const.'
      ],
      [
        'H004',
        'Motor Capacity',
        'Motor Rated Power (kW)',
        '0.75',
        '0.1',
        '75.0',
        'Motor Const.'
      ],
    ]);

    // ── Parameters: Hitachi SJ700 ─────────────────────────────────
    await _insertParams(db, sj700Id, [
      [
        'A001',
        'Freq Source',
        '00=Keypad, 01=Analog, 02=RS485',
        '02',
        '00',
        '10',
        'Command Source'
      ],
      [
        'A003',
        'Base Frequency',
        'Motor Base Frequency (Hz)',
        '50.0',
        '25.0',
        '400.0',
        'Frequency'
      ],
      [
        'A004',
        'Max Frequency',
        'Maximum Frequency (Hz)',
        '50.0',
        '30.0',
        '400.0',
        'Frequency'
      ],
      [
        'A020',
        'Accel Time 1',
        'Acceleration Time 1 (s)',
        '10.0',
        '0.01',
        '3600.0',
        'Ramp'
      ],
      [
        'A021',
        'Decel Time 1',
        'Deceleration Time 1 (s)',
        '10.0',
        '0.01',
        '3600.0',
        'Ramp'
      ],
      ['H003', 'Motor Poles', 'Number of Motor Poles', '4', '2', '48', 'Motor'],
      [
        'H004',
        'Motor kW',
        'Motor Rated Power (kW)',
        '5.5',
        '0.1',
        '75.0',
        'Motor'
      ],
    ]);

    // ── Parameters: Mitsubishi FR-D700 ────────────────────────────
    await _insertParams(db, frD700Id, [
      [
        'Pr.0',
        'Torque Boost',
        'Manual Torque Boost (V)',
        '6',
        '0',
        '30',
        'V/F Control'
      ],
      [
        'Pr.1',
        'Max Frequency',
        'Maximum Frequency (Hz)',
        '120.0',
        '0.0',
        '400.0',
        'Frequency'
      ],
      [
        'Pr.2',
        'Min Frequency',
        'Minimum Frequency (Hz)',
        '0.0',
        '0.0',
        '120.0',
        'Frequency'
      ],
      [
        'Pr.7',
        'Accel Time',
        'Acceleration Time (s)',
        '5.0',
        '0.0',
        '3600.0',
        'Ramp'
      ],
      [
        'Pr.8',
        'Decel Time',
        'Deceleration Time (s)',
        '5.0',
        '0.0',
        '3600.0',
        'Ramp'
      ],
      [
        'Pr.9',
        'Electronic OL',
        'Motor Electronic Thermal O/L (A)',
        '0.0',
        '0.0',
        '500.0',
        'Protection'
      ],
      [
        'Pr.19',
        'Base Frequency Voltage',
        'Rated Motor Voltage (V)',
        '200',
        '0',
        '1000',
        'Motor'
      ],
    ]);

    // ── Parameters: Mitsubishi FR-E700 ────────────────────────────
    await _insertParams(db, frE700Id, [
      [
        'Pr.0',
        'Torque Boost',
        'Manual Torque Boost (V)',
        '6',
        '0',
        '30',
        'V/F Control'
      ],
      [
        'Pr.1',
        'Max Frequency',
        'Maximum Frequency (Hz)',
        '120.0',
        '0.0',
        '400.0',
        'Frequency'
      ],
      [
        'Pr.7',
        'Accel Time',
        'Acceleration Time (s)',
        '5.0',
        '0.0',
        '3600.0',
        'Ramp'
      ],
      [
        'Pr.8',
        'Decel Time',
        'Deceleration Time (s)',
        '5.0',
        '0.0',
        '3600.0',
        'Ramp'
      ],
      [
        'Pr.80',
        'Motor Capacity',
        'Motor Capacity (kW)',
        '2.2',
        '0.0',
        '55.0',
        'Motor'
      ],
      [
        'Pr.83',
        'Rated Motor Voltage',
        'Rated Motor Voltage (V)',
        '200',
        '0',
        '1000',
        'Motor'
      ],
      [
        'Pr.84',
        'Rated Motor Frequency',
        'Rated Motor Frequency (Hz)',
        '60.0',
        '0.0',
        '400.0',
        'Motor'
      ],
    ]);

    // ── Parameters: Yaskawa V1000 ─────────────────────────────────
    await _insertParams(db, v1000Id, [
      [
        'A1-02',
        'Control Method',
        '0=V/f, 1=Open Loop Vector',
        '0',
        '0',
        '3',
        'Initialize'
      ],
      [
        'b1-01',
        'Freq Ref Source',
        '0=Keypad, 1=Analog, 2=Serial',
        '1',
        '0',
        '4',
        'Sequence'
      ],
      [
        'b1-02',
        'Run Source',
        '0=Keypad, 1=Digital Input, 2=Serial',
        '1',
        '0',
        '3',
        'Sequence'
      ],
      [
        'C1-01',
        'Accel Time 1',
        'Acceleration Time 1 (s)',
        '10.0',
        '0.0',
        '6000.0',
        'Ramp'
      ],
      [
        'C1-02',
        'Decel Time 1',
        'Deceleration Time 1 (s)',
        '10.0',
        '0.0',
        '6000.0',
        'Ramp'
      ],
      [
        'E1-01',
        'Input Voltage',
        'Input Voltage Setting (V)',
        '230',
        '155',
        '255',
        'Motor'
      ],
      [
        'E2-01',
        'Motor Rated Current',
        'Motor Rated Current (A)',
        '4.0',
        '0.0',
        '6000',
        'Motor'
      ],
    ]);

    // ── Parameters: Yaskawa A1000 ─────────────────────────────────
    await _insertParams(db, a1000Id, [
      [
        'A1-02',
        'Control Method',
        '0=V/f, 2=Open Loop Vector, 3=Closed Loop Vector',
        '0',
        '0',
        '5',
        'Initialize'
      ],
      [
        'b1-01',
        'Freq Ref Source',
        '0=Keypad, 1=Analog, 2=Serial, 3=Option',
        '1',
        '0',
        '4',
        'Sequence'
      ],
      [
        'b1-02',
        'Run Source',
        '0=Keypad, 1=Digital, 2=Serial, 3=Option',
        '1',
        '0',
        '3',
        'Sequence'
      ],
      [
        'C1-01',
        'Accel Time 1',
        'Acceleration Time 1 (s)',
        '10.0',
        '0.0',
        '6000.0',
        'Ramp'
      ],
      [
        'C1-02',
        'Decel Time 1',
        'Deceleration Time 1 (s)',
        '10.0',
        '0.0',
        '6000.0',
        'Ramp'
      ],
      [
        'E1-01',
        'Input Voltage',
        'Input Voltage Setting (V)',
        '400',
        '155',
        '510',
        'Motor'
      ],
      [
        'E2-01',
        'Motor Rated Current',
        'Motor Rated Current (A)',
        '13.0',
        '0.0',
        '6000',
        'Motor'
      ],
      [
        'L3-02',
        'Stall Prev Level',
        'Stall Prevention Level during Accel (%)',
        '150',
        '0',
        '200',
        'Protection'
      ],
    ]);

    // ── Manuals ───────────────────────────────────────────────────
    final manuals = [
      [vfdSId, 'VFD-S User Manual', 'User Manual', 'English', 3],
      [vfdSId, 'VFD-S Quick Start Guide', 'Quick Start', 'English', 2],
      [vfdSId, 'VFD-S Parameter List', 'Parameter Guide', 'English', 3],
      [vfdLId, 'VFD-L User Manual', 'User Manual', 'English', 2],
      [vfdLId, 'VFD-L Quick Start Guide', 'Quick Start', 'English', 1],
      [vfdEId, 'VFD-E User Manual', 'User Manual', 'English', 4],
      [vfdEId, 'VFD-E Parameter List', 'Parameter Guide', 'English', 4],
      [vfdMId, 'VFD-M User Manual', 'User Manual', 'English', 2],
      [vfdC200Id, 'VFD-C200 User Manual', 'User Manual', 'English', 1],
      [vfdC200Id, 'VFD-C200 Quick Start', 'Quick Start', 'English', 1],
      [sed2Id, 'SED2 Operating Instructions', 'User Manual', 'English', 2],
      [sed2Id, 'SED2 Parameter List', 'Parameter Guide', 'English', 2],
      [g120Id, 'SINAMICS G120 Operating Manual', 'User Manual', 'English', 5],
      [g120Id, 'SINAMICS G120 Quick Start', 'Quick Start', 'English', 3],
      [mm440Id, 'MICROMASTER 440 Manual', 'User Manual', 'English', 3],
      [acs550Id, 'ACS550 Users Manual', 'User Manual', 'English', 4],
      [acs550Id, 'ACS550 Quick Start Guide', 'Quick Start', 'English', 4],
      [acs310Id, 'ACS310 Users Manual', 'User Manual', 'English', 2],
      [atv312Id, 'Altivar 312 Programming Manual', 'User Manual', 'English', 3],
      [atv312Id, 'Altivar 312 Quick Start', 'Quick Start', 'English', 2],
      [atv630Id, 'Altivar Process 630 Manual', 'User Manual', 'English', 1],
      [
        atv630Id,
        'Altivar 630 Parameter Reference',
        'Parameter Guide',
        'English',
        1
      ],
      [wj200Id, 'WJ200 Instruction Manual', 'User Manual', 'English', 2],
      [sj700Id, 'SJ700 Instruction Manual', 'User Manual', 'English', 3],
      [frD700Id, 'FR-D700 Instruction Manual', 'User Manual', 'English', 2],
      [frD700Id, 'FR-D700 Parameter Manual', 'Parameter Guide', 'English', 2],
      [frE700Id, 'FR-E700 Instruction Manual', 'User Manual', 'English', 2],
      [v1000Id, 'V1000 Technical Manual', 'User Manual', 'English', 4],
      [v1000Id, 'V1000 Quick Start', 'Quick Start', 'English', 4],
      [a1000Id, 'A1000 Technical Manual', 'User Manual', 'English', 3],
      [a1000Id, 'A1000 Parameter Access', 'Parameter Guide', 'English', 3],
    ];
    for (final m in manuals) {
      await db.insert('vfd_manuals', {
        'modelId': m[0],
        'title': m[1],
        'manualType': m[2],
        'filePath': '',
        'language': m[3],
        'version': m[4],
      });
    }

    // ── Protocols for Delta ─────────────────────────────────────────
    final deltaRtuId = await db.insert('protocols', {
      'vendorId': deltaId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU communication',
      'commCard': 'DVP-SE'
    });
    final deltaTcpId = await db.insert('protocols', {
      'vendorId': deltaId,
      'name': 'Modbus TCP',
      'type': 'Ethernet',
      'description': 'Ethernet Modbus TCP communication',
      'commCard': 'DVP-SE'
    });
    await db.insert('protocols', {
      'vendorId': deltaId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP industrial protocol',
      'commCard': 'DVP-SE'
    });
    await db.insert('protocols', {
      'vendorId': deltaId,
      'name': 'CANopen',
      'type': 'Serial',
      'description': 'CANopen fieldbus communication',
      'commCard': 'CAN-SE'
    });
    await db.insert('protocols', {
      'vendorId': deltaId,
      'name': 'DeviceNet',
      'type': 'Serial',
      'description': 'DeviceNet fieldbus',
      'commCard': 'DVPDNET'
    });
    await db.insert('protocols', {
      'vendorId': deltaId,
      'name': 'PROFINET',
      'type': 'Ethernet',
      'description': 'PROFINET IO',
      'commCard': 'DVPPFN01'
    });
    await db.insert('protocols', {
      'vendorId': deltaId,
      'name': 'Hard Wire (Direct I/O)',
      'type': 'Direct',
      'description': 'Direct I/O control via analog/digital inputs'
    });

    // ── Protocols for Siemens ────────────────────────────────────────
    final siemensProfibusId = await db.insert('protocols', {
      'vendorId': siemensId,
      'name': 'Profibus DP',
      'type': 'Serial',
      'description': 'Profibus DP fieldbus communication',
      'commCard': 'CBP2'
    });
    await db.insert('protocols', {
      'vendorId': siemensId,
      'name': 'Profinet IRT',
      'type': 'Ethernet',
      'description': 'Profinet IRT real-time Ethernet',
      'commCard': 'CBE'
    });
    await db.insert('protocols', {
      'vendorId': siemensId,
      'name': 'USS',
      'type': 'Serial',
      'description': 'USS protocol via RS485',
      'commCard': 'CB15'
    });
    await db.insert('protocols', {
      'vendorId': siemensId,
      'name': 'Hard Wire (Direct I/O)',
      'type': 'Direct',
      'description': 'Direct I/O control via analog/digital inputs'
    });

    // ── Protocols for ABB ───────────────────────────────────────────
    final abbFieldbusId = await db.insert('protocols', {
      'vendorId': abbId,
      'name': 'Fieldbus Adapter',
      'type': 'Serial',
      'description': 'ABB Fieldbus adapter communication',
      'commCard': 'RPBA-01'
    });
    await db.insert('protocols', {
      'vendorId': abbId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP protocol support',
      'commCard': 'RETA-01/02'
    });
    await db.insert('protocols', {
      'vendorId': abbId,
      'name': 'Profinet IO',
      'type': 'Ethernet',
      'description': 'Profinet IO communication',
      'commCard': 'RPGO-01'
    });
    await db.insert('protocols', {
      'vendorId': abbId,
      'name': 'DeviceNet',
      'type': 'Serial',
      'description': 'DeviceNet fieldbus',
      'commCard': 'RDNA-01'
    });
    await db.insert('protocols', {
      'vendorId': abbId,
      'name': 'CANopen',
      'type': 'Serial',
      'description': 'CANopen fieldbus',
      'commCard': 'RCNA-01'
    });
    await db.insert('protocols', {
      'vendorId': abbId,
      'name': 'PROFIBUS',
      'type': 'Serial',
      'description': 'PROFIBUS DP fieldbus',
      'commCard': 'RPBA-01'
    });
    await db.insert('protocols', {
      'vendorId': abbId,
      'name': 'Hard Wire (Direct I/O)',
      'type': 'Direct',
      'description': 'Direct I/O control via analog/digital inputs'
    });

    // ── Protocols for Schneider ───────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': schneiderId,
      'name': 'CANopen',
      'type': 'Serial',
      'description': 'CANopen fieldbus communication',
      'commCard': 'VW3A8105'
    });
    await db.insert('protocols', {
      'vendorId': schneiderId,
      'name': 'Modbus TCP',
      'type': 'Ethernet',
      'description': 'Modbus TCP Ethernet communication',
      'commCard': 'VW3A8106'
    });
    await db.insert('protocols', {
      'vendorId': schneiderId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP',
      'commCard': 'VW3A8107'
    });
    await db.insert('protocols', {
      'vendorId': schneiderId,
      'name': 'PROFIBUS DP',
      'type': 'Serial',
      'description': 'PROFIBUS DP',
      'commCard': 'VW3A8103'
    });
    await db.insert('protocols', {
      'vendorId': schneiderId,
      'name': 'DeviceNet',
      'type': 'Serial',
      'description': 'DeviceNet',
      'commCard': 'VW3A8104'
    });
    await db.insert('protocols', {
      'vendorId': schneiderId,
      'name': 'Hard Wire (Direct I/O)',
      'type': 'Direct',
      'description': 'Direct I/O control via analog/digital inputs'
    });

    // ── Protocols for Hitachi ───────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': hitachiId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU communication',
      'commCard': 'SJ300-EXM'
    });
    await db.insert('protocols', {
      'vendorId': hitachiId,
      'name': 'Modbus TCP',
      'type': 'Ethernet',
      'description': 'Ethernet Modbus TCP communication',
      'commCard': 'SJ300-ETH'
    });
    await db.insert('protocols', {
      'vendorId': hitachiId,
      'name': 'PROFIBUS',
      'type': 'Serial',
      'description': 'PROFIBUS DP',
      'commCard': 'SJ300-PFB'
    });
    await db.insert('protocols', {
      'vendorId': hitachiId,
      'name': 'DeviceNet',
      'type': 'Serial',
      'description': 'DeviceNet',
      'commCard': 'SJ300-DNT'
    });
    await db.insert('protocols', {
      'vendorId': hitachiId,
      'name': 'Hard Wire (Direct I/O)',
      'type': 'Direct',
      'description': 'Direct I/O control via analog/digital inputs'
    });

    // ── Protocols for Mitsubishi ─────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': mitsubishiId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU communication',
      'commCard': 'FR-A8NR'
    });
    await db.insert('protocols', {
      'vendorId': mitsubishiId,
      'name': 'Modbus TCP',
      'type': 'Ethernet',
      'description': 'Ethernet Modbus TCP communication',
      'commCard': 'FR-A8EN'
    });
    await db.insert('protocols', {
      'vendorId': mitsubishiId,
      'name': 'CC-Link',
      'type': 'Serial',
      'description': 'CC-Link fieldbus',
      'commCard': 'FR-A8NC'
    });
    await db.insert('protocols', {
      'vendorId': mitsubishiId,
      'name': 'DeviceNet',
      'type': 'Serial',
      'description': 'DeviceNet',
      'commCard': 'FR-A8ND'
    });
    await db.insert('protocols', {
      'vendorId': mitsubishiId,
      'name': 'PROFIBUS DP',
      'type': 'Serial',
      'description': 'PROFIBUS DP',
      'commCard': 'FR-A8NP'
    });
    await db.insert('protocols', {
      'vendorId': mitsubishiId,
      'name': 'EtherCAT',
      'type': 'Ethernet',
      'description': 'EtherCAT',
      'commCard': 'FR-A8EC'
    });
    await db.insert('protocols', {
      'vendorId': mitsubishiId,
      'name': 'Hard Wire (Direct I/O)',
      'type': 'Direct',
      'description': 'Direct I/O control via analog/digital inputs'
    });

    // ── Protocols for Yaskawa ─────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': yaskawaId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU communication',
      'commCard': 'SI-M3'
    });
    await db.insert('protocols', {
      'vendorId': yaskawaId,
      'name': 'Modbus TCP',
      'type': 'Ethernet',
      'description': 'Ethernet Modbus TCP communication',
      'commCard': 'SI-EN'
    });
    await db.insert('protocols', {
      'vendorId': yaskawaId,
      'name': 'MEMOBUS',
      'type': 'Serial',
      'description': 'MEMOBUS RTU/TCP protocol',
      'commCard': 'SI-M'
    });
    await db.insert('protocols', {
      'vendorId': yaskawaId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP',
      'commCard': 'SI-EN2'
    });
    await db.insert('protocols', {
      'vendorId': yaskawaId,
      'name': 'PROFIBUS',
      'type': 'Serial',
      'description': 'PROFIBUS DP',
      'commCard': 'SI-P'
    });
    await db.insert('protocols', {
      'vendorId': yaskawaId,
      'name': 'DeviceNet',
      'type': 'Serial',
      'description': 'DeviceNet',
      'commCard': 'SI-D'
    });
    await db.insert('protocols', {
      'vendorId': yaskawaId,
      'name': 'CANopen',
      'type': 'Serial',
      'description': 'CANopen',
      'commCard': 'SI-C'
    });
    await db.insert('protocols', {
      'vendorId': yaskawaId,
      'name': 'Hard Wire (Direct I/O)',
      'type': 'Direct',
      'description': 'Direct I/O control via analog/digital inputs'
    });

    // ── Protocols for Danfoss ───────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': danfossId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU communication',
      'commCard': 'MCB 101'
    });
    await db.insert('protocols', {
      'vendorId': danfossId,
      'name': 'FC Protocol',
      'type': 'Serial',
      'description': 'Danfoss FC Protocol',
      'commCard': 'MCB 101'
    });
    await db.insert('protocols', {
      'vendorId': danfossId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP protocol',
      'commCard': 'MCA 121'
    });
    await db.insert('protocols', {
      'vendorId': danfossId,
      'name': 'PROFIBUS',
      'type': 'Serial',
      'description': 'PROFIBUS DP',
      'commCard': 'MCA 124'
    });
    await db.insert('protocols', {
      'vendorId': danfossId,
      'name': 'DeviceNet',
      'type': 'Serial',
      'description': 'DeviceNet',
      'commCard': 'MCA 125'
    });

    // ── Protocols for Allen Bradley ───────────────────────────────────
    await db.insert('protocols', {
      'vendorId': allenBradleyId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'Integrated EtherNet/IP communication',
      'commCard': '20-COMM-X'
    });
    await db.insert('protocols', {
      'vendorId': allenBradleyId,
      'name': 'DeviceNet',
      'type': 'Serial',
      'description': 'DeviceNet fieldbus',
      'commCard': '20-COMM-D'
    });
    await db.insert('protocols', {
      'vendorId': allenBradleyId,
      'name': 'PROFIBUS',
      'type': 'Serial',
      'description': 'PROFIBUS DP',
      'commCard': '20-COMM-P'
    });
    await db.insert('protocols', {
      'vendorId': allenBradleyId,
      'name': 'ControlNet',
      'type': 'Serial',
      'description': 'ControlNet',
      'commCard': '20-COMM-C'
    });
    await db.insert('protocols', {
      'vendorId': allenBradleyId,
      'name': 'Hard Wire (Direct I/O)',
      'type': 'Direct',
      'description': 'Direct I/O control'
    });

    // ── Protocols for Omron ────────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': omronId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU',
      'commCard': '3G3AX-MCR1'
    });
    await db.insert('protocols', {
      'vendorId': omronId,
      'name': 'CompoNet',
      'type': 'Serial',
      'description': 'CompoNet fieldbus',
      'commCard': '3G3AX-NCN01'
    });
    await db.insert('protocols', {
      'vendorId': omronId,
      'name': 'EtherCAT',
      'type': 'Ethernet',
      'description': 'EtherCAT real-time Ethernet',
      'commCard': '3G3AX-ECT'
    });
    await db.insert('protocols', {
      'vendorId': omronId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP',
      'commCard': '3G3AX-EN01'
    });

    // ── Protocols for INVT ─────────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': invtId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU',
      'commCard': 'PCI-GLM'
    });
    await db.insert('protocols', {
      'vendorId': invtId,
      'name': 'Modbus TCP',
      'type': 'Ethernet',
      'description': 'Ethernet Modbus TCP',
      'commCard': 'PCI-ETH'
    });
    await db.insert('protocols', {
      'vendorId': invtId,
      'name': 'PROFIBUS',
      'type': 'Serial',
      'description': 'PROFIBUS DP',
      'commCard': 'PCI-PFB'
    });
    await db.insert('protocols', {
      'vendorId': invtId,
      'name': 'Hard Wire',
      'type': 'Direct',
      'description': 'Direct I/O control'
    });

    // ── Protocols for WEG ─────────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': wegId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU',
      'commCard': 'CFW300-MC-485'
    });
    await db.insert('protocols', {
      'vendorId': wegId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP',
      'commCard': 'CFW300-MC-EIP'
    });
    await db.insert('protocols', {
      'vendorId': wegId,
      'name': 'PROFIBUS',
      'type': 'Serial',
      'description': 'PROFIBUS DP',
      'commCard': 'CFW300-MC-PFB'
    });
    await db.insert('protocols', {
      'vendorId': wegId,
      'name': 'Hard Wire',
      'type': 'Direct',
      'description': 'Direct I/O control'
    });

    // ── Protocols for LS ───────────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': lsId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU',
      'commCard': 'OPG-485'
    });
    await db.insert('protocols', {
      'vendorId': lsId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP',
      'commCard': 'OPG-ETH'
    });
    await db.insert('protocols', {
      'vendorId': lsId,
      'name': 'PROFIBUS',
      'type': 'Serial',
      'description': 'PROFIBUS DP',
      'commCard': 'OPG-PFB'
    });
    await db.insert('protocols', {
      'vendorId': lsId,
      'name': 'Hard Wire',
      'type': 'Direct',
      'description': 'Direct I/O control'
    });

    // ── Protocols for Inovance ────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': inovanceId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU',
      'commCard': 'HD2-485'
    });
    await db.insert('protocols', {
      'vendorId': inovanceId,
      'name': 'Modbus TCP',
      'type': 'Ethernet',
      'description': 'Ethernet Modbus TCP',
      'commCard': 'HD2-TCP'
    });
    await db.insert('protocols', {
      'vendorId': inovanceId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP',
      'commCard': 'HD2-EIP'
    });

    // ── Protocols for Lenze ────────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': lenzeId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU',
      'commCard': 'EIP/MB-01'
    });
    await db.insert('protocols', {
      'vendorId': lenzeId,
      'name': 'EtherCAT',
      'type': 'Ethernet',
      'description': 'EtherCAT real-time Ethernet',
      'commCard': 'ECT-01'
    });
    await db.insert('protocols', {
      'vendorId': lenzeId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP',
      'commCard': 'ECP-01'
    });

    // ── Protocols for others ───────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': toshibaId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU',
      'commCard': 'VFAS1-485'
    });
    await db.insert('protocols', {
      'vendorId': toshibaId,
      'name': 'PROFIBUS',
      'type': 'Serial',
      'description': 'PROFIBUS DP',
      'commCard': 'VFAS1-PFB'
    });
    await db.insert('protocols', {
      'vendorId': fujiId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU',
      'commCard': 'FRENIC-485'
    });
    await db.insert('protocols', {
      'vendorId': kebId,
      'name': 'CANopen',
      'type': 'Serial',
      'description': 'CANopen fieldbus',
      'commCard': 'CAN-01'
    });
    await db.insert('protocols', {
      'vendorId': parkerId,
      'name': 'Hard Wire',
      'type': 'Direct',
      'description': 'Direct I/O control'
    });

    // ── Protocol Parameters: Delta Modbus RTU ─────────────────────────
    await _insertProtocolParams(db, deltaRtuId, [
      [
        '00-00',
        'Communication Address',
        'VFD Station Address (1-247)',
        '1',
        '1',
        '247',
        'Communication'
      ],
      [
        '00-01',
        'Baud Rate',
        '0=4800, 1=9600, 2=19200, 3=38400, 4=57600',
        '1',
        '0',
        '4',
        'Communication'
      ],
      [
        '00-02',
        'Data Format',
        '0=8N1, 1=8E1, 2=8O1',
        '0',
        '0',
        '2',
        'Communication'
      ],
      [
        '00-03',
        'Communication Loss',
        '0=Decelerate to stop, 1=Free run, 2=Continue',
        '0',
        '0',
        '2',
        'Communication'
      ],
      [
        '00-04',
        'Communication Timeout',
        'Communication timeout time (0.1-30.0s)',
        '1.0',
        '0.1',
        '30.0',
        'Communication'
      ],
      [
        '09-00',
        'RS485 Address',
        'Communication address for RS485',
        '1',
        '1',
        '254',
        'RS485'
      ],
      [
        '09-01',
        'RS485 Baud Rate',
        'Baud rate selection for RS485',
        '19200',
        '4800',
        '57600',
        'RS485'
      ],
    ]);

    // ── Protocol Parameters: Delta Modbus TCP ────────────────────────
    await _insertProtocolParams(db, deltaTcpId, [
      [
        '00-00',
        'IP Address Byte 1',
        'IP Address first octet',
        '192',
        '0',
        '255',
        'TCP/IP'
      ],
      [
        '00-01',
        'IP Address Byte 2',
        'IP Address second octet',
        '168',
        '0',
        '255',
        'TCP/IP'
      ],
      [
        '00-02',
        'IP Address Byte 3',
        'IP Address third octet',
        '1',
        '0',
        '255',
        'TCP/IP'
      ],
      [
        '00-03',
        'IP Address Byte 4',
        'IP Address fourth octet',
        '100',
        '0',
        '255',
        'TCP/IP'
      ],
      [
        '00-10',
        'Subnet Mask Byte 1',
        'Subnet mask first octet',
        '255',
        '0',
        '255',
        'TCP/IP'
      ],
      [
        '00-11',
        'Subnet Mask Byte 2',
        'Subnet mask second octet',
        '255',
        '0',
        '255',
        'TCP/IP'
      ],
      [
        '00-12',
        'Subnet Mask Byte 3',
        'Subnet mask third octet',
        '255',
        '0',
        '255',
        'TCP/IP'
      ],
      [
        '00-13',
        'Subnet Mask Byte 4',
        'Subnet mask fourth octet',
        '0',
        '0',
        '255',
        'TCP/IP'
      ],
      [
        '00-20',
        'Gateway Byte 1',
        'Gateway first octet',
        '192',
        '0',
        '255',
        'TCP/IP'
      ],
      [
        '00-21',
        'Port Number',
        'Modbus TCP port number',
        '502',
        '1024',
        '65535',
        'TCP/IP'
      ],
    ]);

    // ── Protocol Parameters: Siemens Profibus ───────────────────────
    await _insertProtocolParams(db, siemensProfibusId, [
      [
        'P0.010',
        'Profibus Address',
        'Profibus station address (1-125)',
        '1',
        '1',
        '125',
        'Profibus'
      ],
      [
        'P0.011',
        'PPO Type',
        '0=PPO1, 1=PPO2, 2=PPO3, 3=PPO4, 4=PPO5',
        '2',
        '0',
        '4',
        'Profibus'
      ],
      [
        'P0.012',
        'Bus Baud Rate',
        'Auto baud rate detection',
        '0',
        '0',
        '1',
        'Profibus'
      ],
      [
        'P0.013',
        'Bus Diagnostic',
        'Bus diagnostic data address',
        '0',
        '0',
        '65535',
        'Profibus'
      ],
      [
        'P1.205',
        'PZD1 OUT',
        'Process data word 1 output',
        '3100',
        '0',
        '65535',
        'Process Data'
      ],
      [
        'P1.206',
        'PZD2 OUT',
        'Process data word 2 output',
        '3101',
        '0',
        '65535',
        'Process Data'
      ],
    ]);

    // ── Protocol Parameters: ABB Fieldbus ─────────────────────────────
    await _insertProtocolParams(db, abbFieldbusId, [
      [
        '51.01',
        'Profile',
        'Fieldbus profile selection',
        '0',
        '0',
        '4',
        'Fieldbus'
      ],
      ['51.02', 'PPO Type', 'PPO type 1-5', '3', '1', '5', 'Fieldbus'],
      [
        '51.03',
        'Node Address',
        'Fieldbus node address (1-126)',
        '1',
        '1',
        '126',
        'Fieldbus'
      ],
      ['51.04', 'Baud Rate', 'Fieldbus baud rate', '0', '0', '7', 'Fieldbus'],
      [
        '52.01',
        'Control Word',
        'Control word from fieldbus',
        '0',
        '0',
        '65535',
        'Control'
      ],
      [
        '52.02',
        'Speed Ref',
        'Speed reference from fieldbus',
        '0',
        '-32768',
        '32767',
        'Reference'
      ],
      [
        '53.01',
        'Status Word',
        'Status word to fieldbus',
        '0',
        '0',
        '65535',
        'Status'
      ],
      [
        '53.02',
        'Speed Out',
        'Speed output to fieldbus',
        '0',
        '-32768',
        '32767',
        'Status'
      ],
    ]);

    // ══════════════════════════════════════════════════════════════════
    // ADDITIONAL MODELS FROM CLICK2ELECTRO.COM
    // ══════════════════════════════════════════════════════════════════

    // ── Siemens additional models ────────────────────────────────────
    final int mm420Id = await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'MICROMASTER 420',
      'series': 'MM420',
      'description': 'General Purpose VFD',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'MICROMASTER 420',
      'series': 'MM420',
      'description': 'General Purpose VFD',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    final int mm430Id = await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'MICROMASTER 430',
      'series': 'MM430',
      'description': 'Pump and Fan VFD',
      'powerRating': 4.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'MICROMASTER 430',
      'series': 'MM430',
      'description': 'Pump and Fan VFD',
      'powerRating': 11.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'SINAMICS S120',
      'series': 'S120',
      'description': 'Modular Drive System for Motion Control',
      'powerRating': 10.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'SINAMICS V70',
      'series': 'V70',
      'description': 'Basic Servo Drive',
      'powerRating': 1.5,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'SINAMICS V90',
      'series': 'V90',
      'description': 'Servo Drive for SIMOTICS S',
      'powerRating': 1.0,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'SINAMICS V90',
      'series': 'V90',
      'description': 'Servo Drive for SIMOTICS S',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'SINAMICS G110',
      'series': 'G110',
      'description': 'Simple Compact Drive',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': siemensId,
      'name': 'SINAMICS G115D',
      'series': 'G115D',
      'description': 'Distributed Drive for Conveyor',
      'powerRating': 4.0,
      'voltage': '400V'
    });

    // ── ABB additional models ────────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': abbId,
      'name': 'ACS380',
      'series': 'ACS380',
      'description': 'Machinery Drive',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': abbId,
      'name': 'ACS380',
      'series': 'ACS380',
      'description': 'Machinery Drive',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': abbId,
      'name': 'ACS150',
      'series': 'ACS150',
      'description': 'Ultra-compact Drive for Machines',
      'powerRating': 0.37,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': abbId,
      'name': 'ACS150',
      'series': 'ACS150',
      'description': 'Ultra-compact Drive for Machines',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': abbId,
      'name': 'ACS850',
      'series': 'ACS850',
      'description': 'Wind Turbine Drive',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': abbId,
      'name': 'ACS480',
      'series': 'ACS480',
      'description': 'Drives for Machinery OEM',
      'powerRating': 1.5,
      'voltage': '400V'
    });

    // ── Schneider additional models ──────────────────────────────────
    final int atv12Id = await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV12',
      'series': 'Altivar 12',
      'description': 'Compact Drive for Simple Machines',
      'powerRating': 0.18,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV12',
      'series': 'Altivar 12',
      'description': 'Compact Drive for Simple Machines',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    final int atv31Id = await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV31',
      'series': 'Altivar 31',
      'description': 'VFD for Simple Machines',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV31',
      'series': 'Altivar 31',
      'description': 'VFD for Simple Machines',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    final int atv32Id = await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV32',
      'series': 'Altivar 32',
      'description': 'VFD for Machine Builders',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV32',
      'series': 'Altivar 32',
      'description': 'VFD for Machine Builders',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    final int atv61Id = await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV61',
      'series': 'Altivar 61',
      'description': 'HVAC Drive for Pump and Fan',
      'powerRating': 7.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV61',
      'series': 'Altivar 61',
      'description': 'HVAC Drive for Pump and Fan',
      'powerRating': 22.0,
      'voltage': '400V'
    });
    final int atv71Id = await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV71',
      'series': 'Altivar 71',
      'description': 'High Performance Drive for Machines',
      'powerRating': 7.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV71',
      'series': 'Altivar 71',
      'description': 'High Performance Drive for Machines',
      'powerRating': 22.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV212',
      'series': 'Altivar 212',
      'description': 'HVAC Drive for Pump and Fan',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV303',
      'series': 'Altivar 303',
      'description': 'Simple Drive',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV310',
      'series': 'Altivar 310',
      'description': 'Pump and Fan Drive',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV310',
      'series': 'Altivar 310',
      'description': 'Pump and Fan Drive',
      'powerRating': 4.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV600',
      'series': 'Altivar Process 600',
      'description': 'Process Drive for Pump Fan Compressor',
      'powerRating': 15.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV650',
      'series': 'Altivar Process 650',
      'description': 'ATEX Process Drive',
      'powerRating': 15.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV900',
      'series': 'Altivar Process 900',
      'description': 'Regenerative Process Drive',
      'powerRating': 22.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV930',
      'series': 'Altivar Process 930',
      'description': 'Bypass Drive for Pumps and Fans',
      'powerRating': 18.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': schneiderId,
      'name': 'ATV950',
      'series': 'Altivar Process 950',
      'description': 'Drive with Power Factor Correction',
      'powerRating': 18.5,
      'voltage': '400V'
    });

    // ── Danfoss additional models ────────────────────────────────────
    final int fc51Id = await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'FC51',
      'series': 'VLT Micro Drive FC 51',
      'description': 'Simple VFD for Basic Applications',
      'powerRating': 0.75,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'FC51',
      'series': 'VLT Micro Drive FC 51',
      'description': 'Simple VFD for Basic Applications',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    final int fc102Id = await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'FC102',
      'series': 'VLT HVAC Drive FC 102',
      'description': 'HVAC Application VFD',
      'powerRating': 1.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'FC102',
      'series': 'VLT HVAC Drive FC 102',
      'description': 'HVAC Application VFD',
      'powerRating': 11.0,
      'voltage': '400V'
    });
    final int fc202Id = await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'FC202',
      'series': 'VLT AQUA Drive FC 202',
      'description': 'Water and Wastewater VFD',
      'powerRating': 1.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'FC202',
      'series': 'VLT AQUA Drive FC 202',
      'description': 'Water and Wastewater VFD',
      'powerRating': 11.0,
      'voltage': '400V'
    });
    final int fc302Id = await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'FC302',
      'series': 'VLT AutomationDrive FC 302',
      'description': 'High Performance Automation VFD',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'FC302',
      'series': 'VLT AutomationDrive FC 302',
      'description': 'High Performance Automation VFD',
      'powerRating': 15.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'FC360',
      'series': 'VLT Compact Starter FC 360',
      'description': 'Compact Bypass Drive',
      'powerRating': 4.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'FC280',
      'series': 'VLT Compact Drive FC 280',
      'description': 'Compact General Purpose Drive',
      'powerRating': 4.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'VACON 10',
      'series': 'VACON 10',
      'description': 'Simple Cost-Effective Drive',
      'powerRating': 0.75,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'VACON 20',
      'series': 'VACON 20',
      'description': 'General Purpose Drive',
      'powerRating': 1.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'VACON 100',
      'series': 'VACON 100',
      'description': 'High Performance Drive',
      'powerRating': 7.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'iC7',
      'series': 'iC7',
      'description': 'Next Generation High Power Drive',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': danfossId,
      'name': 'iC2',
      'series': 'iC2',
      'description': 'Next Generation Compact Drive',
      'powerRating': 1.5,
      'voltage': '400V'
    });

    // ── Allen Bradley additional models ──────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 523',
      'series': 'PowerFlex 523',
      'description': 'Entry-Level AC Drive',
      'powerRating': 2.2,
      'voltage': '480V'
    });
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 4',
      'series': 'PowerFlex 4',
      'description': 'Compact Drive for Basic Applications',
      'powerRating': 0.4,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 4M',
      'series': 'PowerFlex 4M',
      'description': 'Micro Drive',
      'powerRating': 0.4,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 40P',
      'series': 'PowerFlex 40P',
      'description': 'AC Drive with Dynamic Braking',
      'powerRating': 2.2,
      'voltage': '480V'
    });
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 400',
      'series': 'PowerFlex 400',
      'description': 'Fan and Pump Drive',
      'powerRating': 5.5,
      'voltage': '480V'
    });
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 70',
      'series': 'PowerFlex 70',
      'description': 'General Purpose Drive',
      'powerRating': 4.0,
      'voltage': '480V'
    });
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 700',
      'series': 'PowerFlex 700',
      'description': 'High Performance Drive',
      'powerRating': 7.5,
      'voltage': '480V'
    });
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 700L',
      'series': 'PowerFlex 700L',
      'description': 'High Power Drive with LiquiCool',
      'powerRating': 22.0,
      'voltage': '480V'
    });
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 700S',
      'series': 'PowerFlex 700S',
      'description': 'High Performance Vector Drive',
      'powerRating': 15.0,
      'voltage': '480V'
    });
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 753',
      'series': 'PowerFlex 753',
      'description': 'General Purpose Drive with Safe Speed',
      'powerRating': 11.0,
      'voltage': '480V'
    });
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 755',
      'series': 'PowerFlex 755',
      'description': 'High Performance Drive with Safe Torque',
      'powerRating': 15.0,
      'voltage': '480V'
    });
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 755T',
      'series': 'PowerFlex 755T',
      'description': 'Regenerative Drive System',
      'powerRating': 30.0,
      'voltage': '480V'
    });
    await db.insert('vfd_models', {
      'vendorId': allenBradleyId,
      'name': 'PowerFlex 755TS',
      'series': 'PowerFlex 755TS',
      'description': 'Regenerative Drive with STO',
      'powerRating': 30.0,
      'voltage': '480V'
    });

    // ── Hitachi additional models ────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'SJ-P1',
      'series': 'SJ-P1',
      'description': 'High Performance Inverter',
      'powerRating': 2.2,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'WJ-C1',
      'series': 'WJ-C1',
      'description': 'Compact Multi-Function Inverter',
      'powerRating': 1.5,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'NE-S1',
      'series': 'NE-S1',
      'description': 'Simple Compact VFD',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'X200',
      'series': 'X200',
      'description': 'Multi-Functional VFD',
      'powerRating': 0.4,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'X200',
      'series': 'X200',
      'description': 'Multi-Functional VFD',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'WL200',
      'series': 'WL200',
      'description': 'Sensorless Vector Drive',
      'powerRating': 2.2,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'L200',
      'series': 'L200',
      'description': 'Inverter for Fan and Pump',
      'powerRating': 1.5,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'SJ200',
      'series': 'SJ200',
      'description': 'Sensorless Vector Inverter',
      'powerRating': 1.5,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'SJ300',
      'series': 'SJ300',
      'description': 'Flux Vector Drive',
      'powerRating': 4.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'L300P',
      'series': 'L300P',
      'description': 'High Functionality VFD',
      'powerRating': 4.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'SJ700D',
      'series': 'SJ700D',
      'description': 'Dynamic Braking Drive',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': hitachiId,
      'name': 'SJ700B',
      'series': 'SJ700B',
      'description': 'Built-in Brake Resistor Drive',
      'powerRating': 5.5,
      'voltage': '400V'
    });

    // ── Mitsubishi additional models ─────────────────────────────────
    final int frA800Id = await db.insert('vfd_models', {
      'vendorId': mitsubishiId,
      'name': 'FR-A800',
      'series': 'A800',
      'description': 'iQ Platform Compatible Inverter',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': mitsubishiId,
      'name': 'FR-A800',
      'series': 'A800',
      'description': 'iQ Platform Compatible Inverter',
      'powerRating': 22.0,
      'voltage': '400V'
    });
    final int frF800Id = await db.insert('vfd_models', {
      'vendorId': mitsubishiId,
      'name': 'FR-F800',
      'series': 'F800',
      'description': 'Fan and Pump Inverter',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': mitsubishiId,
      'name': 'FR-F800',
      'series': 'F800',
      'description': 'Fan and Pump Inverter',
      'powerRating': 22.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': mitsubishiId,
      'name': 'FR-E800',
      'series': 'E800',
      'description': 'Advanced Sensorless Vector Inverter',
      'powerRating': 2.2,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': mitsubishiId,
      'name': 'FR-E800',
      'series': 'E800',
      'description': 'Advanced Sensorless Vector Inverter',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': mitsubishiId,
      'name': 'FR-CS80',
      'series': 'CS80',
      'description': 'Compact Simple Inverter',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': mitsubishiId,
      'name': 'FR-CS80',
      'series': 'CS80',
      'description': 'Compact Simple Inverter',
      'powerRating': 2.2,
      'voltage': '400V'
    });

    // ── LS Electric additional models ────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': lsId,
      'name': 'L100',
      'series': 'L100',
      'description': 'Compact General Purpose VFD',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': lsId,
      'name': 'M100',
      'series': 'M100',
      'description': 'Micro Drive',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': lsId,
      'name': 'G100',
      'series': 'G100',
      'description': 'General Purpose Vector Drive',
      'powerRating': 0.75,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': lsId,
      'name': 'G100',
      'series': 'G100',
      'description': 'General Purpose Vector Drive',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': lsId,
      'name': 'S100',
      'series': 'S100',
      'description': 'Simple Compact Drive',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': lsId,
      'name': 'H100',
      'series': 'H100',
      'description': 'HVAC Drive for Fan and Pump',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': lsId,
      'name': 'iE5',
      'series': 'iE5',
      'description': 'Economy Drive',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': lsId,
      'name': 'iS7',
      'series': 'iS7',
      'description': 'High Performance Vector Drive',
      'powerRating': 7.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': lsId,
      'name': 'iP5A',
      'series': 'iP5A',
      'description': 'Advanced Vector Drive',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': lsId,
      'name': 'iC5',
      'series': 'iC5',
      'description': 'Compact Drive',
      'powerRating': 0.75,
      'voltage': '230V'
    });

    // ── WEG additional models ────────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': wegId,
      'name': 'CFW09',
      'series': 'CFW09',
      'description': 'High Performance VFD',
      'powerRating': 4.0,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': wegId,
      'name': 'CFW10',
      'series': 'CFW10',
      'description': 'Mini Drive',
      'powerRating': 0.37,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': wegId,
      'name': 'CFW11',
      'series': 'CFW11',
      'description': 'High Performance Drive',
      'powerRating': 7.5,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': wegId,
      'name': 'CFW100 G2',
      'series': 'CFW100 G2',
      'description': 'Compact Drive Second Generation',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': wegId,
      'name': 'CFW501',
      'series': 'CFW501',
      'description': 'Economy Drive for Simple Machines',
      'powerRating': 5.5,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': wegId,
      'name': 'CFW700',
      'series': 'CFW700',
      'description': 'Machine Drive',
      'powerRating': 15.0,
      'voltage': '380V'
    });
    await db.insert('vfd_models', {
      'vendorId': wegId,
      'name': 'CFW701',
      'series': 'CFW701',
      'description': 'Machine Drive with Safety Functions',
      'powerRating': 15.0,
      'voltage': '380V'
    });

    // ── Fuji FRENIC models ───────────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': fujiId,
      'name': 'FRENIC-Mini',
      'series': 'FRENIC-Mini',
      'description': 'Compact VFD for Machinery',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': fujiId,
      'name': 'FRENIC-Mini',
      'series': 'FRENIC-Mini',
      'description': 'Compact VFD for Machinery',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': fujiId,
      'name': 'FRENIC-Multi',
      'series': 'FRENIC-Multi',
      'description': 'Multi-Purpose VFD',
      'powerRating': 2.2,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': fujiId,
      'name': 'FRENIC-Multi',
      'series': 'FRENIC-Multi',
      'description': 'Multi-Purpose VFD',
      'powerRating': 7.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': fujiId,
      'name': 'FRENIC-Eco',
      'series': 'FRENIC-Eco',
      'description': 'Energy Saving Fan Pump VFD',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': fujiId,
      'name': 'FRENIC-Mega',
      'series': 'FRENIC-Mega',
      'description': 'High Performance Vector VFD',
      'powerRating': 7.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': fujiId,
      'name': 'FRENIC-HVAC',
      'series': 'FRENIC-HVAC',
      'description': 'HVAC Application VFD',
      'powerRating': 11.0,
      'voltage': '400V'
    });

    // ── Omron additional models ──────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': omronId,
      'name': '3G3MX2-V1',
      'series': '3G3MX2-V1',
      'description': 'Multi-Function Inverter V1',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': omronId,
      'name': '3G3MX2-V2',
      'series': '3G3MX2-V2',
      'description': 'Multi-Function Inverter V2',
      'powerRating': 1.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': omronId,
      'name': 'RX2',
      'series': 'RX2',
      'description': 'High Performance Vector Drive',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': omronId,
      'name': 'MX2',
      'series': 'MX2',
      'description': 'High Performance VFD',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': omronId,
      'name': 'CR700',
      'series': 'CR700',
      'description': 'Compact Drive',
      'powerRating': 0.4,
      'voltage': '230V'
    });

    // ── Toshiba models ───────────────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': toshibaId,
      'name': 'VF-S15',
      'series': 'VF-S15',
      'description': 'Simple Compact VFD',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': toshibaId,
      'name': 'VF-AS3',
      'series': 'VF-AS3',
      'description': 'General Purpose Drive',
      'powerRating': 4.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': toshibaId,
      'name': 'VF-PS1',
      'series': 'VF-PS1',
      'description': 'Fan Pump Drive',
      'powerRating': 7.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': toshibaId,
      'name': 'VF-FS1',
      'series': 'VF-FS1',
      'description': 'Fan and Blower Drive',
      'powerRating': 11.0,
      'voltage': '400V'
    });

    // ── Yaskawa additional models ────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': yaskawaId,
      'name': 'GA500',
      'series': 'GA500',
      'description': 'Compact Drive for Machines',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': yaskawaId,
      'name': 'GA500',
      'series': 'GA500',
      'description': 'Compact Drive for Machines',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': yaskawaId,
      'name': 'GA700',
      'series': 'GA700',
      'description': 'High Performance Drive',
      'powerRating': 7.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': yaskawaId,
      'name': 'U1000',
      'series': 'U1000',
      'description': 'Matrix Drive (Regenerative)',
      'powerRating': 15.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': yaskawaId,
      'name': 'P1000',
      'series': 'P1000',
      'description': 'Fan and Pump Drive',
      'powerRating': 11.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': yaskawaId,
      'name': 'L1000A',
      'series': 'L1000A',
      'description': 'Elevator Drive',
      'powerRating': 7.5,
      'voltage': '400V'
    });

    // ── KEB models ───────────────────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': kebId,
      'name': 'COMBIVERT F5',
      'series': 'F5',
      'description': 'General Purpose Drive',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': kebId,
      'name': 'COMBIVERT S6',
      'series': 'S6',
      'description': 'Servo Drive',
      'powerRating': 3.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': kebId,
      'name': 'COMBIVERT C6',
      'series': 'C6',
      'description': 'Compact Drive',
      'powerRating': 0.75,
      'voltage': '230V'
    });

    // ── Parker models ────────────────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': parkerId,
      'name': 'AC10',
      'series': 'AC10',
      'description': 'General Purpose Drive',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': parkerId,
      'name': 'AC30',
      'series': 'AC30',
      'description': 'General Purpose Drive',
      'powerRating': 4.0,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': parkerId,
      'name': 'AC890',
      'series': 'AC890',
      'description': 'High Performance Vector Drive',
      'powerRating': 15.0,
      'voltage': '400V'
    });

    // ── L&T models ───────────────────────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': ltId,
      'name': 'iDrive',
      'series': 'iDrive',
      'description': 'General Purpose VFD',
      'powerRating': 0.75,
      'voltage': '230V'
    });
    await db.insert('vfd_models', {
      'vendorId': ltId,
      'name': 'MX',
      'series': 'MX',
      'description': 'Compact Micro Drive',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': ltId,
      'name': 'e-Drive',
      'series': 'e-Drive',
      'description': 'Energy Efficient Drive',
      'powerRating': 5.5,
      'voltage': '400V'
    });

    // ── Nidec (Control Techniques) models ────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': nidecId,
      'name': 'Unidrive M200',
      'series': 'Unidrive M200',
      'description': 'Open Loop Induction Motor Drive',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': nidecId,
      'name': 'Unidrive M400',
      'series': 'Unidrive M400',
      'description': 'Elevator and Hoist Drive',
      'powerRating': 7.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': nidecId,
      'name': 'Unidrive M600',
      'series': 'Unidrive M600',
      'description': 'High Performance Closed Loop Drive',
      'powerRating': 7.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': nidecId,
      'name': 'Commander C200',
      'series': 'Commander C200',
      'description': 'Cost Effective VFD',
      'powerRating': 1.5,
      'voltage': '230V'
    });

    // ── INOVANCE additional models ───────────────────────────────────
    await db.insert('vfd_models', {
      'vendorId': inovanceId,
      'name': 'MD290',
      'series': 'MD290',
      'description': 'High Performance Drive',
      'powerRating': 5.5,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': inovanceId,
      'name': 'MD310',
      'series': 'MD310',
      'description': 'General Purpose Drive',
      'powerRating': 2.2,
      'voltage': '400V'
    });
    await db.insert('vfd_models', {
      'vendorId': inovanceId,
      'name': 'MD500',
      'series': 'MD500',
      'description': 'High Performance Servo VFD',
      'powerRating': 7.5,
      'voltage': '400V'
    });

    // ══════════════════════════════════════════════════════════════════
    // PARAMETERS FOR NEW MODELS
    // ══════════════════════════════════════════════════════════════════

    // ── Params: Siemens MM420 ────────────────────────────────────────
    await _insertParams(db, mm420Id, [
      [
        'P0.003',
        'Access Level',
        '1=Standard, 2=Extended, 3=Expert',
        '1',
        '1',
        '4',
        'General'
      ],
      [
        'P0.304',
        'Motor Rated Voltage',
        'Motor Nameplate Voltage (V)',
        '230',
        '10',
        '2000',
        'Motor'
      ],
      [
        'P0.305',
        'Motor Rated Current',
        'Motor Nameplate Current (A)',
        '3.7',
        '0.01',
        '10000',
        'Motor'
      ],
      [
        'P0.307',
        'Motor Rated Power',
        'Motor Nameplate Power (kW)',
        '0.75',
        '0.01',
        '2000',
        'Motor'
      ],
      [
        'P1.000',
        'Freq Setpoint',
        'Frequency Reference (Hz)',
        '0.0',
        '0.0',
        '650.0',
        'Setpoints'
      ],
      [
        'P1.120',
        'Ramp Up Time',
        'Acceleration Time 0→Max (s)',
        '10.0',
        '0.0',
        '650.0',
        'Ramp'
      ],
      [
        'P1.121',
        'Ramp Down Time',
        'Deceleration Time Max�? (s)',
        '10.0',
        '0.0',
        '650.0',
        'Ramp'
      ],
    ]);

    // ── Params: Danfoss FC51 ─────────────────────────────────────────
    await _insertParams(db, fc51Id, [
      [
        '1-20',
        'Motor Power',
        'Motor Nameplate Power (kW)',
        '0.75',
        '0.0',
        '7.5',
        'Motor Load'
      ],
      [
        '1-22',
        'Motor Voltage',
        'Motor Nameplate Voltage (V)',
        '400',
        '50',
        '1000',
        'Motor Load'
      ],
      [
        '1-24',
        'Motor Current',
        'Motor Nameplate Current (A)',
        '1.8',
        '0.0',
        '1000',
        'Motor Load'
      ],
      [
        '1-25',
        'Motor Nominal Speed',
        'Motor Nameplate Speed (RPM)',
        '1420',
        '100',
        '9999',
        'Motor Load'
      ],
      [
        '3-02',
        'Min Reference',
        'Minimum Reference (Hz)',
        '0.0',
        '0.0',
        '400.0',
        'Reference'
      ],
      [
        '3-03',
        'Max Reference',
        'Maximum Reference (Hz)',
        '50.0',
        '0.0',
        '400.0',
        'Reference'
      ],
      [
        '3-41',
        'Ramp 1 Up Time',
        'Acceleration Time (s)',
        '3.0',
        '0.01',
        '3600.0',
        'Ramp'
      ],
      [
        '3-42',
        'Ramp 1 Down Time',
        'Deceleration Time (s)',
        '3.0',
        '0.01',
        '3600.0',
        'Ramp'
      ],
    ]);

    // ── Params: Danfoss FC102 ────────────────────────────────────────
    await _insertParams(db, fc102Id, [
      [
        '1-20',
        'Motor Power',
        'Motor Nameplate Power (kW)',
        '1.5',
        '0.0',
        '400',
        'Motor'
      ],
      [
        '1-22',
        'Motor Voltage',
        'Motor Nameplate Voltage (V)',
        '400',
        '50',
        '1000',
        'Motor'
      ],
      [
        '1-24',
        'Motor Current',
        'Motor Nameplate Current (A)',
        '3.7',
        '0.0',
        '1000',
        'Motor'
      ],
      [
        '3-02',
        'Min Reference',
        'Minimum Frequency Reference (Hz)',
        '0.0',
        '0.0',
        '400',
        'Reference'
      ],
      [
        '3-03',
        'Max Reference',
        'Maximum Frequency Reference (Hz)',
        '50.0',
        '0.0',
        '400',
        'Reference'
      ],
      [
        '3-41',
        'Ramp 1 Up Time',
        'Acceleration Time (s)',
        '20.0',
        '0.01',
        '3600',
        'Ramp'
      ],
      [
        '3-42',
        'Ramp 1 Down Time',
        'Deceleration Time (s)',
        '20.0',
        '0.01',
        '3600',
        'Ramp'
      ],
      [
        '22-20',
        'Low Flow Timer',
        'Timer for Low Flow Detection (s)',
        '10.0',
        '0.0',
        '600',
        'HVAC'
      ],
      [
        '22-23',
        'No-Flow Function',
        'Action at No Flow Detection',
        '0',
        '0',
        '5',
        'HVAC'
      ],
    ]);

    // ── Params: Danfoss FC302 ────────────────────────────────────────
    await _insertParams(db, fc302Id, [
      [
        '1-00',
        'Control Mode',
        '0=Open Loop Speed, 1=Torque, 3=Closed Loop',
        '0',
        '0',
        '3',
        'Control'
      ],
      [
        '1-20',
        'Motor Power',
        'Motor Nameplate Power (kW)',
        '2.2',
        '0.0',
        '400',
        'Motor'
      ],
      [
        '1-22',
        'Motor Voltage',
        'Motor Nameplate Voltage (V)',
        '400',
        '50',
        '1000',
        'Motor'
      ],
      [
        '1-24',
        'Motor Current',
        'Motor Nameplate Current (A)',
        '5.0',
        '0.0',
        '1000',
        'Motor'
      ],
      [
        '3-02',
        'Min Reference',
        'Minimum Reference (Hz)',
        '0.0',
        '0.0',
        '400',
        'Reference'
      ],
      [
        '3-03',
        'Max Reference',
        'Maximum Reference (Hz)',
        '50.0',
        '0.0',
        '400',
        'Reference'
      ],
      [
        '3-41',
        'Ramp 1 Up Time',
        'Acceleration Time (s)',
        '5.0',
        '0.01',
        '3600',
        'Ramp'
      ],
      [
        '3-42',
        'Ramp 1 Down Time',
        'Deceleration Time (s)',
        '5.0',
        '0.01',
        '3600',
        'Ramp'
      ],
    ]);

    // ── Params: Allen Bradley PowerFlex 4 ───────────────────────────
    await _insertParams(db, powerFlex40Id, [
      [
        'P031',
        'Motor NP Volts',
        'Motor Nameplate Voltage (V)',
        '230',
        '0',
        '480',
        'Motor'
      ],
      [
        'P032',
        'Motor NP Hertz',
        'Motor Nameplate Frequency (Hz)',
        '60',
        '15',
        '400',
        'Motor'
      ],
      [
        'P033',
        'Motor OL Current',
        'Motor Overload Current (A)',
        '2.0',
        '0.0',
        '99.9',
        'Protection'
      ],
      [
        'A051',
        'Accel Time 1',
        'Acceleration Time (s)',
        '10.0',
        '0.1',
        '600',
        'Ramp'
      ],
      [
        'A052',
        'Decel Time 1',
        'Deceleration Time (s)',
        '10.0',
        '0.1',
        '600',
        'Ramp'
      ],
      [
        'A067',
        'Freq Command Sel',
        '0=Keypad, 1=Analog, 2=DPI',
        '1',
        '0',
        '5',
        'Command'
      ],
      [
        'A068',
        'Speed Ref A Hi',
        'High Speed Reference (Hz)',
        '60.0',
        '0.0',
        '400',
        'Limits'
      ],
      [
        'A069',
        'Speed Ref A Lo',
        'Low Speed Reference (Hz)',
        '0.0',
        '0.0',
        '400',
        'Limits'
      ],
    ]);

    // ── Params: Mitsubishi FR-A800 ───────────────────────────────────
    await _insertParams(db, frA800Id, [
      [
        'Pr.0',
        'Torque Boost',
        'Manual Torque Boost (V)',
        '6',
        '0',
        '30',
        'V/F Control'
      ],
      [
        'Pr.1',
        'Max Frequency',
        'Maximum Frequency (Hz)',
        '120.0',
        '0.0',
        '590.0',
        'Frequency'
      ],
      [
        'Pr.2',
        'Min Frequency',
        'Minimum Frequency (Hz)',
        '0.0',
        '0.0',
        '590.0',
        'Frequency'
      ],
      [
        'Pr.7',
        'Accel Time',
        'Acceleration Time (s)',
        '5.0',
        '0.0',
        '3600.0',
        'Ramp'
      ],
      [
        'Pr.8',
        'Decel Time',
        'Deceleration Time (s)',
        '5.0',
        '0.0',
        '3600.0',
        'Ramp'
      ],
      [
        'Pr.71',
        'Control Mode',
        '0=V/F, 1=Flux Vector, 20=PM Motor',
        '0',
        '0',
        '20',
        'Control'
      ],
      [
        'Pr.80',
        'Motor Capacity',
        'Motor Rated Power (kW)',
        '5.5',
        '0.0',
        '110',
        'Motor'
      ],
      [
        'Pr.83',
        'Rated Motor Voltage',
        'Motor Nameplate Voltage (V)',
        '400',
        '0',
        '1000',
        'Motor'
      ],
    ]);

    // ── Params: Mitsubishi FR-F800 ───────────────────────────────────
    await _insertParams(db, frF800Id, [
      [
        'Pr.1',
        'Max Frequency',
        'Maximum Frequency (Hz)',
        '120.0',
        '0.0',
        '590.0',
        'Frequency'
      ],
      [
        'Pr.7',
        'Accel Time',
        'Acceleration Time (s)',
        '10.0',
        '0.0',
        '3600.0',
        'Ramp'
      ],
      [
        'Pr.8',
        'Decel Time',
        'Deceleration Time (s)',
        '10.0',
        '0.0',
        '3600.0',
        'Ramp'
      ],
      [
        'Pr.9',
        'OL Current',
        'Electronic Thermal O/L (A)',
        '0.0',
        '0.0',
        '500',
        'Protection'
      ],
      [
        'Pr.80',
        'Motor Capacity',
        'Motor Rated Power (kW)',
        '5.5',
        '0.0',
        '110',
        'Motor'
      ],
      [
        'Pr.128',
        'PID Action',
        '0=Disabled, 10=Positive, 11=Reverse',
        '0',
        '0',
        '11',
        'PID'
      ],
    ]);

    // ── Params: Schneider ATV12 ──────────────────────────────────────
    await _insertParams(db, atv12Id, [
      [
        'bFr',
        'Standard Frequency',
        '50Hz or 60Hz grid',
        '50',
        '50',
        '60',
        'Motor Control'
      ],
      [
        'ACC',
        'Acceleration',
        'Acceleration Time (s)',
        '3.0',
        '0.1',
        '999.9',
        'Ramp'
      ],
      [
        'dEC',
        'Deceleration',
        'Deceleration Time (s)',
        '3.0',
        '0.1',
        '999.9',
        'Ramp'
      ],
      [
        'LSP',
        'Low Speed',
        'Low Speed Frequency (Hz)',
        '0.0',
        '0.0',
        '500',
        'Limits'
      ],
      [
        'HSP',
        'High Speed',
        'High Speed Frequency (Hz)',
        '50.0',
        '0.0',
        '500',
        'Limits'
      ],
      [
        'ItH',
        'Motor Thermal',
        'Motor Thermal Protection Current (A)',
        '0.9',
        '0.0',
        '65535',
        'Protection'
      ],
    ]);

    // ── Params: Schneider ATV61 ──────────────────────────────────────
    await _insertParams(db, atv61Id, [
      [
        'ACC',
        'Acceleration',
        'Acceleration Ramp Time (s)',
        '5.0',
        '0.01',
        '6000',
        'Ramp'
      ],
      [
        'dEC',
        'Deceleration',
        'Deceleration Ramp Time (s)',
        '5.0',
        '0.01',
        '6000',
        'Ramp'
      ],
      [
        'LSP',
        'Low Speed',
        'Low Speed Frequency (Hz)',
        '0.0',
        '0.0',
        '599',
        'Limits'
      ],
      [
        'HSP',
        'High Speed',
        'High Speed Frequency (Hz)',
        '50.0',
        '0.0',
        '599',
        'Limits'
      ],
      [
        'nPr',
        'Motor Power',
        'Motor Rated Power (kW)',
        '7.5',
        '0.0',
        '75000',
        'Motor'
      ],
      [
        'UnS',
        'Motor Voltage',
        'Motor Rated Voltage (V)',
        '400',
        '100',
        '690',
        'Motor'
      ],
      [
        'nCr',
        'Motor Current',
        'Motor Rated Current (A)',
        '16.0',
        '0.0',
        '65535',
        'Motor'
      ],
      [
        'nSP',
        'Motor Speed',
        'Motor Rated Speed (RPM)',
        '1450',
        '0',
        '60000',
        'Motor'
      ],
    ]);

    // ── Params: Schneider ATV71 ──────────────────────────────────────
    await _insertParams(db, atv71Id, [
      [
        'ACC',
        'Acceleration',
        'Acceleration Ramp Time (s)',
        '3.0',
        '0.01',
        '6000',
        'Ramp'
      ],
      [
        'dEC',
        'Deceleration',
        'Deceleration Ramp Time (s)',
        '3.0',
        '0.01',
        '6000',
        'Ramp'
      ],
      [
        'LSP',
        'Low Speed',
        'Low Speed Frequency (Hz)',
        '0.0',
        '0.0',
        '599',
        'Limits'
      ],
      [
        'HSP',
        'High Speed',
        'High Speed Frequency (Hz)',
        '50.0',
        '0.0',
        '599',
        'Limits'
      ],
      [
        'nPr',
        'Motor Power',
        'Motor Rated Power (kW)',
        '7.5',
        '0.0',
        '75000',
        'Motor'
      ],
      [
        'UnS',
        'Motor Voltage',
        'Motor Rated Voltage (V)',
        '400',
        '100',
        '690',
        'Motor'
      ],
      [
        'nCr',
        'Motor Current',
        'Motor Rated Current (A)',
        '16.0',
        '0.0',
        '65535',
        'Motor'
      ],
      [
        'Ctt',
        'Motor Control',
        '0=SVC, 2=FVC, 3=Sync',
        '0',
        '0',
        '5',
        'Control'
      ],
    ]);

    // ── Params: LS G100 ──────────────────────────────────────────────
    await _insertParams(db, ig5AId, [
      [
        'DRV',
        'Drive Mode',
        '0=Keypad, 1=Run Fwd, 2=RS485',
        '0',
        '0',
        '3',
        'Basic'
      ],
      [
        'ACC',
        'Accel Time',
        'Acceleration Time (s)',
        '5.0',
        '0.0',
        '6000',
        'Basic'
      ],
      [
        'DEC',
        'Decel Time',
        'Deceleration Time (s)',
        '10.0',
        '0.0',
        '6000',
        'Basic'
      ],
      [
        'FRQ',
        'Freq Source',
        '0=Keypad, 1=V0, 2=I, 3=RS485',
        '0',
        '0',
        '7',
        'Basic'
      ],
      [
        'Fmax',
        'Max Frequency',
        'Maximum Frequency (Hz)',
        '60.0',
        '40.0',
        '400',
        'Frequency'
      ],
      [
        'Fbase',
        'Base Frequency',
        'Base Frequency (Hz)',
        '60.0',
        '30.0',
        '400',
        'Frequency'
      ],
      [
        'OVT',
        'Motor OL Level',
        'Motor Overload Trip Level (%)',
        '100',
        '50',
        '200',
        'Protection'
      ],
    ]);

    // ── Manuals: new models ──────────────────────────────────────────
    final newManuals = [
      [
        mm420Id,
        'MICROMASTER 420 Operating Manual',
        'User Manual',
        'English',
        3
      ],
      [
        mm430Id,
        'MICROMASTER 430 Operating Manual',
        'User Manual',
        'English',
        2
      ],
      [
        fc51Id,
        'VLT Micro Drive FC 51 Operating Instructions',
        'User Manual',
        'English',
        4
      ],
      [
        fc102Id,
        'VLT HVAC Drive FC 102 Programming Guide',
        'User Manual',
        'English',
        5
      ],
      [
        fc202Id,
        'VLT AQUA Drive FC 202 Operating Instructions',
        'User Manual',
        'English',
        3
      ],
      [
        fc302Id,
        'VLT AutomationDrive FC 302 Programming Guide',
        'User Manual',
        'English',
        6
      ],
      [atv12Id, 'Altivar 12 User Manual', 'User Manual', 'English', 2],
      [atv31Id, 'Altivar 31 User Manual', 'User Manual', 'English', 2],
      [atv32Id, 'Altivar 32 User Manual', 'User Manual', 'English', 2],
      [atv61Id, 'Altivar 61 Programming Manual', 'User Manual', 'English', 3],
      [atv71Id, 'Altivar 71 Programming Manual', 'User Manual', 'English', 3],
      [frA800Id, 'FR-A800 Instruction Manual', 'User Manual', 'English', 2],
      [frF800Id, 'FR-F800 Instruction Manual', 'User Manual', 'English', 2],
    ];
    for (final m in newManuals) {
      await db.insert('vfd_manuals', {
        'modelId': m[0],
        'title': m[1],
        'manualType': m[2],
        'filePath': '',
        'language': m[3],
        'version': m[4],
      });
    }

    // ── Protocols for Fuji ────────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': fujiId,
      'name': 'Modbus TCP',
      'type': 'Ethernet',
      'description': 'Ethernet Modbus TCP',
      'commCard': 'OPC-ENT'
    });
    await db.insert('protocols', {
      'vendorId': fujiId,
      'name': 'PROFIBUS DP',
      'type': 'Serial',
      'description': 'PROFIBUS DP',
      'commCard': 'OPC-PDP'
    });
    await db.insert('protocols', {
      'vendorId': fujiId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP',
      'commCard': 'OPC-ENT2'
    });
    await db.insert('protocols', {
      'vendorId': fujiId,
      'name': 'Hard Wire (Direct I/O)',
      'type': 'Direct',
      'description': 'Direct I/O control via analog/digital inputs'
    });

    // ── Protocols for L&T ─────────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': ltId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU',
      'commCard': 'Built-in'
    });
    await db.insert('protocols', {
      'vendorId': ltId,
      'name': 'Hard Wire',
      'type': 'Direct',
      'description': 'Direct I/O control'
    });

    // ── Protocols for Nidec ───────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': nidecId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU',
      'commCard': 'Built-in'
    });
    await db.insert('protocols', {
      'vendorId': nidecId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP',
      'commCard': 'SI-EtherNet/IP'
    });
    await db.insert('protocols', {
      'vendorId': nidecId,
      'name': 'PROFIBUS DP',
      'type': 'Serial',
      'description': 'PROFIBUS DP',
      'commCard': 'SI-Profibus'
    });
    await db.insert('protocols', {
      'vendorId': nidecId,
      'name': 'Hard Wire',
      'type': 'Direct',
      'description': 'Direct I/O control'
    });

    // ── Protocols for KEB ─────────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': kebId,
      'name': 'EtherCAT',
      'type': 'Ethernet',
      'description': 'EtherCAT real-time Ethernet',
      'commCard': 'ECT-01'
    });
    await db.insert('protocols', {
      'vendorId': kebId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP',
      'commCard': 'EIP-01'
    });
    await db.insert('protocols', {
      'vendorId': kebId,
      'name': 'PROFIBUS',
      'type': 'Serial',
      'description': 'PROFIBUS DP',
      'commCard': 'PFB-01'
    });

    // ── Protocols for Parker ─────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': parkerId,
      'name': 'Modbus RTU',
      'type': 'Serial',
      'description': 'RS485 Modbus RTU',
      'commCard': 'Built-in'
    });
    await db.insert('protocols', {
      'vendorId': parkerId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP',
      'commCard': 'EIP-01'
    });
    await db.insert('protocols', {
      'vendorId': parkerId,
      'name': 'PROFIBUS',
      'type': 'Serial',
      'description': 'PROFIBUS DP',
      'commCard': 'PFB-01'
    });

    // ── Protocols for Toshiba ─────────────────────────────────────────
    await db.insert('protocols', {
      'vendorId': toshibaId,
      'name': 'Modbus TCP',
      'type': 'Ethernet',
      'description': 'Ethernet Modbus TCP',
      'commCard': 'VFAS1-ETH'
    });
    await db.insert('protocols', {
      'vendorId': toshibaId,
      'name': 'EtherNet/IP',
      'type': 'Ethernet',
      'description': 'EtherNet/IP',
      'commCard': 'VFAS1-EIP'
    });
    await db.insert('protocols', {
      'vendorId': toshibaId,
      'name': 'Hard Wire',
      'type': 'Direct',
      'description': 'Direct I/O control'
    });
  }

  /// Helper to batch-insert parameters for a model.
  Future<void> _insertParams(
      Database db, int modelId, List<List<String>> params) async {
    for (final p in params) {
      await db.insert('vfd_parameters', {
        'modelId': modelId,
        'paramCode': p[0],
        'paramName': p[1],
        'description': p[2],
        'defaultValue': p[3],
        'minValue': p[4],
        'maxValue': p[5],
        'groupName': p[6],
      });
    }
  }

  /// Helper to batch-insert protocol-specific parameters.
  Future<void> _insertProtocolParams(
      Database db, int protocolId, List<List<String>> params) async {
    for (final p in params) {
      await db.insert('protocol_parameters', {
        'protocolId': protocolId,
        'paramCode': p[0],
        'paramName': p[1],
        'description': p[2],
        'defaultValue': p[3],
        'minValue': p[4],
        'maxValue': p[5],
        'groupName': p[6],
      });
    }
  }

  // ── Read Operations ──────────────────────────────────────────────

  Future<List<Vendor>> getAllVendors() async {
    try {
      final db = await database;
      final result = await db.query('vendors');
      return result.map((map) => Vendor.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to load vendors: $e',
        code: 'QUERY_ERROR',
        originalException: e,
      );
    }
  }

  Future<List<VfdModel>> getModelsByVendor(int vendorId) async {
    try {
      final db = await database;
      final result = await db
          .query('vfd_models', where: 'vendorId = ?', whereArgs: [vendorId]);
      return result.map((map) => VfdModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to load models for vendor $vendorId: $e',
        code: 'QUERY_ERROR',
        originalException: e,
      );
    }
  }

  Future<List<VfdModel>> getAllModels() async {
    try {
      final db = await database;
      final result = await db.query('vfd_models');
      return result.map((map) => VfdModel.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to load all models: $e',
        code: 'QUERY_ERROR',
        originalException: e,
      );
    }
  }

  Future<List<VfdParameter>> getParametersByModel(int modelId) async {
    try {
      final db = await database;

      // Direct lookup first
      var result = await db
          .query('vfd_parameters', where: 'modelId = ?', whereArgs: [modelId]);

      // Fallback: find params from another row with same model name + vendor
      if (result.isEmpty) {
        final modelRows = await db.query(
          'vfd_models',
          columns: ['name', 'vendorId'],
          where: 'id = ?',
          whereArgs: [modelId],
          limit: 1,
        );
        if (modelRows.isNotEmpty) {
          final modelName = modelRows.first['name'] as String;
          final vendorId = modelRows.first['vendorId'] as int;
          final allIds = await db.rawQuery(
            'SELECT id FROM vfd_models WHERE name = ? AND vendorId = ?',
            [modelName, vendorId],
          );
          for (final row in allIds) {
            final id = row['id'] as int;
            if (id == modelId) continue;
            result = await db.query(
              'vfd_parameters',
              where: 'modelId = ?',
              whereArgs: [id],
            );
            if (result.isNotEmpty) break;
          }
        }
      }

      return result.map((map) => VfdParameter.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to load parameters for model $modelId: $e',
        code: 'QUERY_ERROR',
        originalException: e,
      );
    }
  }

  Future<List<VfdManual>> getManualsByModel(int modelId) async {
    try {
      final db = await database;
      final result = await db
          .query('vfd_manuals', where: 'modelId = ?', whereArgs: [modelId]);
      return result.map((map) => VfdManual.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to load manuals for model $modelId: $e',
        code: 'QUERY_ERROR',
        originalException: e,
      );
    }
  }

  Future<List<VfdModel>> searchModels(String query) async {
    try {
      if (query.isEmpty) {
        throw ValidationException(
          message: 'Search query cannot be empty',
          code: 'EMPTY_SEARCH',
        );
      }
      final db = await database;
      final result = await db.query(
        'vfd_models',
        where: 'name LIKE ? OR series LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
      );
      return result.map((map) => VfdModel.fromMap(map)).toList();
    } catch (e) {
      if (e is VfdException) rethrow;
      throw DatabaseException(
        message: 'Failed to search models: $e',
        code: 'SEARCH_ERROR',
        originalException: e,
      );
    }
  }

  // ── Cascade Filter Queries ────────────────────────────────────────

  /// Unique model names for a vendor (for name dropdown).
  Future<List<String>> getDistinctModelNamesByVendor(int vendorId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT DISTINCT name FROM vfd_models WHERE vendorId = ? ORDER BY name',
        [vendorId],
      );
      return result.map((r) => r['name'] as String).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to load model names: $e',
        code: 'QUERY_ERROR',
        originalException: e,
      );
    }
  }

  /// Distinct power ratings for a vendor + model name.
  Future<List<double>> getPowerRatingsByVendorAndName(
      int vendorId, String name) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT DISTINCT powerRating FROM vfd_models '
        'WHERE vendorId = ? AND name = ? ORDER BY powerRating',
        [vendorId, name],
      );
      final list = result
          .map((r) => (r['powerRating'] as num).toDouble())
          .where((p) => p > 0)
          .toList()
        ..sort();
      if (list.isEmpty) {
        throw DataNotFoundException(
          message: 'No power ratings found for model: $name',
          code: 'NO_POWER_RATINGS',
        );
      }
      return list;
    } catch (e) {
      if (e is VfdException) rethrow;
      throw DatabaseException(
        message: 'Failed to load power ratings: $e',
        code: 'QUERY_ERROR',
        originalException: e,
      );
    }
  }

  /// Distinct voltages for a vendor + model name + power rating.
  Future<List<String>> getVoltagesByFilter(
      int vendorId, String name, double power) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT DISTINCT voltage FROM vfd_models '
        'WHERE vendorId = ? AND name = ? AND powerRating = ? ORDER BY voltage',
        [vendorId, name, power],
      );
      final voltages = result
          .map((r) => r['voltage'] as String)
          .where((v) => v.isNotEmpty)
          .toList();
      if (voltages.isEmpty) {
        throw DataNotFoundException(
          message: 'No voltages found for model: $name',
          code: 'NO_VOLTAGES',
        );
      }
      return voltages;
    } catch (e) {
      if (e is VfdException) rethrow;
      throw DatabaseException(
        message: 'Failed to load voltages: $e',
        code: 'QUERY_ERROR',
        originalException: e,
      );
    }
  }

  /// Exact model for vendor + name + power + voltage.
  Future<VfdModel?> getModelByFilter(
      int vendorId, String name, double power, String voltage) async {
    try {
      final db = await database;
      final result = await db.query(
        'vfd_models',
        where: 'vendorId = ? AND name = ? AND powerRating = ? AND voltage = ?',
        whereArgs: [vendorId, name, power, voltage],
        limit: 1,
      );
      if (result.isEmpty) {
        return null;
      }
      return VfdModel.fromMap(result.first);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to load model by filter: $e',
        code: 'QUERY_ERROR',
        originalException: e,
      );
    }
  }

  // ── Write Operations ─────────────────────────────────────────────

  Future<void> updateManualFilePath(int id, String filePath) async {
    final db = await database;
    await db.update(
      'vfd_manuals',
      {'filePath': filePath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertManual(VfdManual manual) async {
    final db = await database;
    return await db.insert('vfd_manuals', {
      'modelId': manual.modelId,
      'title': manual.title,
      'manualType': manual.manualType,
      'filePath': manual.filePath,
      'language': manual.language,
      'version': manual.version,
    });
  }

  // ── Fault Code Operations ──────────────────────────────────────────

  Future<List<VfdFault>> getFaultCodesByVendor(String vendorId) async {
    final db = await database;
    final result = await db
        .query('fault_codes', where: 'vendorId = ?', whereArgs: [vendorId]);
    return result.map((map) => VfdFault.fromMap(map)).toList();
  }

  Future<List<VfdFault>> searchFaultCodes(String vendorId, String query) async {
    final db = await database;
    final result = await db.query(
      'fault_codes',
      where: 'vendorId = ? AND (errorCode LIKE ? OR description LIKE ?)',
      whereArgs: [vendorId, '%$query%', '%$query%'],
    );
    return result.map((map) => VfdFault.fromMap(map)).toList();
  }

  Future<VfdFault?> getFaultCode(String vendorId, String errorCode) async {
    final db = await database;
    final result = await db.query(
      'fault_codes',
      where: 'vendorId = ? AND errorCode = ?',
      whereArgs: [vendorId, errorCode],
    );
    if (result.isNotEmpty) {
      return VfdFault.fromMap(result.first);
    }
    return null;
  }

  // ── Protocol Operations ───────────────────────────────────────────

  Future<List<Protocol>> getProtocolsByVendor(int vendorId) async {
    final db = await database;
    final result = await db
        .query('protocols', where: 'vendorId = ?', whereArgs: [vendorId]);
    return result.map((map) => Protocol.fromMap(map)).toList();
  }

  // Get protocols by model ID (model-specific protocols)
  Future<List<Protocol>> getProtocolsByModel(int modelId) async {
    try {
      final db = await database;
      
      // First try to get model-specific protocols
      final modelProtocols = await db.query(
        'protocols',
        where: 'modelId = ?',
        whereArgs: [modelId],
      );
      
      if (modelProtocols.isNotEmpty) {
        return modelProtocols.map((map) => Protocol.fromMap(map)).toList();
      }
      
      // If no model-specific protocols, get vendor protocols
      final modelData = await db.query(
        'vfd_models',
        where: 'id = ?',
        whereArgs: [modelId],
        limit: 1,
      );
      
      if (modelData.isEmpty) {
        throw DataNotFoundException(
          message: 'Model not found',
          code: 'MODEL_NOT_FOUND',
        );
      }
      
      final vendorId = modelData.first['vendorId'] as int;
      
      final vendorProtocols = await db.query(
        'protocols',
        where: 'vendorId = ? AND (modelId IS NULL OR modelId = 0)',
        whereArgs: [vendorId],
      );
      
      return vendorProtocols.map((map) => Protocol.fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to load protocols: $e',
        code: 'QUERY_ERROR',
        originalException: e,
      );
    }
  }

  Future<List<VfdParameter>> getProtocolParameters(int protocolId) async {
    final db = await database;
    final result = await db.query(
      'protocol_parameters',
      where: 'protocolId = ?',
      whereArgs: [protocolId],
    );
    return result.map((map) => VfdParameter.fromMap(map)).toList();
  }

  // ── Drawing Operations ───────────────────────────────────────────

  Future<List<VfdDrawing>> getDrawingsByModel(int modelId) async {
    final db = await database;
    final result = await db
        .query('vfd_drawings', where: 'modelId = ?', whereArgs: [modelId]);
    return result.map((map) => VfdDrawing.fromMap(map)).toList();
  }

  Future<int> insertDrawing(VfdDrawing drawing) async {
    final db = await database;
    return await db.insert('vfd_drawings', {
      'modelId': drawing.modelId,
      'name': drawing.name,
      'filePath': drawing.filePath,
      'fileType': drawing.fileType,
      'uploadedAt': drawing.uploadedAt.toIso8601String(),
    });
  }

  Future<void> deleteDrawing(int id) async {
    final db = await database;
    await db.delete('vfd_drawings', where: 'id = ?', whereArgs: [id]);
  }

  // ── Parameter Value Operations ───────────────────────────────────

  Future<void> saveParameterValue(
      int parameterId, int modelId, String value) async {
    final db = await database;
    final existing = await db.query(
      'parameter_values',
      where: 'parameterId = ? AND modelId = ?',
      whereArgs: [parameterId, modelId],
    );

    if (existing.isEmpty) {
      await db.insert('parameter_values', {
        'parameterId': parameterId,
        'modelId': modelId,
        'value': value,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } else {
      await db.update(
        'parameter_values',
        {
          'value': value,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'parameterId = ? AND modelId = ?',
        whereArgs: [parameterId, modelId],
      );
    }
  }

  Future<Map<int, String>> getParameterValues(int modelId) async {
    final db = await database;
    final result = await db.query(
      'parameter_values',
      where: 'modelId = ?',
      whereArgs: [modelId],
    );

    final Map<int, String> values = {};
    for (final row in result) {
      values[row['parameterId'] as int] = row['value'] as String;
    }
    return values;
  }

  Future<void> clearParameterValues(int modelId) async {
    final db = await database;
    await db
        .delete('parameter_values', where: 'modelId = ?', whereArgs: [modelId]);
  }

  // ── Migration: Model-Specific Protocols ──────────────────────────
  Future<void> _migrateToModelSpecificProtocols(Database db) async {
    LoggingService.info('Migrating to model-specific protocols...', tag: 'DB_MIGRATION');
    
    // Check if modelId column already exists
    final tableInfo = await db.rawQuery('PRAGMA table_info(protocols)');
    final hasModelId = tableInfo.any((col) => col['name'] == 'modelId');
    
    if (!hasModelId) {
      // Add modelId column
      await db.execute('ALTER TABLE protocols ADD COLUMN modelId INTEGER');
      
      // Create index for faster queries
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_protocols_model 
        ON protocols(modelId)
      ''');
      
      LoggingService.info('Added modelId column to protocols table', tag: 'DB_MIGRATION');
    }
    
    // Seed model-specific protocols
    await _seedModelSpecificProtocols(db);
  }

  Future<void> _seedModelSpecificProtocols(Database db) async {
    LoggingService.info('Seeding model-specific protocols...', tag: 'DB_MIGRATION');
    
    // Get all unique models
    final models = await db.rawQuery('''
      SELECT DISTINCT m.id, m.vendorId, m.name, v.name as vendorName
      FROM vfd_models m
      JOIN vendors v ON m.vendorId = v.id
      ORDER BY v.name, m.name
    ''');
    
    int protocolsAdded = 0;
    
    for (final model in models) {
      final modelId = model['id'] as int;
      final vendorId = model['vendorId'] as int;
      final modelName = model['name'] as String;
      final vendorName = model['vendorName'] as String;
      
      // Check if model already has protocols
      final existing = await db.query(
        'protocols',
        where: 'modelId = ?',
        whereArgs: [modelId],
        limit: 1,
      );
      
      if (existing.isNotEmpty) continue;
      
      // Get protocols for this model
      final protocols = _getProtocolsForModel(
        vendorId: vendorId,
        modelId: modelId,
        vendorName: vendorName,
        modelName: modelName,
      );
      
      // Insert protocols
      for (final protocol in protocols) {
        await db.insert('protocols', protocol);
        protocolsAdded++;
      }
    }
    
    LoggingService.info('Added $protocolsAdded model-specific protocols', tag: 'DB_MIGRATION');
  }

  List<Map<String, dynamic>> _getProtocolsForModel({
    required int vendorId,
    required int modelId,
    required String vendorName,
    required String modelName,
  }) {
    // Common protocol for all models
    final commonProtocols = [
      {
        'vendorId': vendorId,
        'modelId': modelId,
        'name': 'Hard Wire (Direct I/O)',
        'type': 'Direct',
        'description': 'Direct I/O control via analog/digital inputs',
        'commCard': null,
      },
    ];
    
    // Vendor-specific protocols
    List<Map<String, dynamic>> vendorProtocols = [];
    
    switch (vendorName) {
      case 'ABB':
        vendorProtocols = [
          {
            'vendorId': vendorId,
            'modelId': modelId,
            'name': 'Modbus RTU',
            'type': 'Serial',
            'description': 'RS485 Modbus RTU communication',
            'commCard': 'Built-in',
          },
          {
            'vendorId': vendorId,
            'modelId': modelId,
            'name': 'PROFIBUS DP',
            'type': 'Serial',
            'description': 'PROFIBUS DP fieldbus',
            'commCard': 'RPBA-01',
          },
          {
            'vendorId': vendorId,
            'modelId': modelId,
            'name': 'EtherNet/IP',
            'type': 'Ethernet',
            'description': 'EtherNet/IP protocol',
            'commCard': 'RETA-01',
          },
        ];
        break;
        
      case 'Schneider':
        vendorProtocols = [
          {
            'vendorId': vendorId,
            'modelId': modelId,
            'name': 'Modbus RTU',
            'type': 'Serial',
            'description': 'RS485 Modbus RTU communication',
            'commCard': 'Built-in',
          },
          {
            'vendorId': vendorId,
            'modelId': modelId,
            'name': 'CANopen',
            'type': 'Serial',
            'description': 'CANopen fieldbus',
            'commCard': 'VW3A8105',
          },
          {
            'vendorId': vendorId,
            'modelId': modelId,
            'name': 'EtherNet/IP',
            'type': 'Ethernet',
            'description': 'EtherNet/IP protocol',
            'commCard': 'VW3A8107',
          },
        ];
        break;
        
      case 'Delta':
        vendorProtocols = [
          {
            'vendorId': vendorId,
            'modelId': modelId,
            'name': 'Modbus RTU',
            'type': 'Serial',
            'description': 'RS485 Modbus RTU communication',
            'commCard': 'Built-in',
          },
          {
            'vendorId': vendorId,
            'modelId': modelId,
            'name': 'Modbus TCP',
            'type': 'Ethernet',
            'description': 'Ethernet Modbus TCP',
            'commCard': 'DVP-SE',
          },
        ];
        break;
        
      case 'Siemens':
        vendorProtocols = [
          {
            'vendorId': vendorId,
            'modelId': modelId,
            'name': 'USS Protocol',
            'type': 'Serial',
            'description': 'USS protocol via RS485',
            'commCard': 'Built-in',
          },
          {
            'vendorId': vendorId,
            'modelId': modelId,
            'name': 'PROFIBUS DP',
            'type': 'Serial',
            'description': 'PROFIBUS DP fieldbus',
            'commCard': 'CBP2',
          },
        ];
        break;
        
      default:
        vendorProtocols = [
          {
            'vendorId': vendorId,
            'modelId': modelId,
            'name': 'Modbus RTU',
            'type': 'Serial',
            'description': 'RS485 Modbus RTU communication',
            'commCard': 'Built-in',
          },
        ];
    }
    
    return [...vendorProtocols, ...commonProtocols];
  }
}
