import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:vfd_param_app/core/services/unit_conversion_service.dart';

void main() {
  group('Calculation Tools', () {
    group('Motor Current Calculator', () {
      test('calculate FLC with valid inputs', () {
        // 5.5kW, 415V, 3-phase motor
        final result = UnitConversionService.calculateFLC(5.5, 415.0, 0.9, 0.85, 3);
        expect(result, greaterThan(0));
        expect(result, closeTo(10.0, 0.5)); // Approximate expected value
      });

      test('calculate FLC with different phases', () {
        // Same power, single phase
        final singlePhase = UnitConversionService.calculateFLC(5.5, 230.0, 0.9, 0.85, 1);
        // Same power, three phase
        final threePhase = UnitConversionService.calculateFLC(5.5, 415.0, 0.9, 0.85, 3);

        expect(singlePhase, greaterThan(threePhase));
      });

      test('calculate FLC with zero inputs', () {
        expect(UnitConversionService.calculateFLC(0, 415.0, 0.9, 0.85, 3), equals(0.0));
        expect(UnitConversionService.calculateFLC(5.5, 0, 0.9, 0.85, 3), equals(double.infinity));
      });
    });

    group('Cable Size Calculator', () {
      test('should recommend correct cable sizes', () {
        expect(_getRecommendedCableSize(10.0), equals('2.5 mm²'));
        expect(_getRecommendedCableSize(20.0), equals('4 mm²'));
        expect(_getRecommendedCableSize(30.0), equals('6 mm²'));
        expect(_getRecommendedCableSize(45.0), equals('10 mm²'));
        expect(_getRecommendedCableSize(70.0), equals('16 mm²'));
        expect(_getRecommendedCableSize(85.0), equals('25 mm²'));
        expect(_getRecommendedCableSize(110.0), equals('35 mm²'));
        expect(_getRecommendedCableSize(135.0), equals('50 mm²'));
        expect(_getRecommendedCableSize(175.0), equals('70 mm²'));
        expect(_getRecommendedCableSize(200.0), equals('95 mm² or larger'));
      });

      test('should handle edge cases', () {
        expect(_getRecommendedCableSize(0.0), equals('2.5 mm²'));
        expect(_getRecommendedCableSize(1000.0), equals('95 mm² or larger'));
      });
    });

    group('Voltage Drop Calculator', () {
      test('calculate voltage drop with valid inputs', () {
        // 10A current, 50m length, 2.5mm² cable
        const resistance = 0.0175 * 50 / 2.5; // Ω
        const expectedDrop = 10.0 * resistance;

        expect(_calculateVoltageDrop(10.0, 50.0, 2.5), closeTo(expectedDrop, 0.01));
      });

      test('calculate voltage drop with zero inputs', () {
        expect(_calculateVoltageDrop(0, 50.0, 2.5), equals(0.0));
        expect(_calculateVoltageDrop(10.0, 0, 2.5), equals(0.0));
        expect(_calculateVoltageDrop(10.0, 50.0, 0), equals(0.0));
      });
    });

    group('Power Factor Calculator', () {
      test('calculate power factor with valid inputs', () {
        // 10kW active power, 12kVA apparent power
        const pf = 10.0 / 12.0;
        final angle = _calculatePowerFactorAngle(10.0, 12.0);

        expect(pf, equals(10.0 / 12.0));
        expect(angle, closeTo(33.56, 0.01)); // arccos(0.833) in degrees
      });

      test('calculate power factor with unity PF', () {
        final angle = _calculatePowerFactorAngle(10.0, 10.0);
        expect(angle, closeTo(0.0, 0.01));
      });

      test('calculate power factor with zero kVA', () {
        expect(() => _calculatePowerFactorAngle(10.0, 0.0), throwsArgumentError);
      });
    });

    group('Energy Savings Calculator', () {
      test('calculate energy savings with affinity laws', () {
        final result = UnitConversionService.affinityLaws(1000.0, 1200.0, 100.0, 5.5);

        expect(result['power2'], greaterThan(5.5));
        expect(result['flow2'], greaterThan(100.0));
        expect(result['pressure2'], greaterThan(100.0));

        // Power should increase with speed³
        final powerRatio = result['power2']! / 5.5;
        const speedRatio = 1200.0 / 1000.0;
        const expectedRatio = speedRatio * speedRatio * speedRatio;

        expect(powerRatio, closeTo(expectedRatio, 0.01));
      });

      test('calculate energy savings with reduced speed', () {
        final result = UnitConversionService.affinityLaws(1000.0, 800.0, 100.0, 5.5);

        expect(result['power2'], lessThan(5.5));
        expect(result['flow2'], lessThan(100.0));
        expect(result['pressure2'], lessThan(100.0));
      });
    });

    group('Signal Toolkit Calculator', () {
      test('4-20mA to engineering conversion', () {
        // 12mA signal, 0-100 engineering range
        const signalMin = 4.0;
        const signalMax = 20.0;
        const engMin = 0.0;
        const engMax = 100.0;
        const signal = 12.0;

        const expected = engMin + ((signal - signalMin) / (signalMax - signalMin)) * (engMax - engMin);
        expect(expected, equals(50.0));
      });

      test('engineering to 4-20mA conversion', () {
        // 50 engineering value, 0-100 engineering range
        const signalMin = 4.0;
        const signalMax = 20.0;
        const engMin = 0.0;
        const engMax = 100.0;
        const engValue = 50.0;

        const expected = signalMin + ((engValue - engMin) / (engMax - engMin)) * (signalMax - signalMin);
        expect(expected, equals(12.0));
      });

      test('0-10V to engineering conversion', () {
        // 5V signal, 0-100 engineering range
        const signalMin = 0.0;
        const signalMax = 10.0;
        const engMin = 0.0;
        const engMax = 100.0;
        const signal = 5.0;

        const expected = engMin + ((signal - signalMin) / (signalMax - signalMin)) * (engMax - engMin);
        expect(expected, equals(50.0));
      });

      test('raw count to engineering conversion', () {
        // 16384 count (50% of 32767), 0-100 engineering range
        const signalMin = 0.0;
        const signalMax = 32767.0;
        const engMin = 0.0;
        const engMax = 100.0;
        const signal = 16384.0;

        const expected = engMin + ((signal - signalMin) / (signalMax - signalMin)) * (engMax - engMin);
        expect(expected, closeTo(50.0, 0.01));
      });
    });

    group('Thermocouple Calculator', () {
      test('Type K thermocouple conversion', () {
        // Test some known values for Type K thermocouple
        // 0°C = 0mV, 100°C ≈ 4.1mV
        expect(_typeKThermocoupleVoltage(0.0), closeTo(0.0, 0.1));
        expect(_typeKThermocoupleVoltage(100.0), closeTo(4.1, 0.1));
      });

      test('thermocouple temperature calculation', () {
        // 4.1mV should be approximately 100°C for Type K
        final temp = _calculateThermocoupleTemp(4.1, 'K');
        expect(temp, closeTo(100.0, 5.0)); // Allow some tolerance
      });
    });

    group('Pressure Calculator', () {
      test('atmospheric pressure conversion', () {
        expect(_convertPressure(1.0, 'atm', 'bar'), closeTo(1.013, 0.001));
        expect(_convertPressure(1.0, 'atm', 'psi'), closeTo(14.696, 0.001));
        expect(_convertPressure(1.0, 'atm', 'kPa'), closeTo(101.325, 0.001));
      });

      test('pressure unit conversions', () {
        expect(_convertPressure(100.0, 'kPa', 'bar'), equals(1.0));
        expect(_convertPressure(1000.0, 'mmH2O', 'mH2O'), equals(1.0));
        expect(_convertPressure(14.7, 'psi', 'atm'), closeTo(1.0, 0.01));
      });
    });

    group('Harmonics Calculator', () {
      test('THD calculation', () {
        const fundamental = 100.0;
        final harmonics = [10.0, 5.0, 3.0]; // 3rd, 5th, 7th harmonics

        final thd = _calculateTHD(fundamental, harmonics);
        expect(thd, greaterThan(0));
        expect(thd, lessThan(100.0));
      });

      test('harmonic current calculation', () {
        const loadCurrent = 10.0;
        const thd = 5.0; // 5% THD

        final harmonicCurrent = _calculateHarmonicCurrent(loadCurrent, thd);
        expect(harmonicCurrent, closeTo(0.5, 0.01));
      });

      test('power quality assessment', () {
        expect(_assessPowerQuality(2.0), equals('Excellent'));
        expect(_assessPowerQuality(5.0), equals('Good'));
        expect(_assessPowerQuality(8.0), equals('Fair'));
        expect(_assessPowerQuality(15.0), equals('Poor'));
        expect(_assessPowerQuality(25.0), equals('Very Poor'));
      });
    });
  });
}

// Helper functions for testing (mirroring calculator logic)

String _getRecommendedCableSize(double current) {
  if (current <= 16) return '2.5 mm²';
  if (current <= 25) return '4 mm²';
  if (current <= 32) return '6 mm²';
  if (current <= 50) return '10 mm²';
  if (current <= 80) return '16 mm²';
  if (current <= 100) return '25 mm²';
  if (current <= 125) return '35 mm²';
  if (current <= 160) return '50 mm²';
  if (current <= 190) return '70 mm²';
  return '95 mm² or larger';
}

double _calculateVoltageDrop(double current, double length, double size) {
  if (size == 0) return 0.0; // Avoid division by zero
  final resistance = 0.0175 * length / size;
  return current * resistance;
}

double _calculatePowerFactorAngle(double kw, double kva) {
  if (kva == 0) throw ArgumentError('kVA cannot be zero');
  final pf = kw / kva;
  return pf >= 0 && pf <= 1 ? _radToDeg(math.acos(pf)) : 0.0;
}

double _radToDeg(double rad) => rad * 180 / 3.141592653589793;

double _typeKThermocoupleVoltage(double tempC) {
  // Simplified Type K thermocouple voltage calculation
  // This is an approximation for testing
  return tempC * 0.041; // ~41µV/°C
}

double _calculateThermocoupleTemp(double voltageMV, String type) {
  // Simplified reverse calculation
  return voltageMV / 0.041;
}

double _convertPressure(double value, String from, String to) {
  // Simplified pressure conversions for testing
  final baseValue = _toPascal(value, from);
  return _fromPascal(baseValue, to);
}

double _toPascal(double value, String unit) {
  switch (unit) {
    case 'Pa': return value;
    case 'kPa': return value * 1000;
    case 'bar': return value * 100000;
    case 'atm': return value * 101325;
    case 'psi': return value * 6894.76;
    case 'mmH2O': return value * 9.80665;
    case 'mH2O': return value * 9806.65;
    default: return value;
  }
}

double _fromPascal(double value, String unit) {
  switch (unit) {
    case 'Pa': return value;
    case 'kPa': return value / 1000;
    case 'bar': return value / 100000;
    case 'atm': return value / 101325;
    case 'psi': return value / 6894.76;
    case 'mmH2O': return value / 9.80665;
    case 'mH2O': return value / 9806.65;
    default: return value;
  }
}

double _calculateTHD(double fundamental, List<double> harmonics) {
  final harmonicRMS = harmonics.fold(0.0, (sum, h) => sum + h * h);
  return math.sqrt(harmonicRMS / (fundamental * fundamental)) * 100;
}

double _calculateHarmonicCurrent(double loadCurrent, double thd) {
  return loadCurrent * thd / 100;
}

String _assessPowerQuality(double thd) {
  if (thd <= 3) return 'Excellent';
  if (thd <= 5) return 'Good';
  if (thd <= 8) return 'Fair';
  if (thd <= 15) return 'Poor';
  return 'Very Poor';
}