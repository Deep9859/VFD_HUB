import 'package:flutter_test/flutter_test.dart';
import 'package:vfd_param_app/core/services/unit_conversion_service.dart';

void main() {
  group('UnitConversionService', () {
    group('Power Conversions', () {
      test('kW to HP conversion', () {
        expect(UnitConversionService.kwToHp(1.0), closeTo(1.341, 0.001));
        expect(UnitConversionService.kwToHp(10.0), closeTo(13.41, 0.001));
        expect(UnitConversionService.kwToHp(0.0), equals(0.0));
      });

      test('HP to kW conversion', () {
        expect(UnitConversionService.hpToKw(1.0), closeTo(0.7457, 0.001));
        expect(UnitConversionService.hpToKw(10.0), closeTo(7.457, 0.001));
        expect(UnitConversionService.hpToKw(0.0), equals(0.0));
      });
    });

    group('Energy Conversions', () {
      test('kWh to MWh conversion', () {
        expect(UnitConversionService.kwhToMwh(1000.0), equals(1.0));
        expect(UnitConversionService.kwhToMwh(500.0), equals(0.5));
      });

      test('MWh to kWh conversion', () {
        expect(UnitConversionService.mwhToKwh(1.0), equals(1000.0));
        expect(UnitConversionService.mwhToKwh(0.5), equals(500.0));
      });

      test('kWh to BTU conversion', () {
        expect(UnitConversionService.kwhToBtu(1.0), closeTo(3412.14, 0.01));
      });

      test('BTU to kWh conversion', () {
        expect(UnitConversionService.btuToKwh(3412.14), closeTo(1.0, 0.01));
      });

      test('kWh to Joules conversion', () {
        expect(UnitConversionService.kwhToJoules(1.0), equals(3600000.0));
      });

      test('Joules to kWh conversion', () {
        expect(UnitConversionService.joulesToKwh(3600000.0), equals(1.0));
      });
    });

    group('Current Conversions', () {
      test('A to mA conversion', () {
        expect(UnitConversionService.aToMa(1.0), equals(1000.0));
        expect(UnitConversionService.aToMa(0.5), equals(500.0));
      });

      test('mA to A conversion', () {
        expect(UnitConversionService.maToA(1000.0), equals(1.0));
        expect(UnitConversionService.maToA(500.0), equals(0.5));
      });

      test('A to kA conversion', () {
        expect(UnitConversionService.aToKa(1000.0), equals(1.0));
        expect(UnitConversionService.aToKa(500.0), equals(0.5));
      });

      test('kA to A conversion', () {
        expect(UnitConversionService.kaToA(1.0), equals(1000.0));
        expect(UnitConversionService.kaToA(0.5), equals(500.0));
      });
    });

    group('Temperature Conversions', () {
      test('Celsius to Fahrenheit', () {
        expect(UnitConversionService.celsiusToFahrenheit(0.0), equals(32.0));
        expect(UnitConversionService.celsiusToFahrenheit(100.0), equals(212.0));
        expect(UnitConversionService.celsiusToFahrenheit(25.0), equals(77.0));
      });

      test('Fahrenheit to Celsius', () {
        expect(UnitConversionService.fahrenheitToCelsius(32.0), equals(0.0));
        expect(UnitConversionService.fahrenheitToCelsius(212.0), equals(100.0));
        expect(UnitConversionService.fahrenheitToCelsius(77.0), equals(25.0));
      });
    });

    group('Speed Conversions', () {
      test('RPM to rad/s conversion', () {
        expect(UnitConversionService.rpmToRadPerSec(60.0), closeTo(6.2832, 0.001));
        expect(UnitConversionService.rpmToRadPerSec(0.0), equals(0.0));
      });

      test('rad/s to RPM conversion', () {
        expect(UnitConversionService.radPerSecToRpm(6.2832), closeTo(60.0, 0.001));
        expect(UnitConversionService.radPerSecToRpm(0.0), equals(0.0));
      });
    });

    group('Length Conversions', () {
      test('Meter to Feet conversion', () {
        expect(UnitConversionService.meterToFeet(1.0), closeTo(3.2808, 0.001));
        expect(UnitConversionService.meterToFeet(0.0), equals(0.0));
      });

      test('Feet to Meter conversion', () {
        expect(UnitConversionService.feetToMeter(3.2808), closeTo(1.0, 0.001));
        expect(UnitConversionService.feetToMeter(0.0), equals(0.0));
      });

      test('mm to Inch conversion', () {
        expect(UnitConversionService.mmToInch(25.4), closeTo(1.0, 0.001));
        expect(UnitConversionService.mmToInch(0.0), equals(0.0));
      });

      test('Inch to mm conversion', () {
        expect(UnitConversionService.inchToMm(1.0), closeTo(25.4, 0.001));
        expect(UnitConversionService.inchToMm(0.0), equals(0.0));
      });
    });

    group('Mass Conversions', () {
      test('kg to lb conversion', () {
        expect(UnitConversionService.kgToLb(1.0), closeTo(2.2046, 0.001));
        expect(UnitConversionService.kgToLb(0.0), equals(0.0));
      });

      test('lb to kg conversion', () {
        expect(UnitConversionService.lbToKg(2.2046), closeTo(1.0, 0.001));
        expect(UnitConversionService.lbToKg(0.0), equals(0.0));
      });

      test('kg to oz conversion', () {
        expect(UnitConversionService.kgToOz(1.0), closeTo(35.274, 0.001));
      });

      test('oz to kg conversion', () {
        expect(UnitConversionService.ozToKg(35.274), closeTo(1.0, 0.001));
      });

      test('kg to ton conversion', () {
        expect(UnitConversionService.kgToTon(1000.0), equals(1.0));
      });

      test('ton to kg conversion', () {
        expect(UnitConversionService.tonToKg(1.0), equals(1000.0));
      });
    });

    group('Volume Conversions', () {
      test('liter to gallon conversion', () {
        expect(UnitConversionService.literToGallon(3.7854), closeTo(1.0, 0.001));
      });

      test('gallon to liter conversion', () {
        expect(UnitConversionService.gallonToLiter(1.0), closeTo(3.7854, 0.001));
      });

      test('liter to m³ conversion', () {
        expect(UnitConversionService.literToM3(1000.0), equals(1.0));
      });

      test('m³ to liter conversion', () {
        expect(UnitConversionService.m3ToLiter(1.0), equals(1000.0));
      });

      test('m³ to ft³ conversion', () {
        expect(UnitConversionService.m3ToFt3(0.0283168), closeTo(1.0, 0.001));
      });

      test('ft³ to m³ conversion', () {
        expect(UnitConversionService.ft3ToM3(1.0), closeTo(0.0283168, 0.001));
      });
    });

    group('Area Conversions', () {
      test('m² to ft² conversion', () {
        expect(UnitConversionService.m2ToFt2(1.0), closeTo(10.7639, 0.001));
      });

      test('ft² to m² conversion', () {
        expect(UnitConversionService.ft2ToM2(10.7639), closeTo(1.0, 0.001));
      });

      test('m² to cm² conversion', () {
        expect(UnitConversionService.m2ToCm2(1.0), equals(10000.0));
      });

      test('cm² to m² conversion', () {
        expect(UnitConversionService.cm2ToM2(10000.0), equals(1.0));
      });

      test('m² to acre conversion', () {
        expect(UnitConversionService.m2ToAcre(4046.86), closeTo(1.0, 0.001));
      });

      test('acre to m² conversion', () {
        expect(UnitConversionService.acreToM2(1.0), closeTo(4046.86, 0.001));
      });
    });

    group('Force Conversions', () {
      test('N to kN conversion', () {
        expect(UnitConversionService.nToKn(1000.0), equals(1.0));
      });

      test('kN to N conversion', () {
        expect(UnitConversionService.knToN(1.0), equals(1000.0));
      });

      test('N to kgf conversion', () {
        expect(UnitConversionService.nToKgf(9.8067), closeTo(1.0, 0.001));
      });

      test('kgf to N conversion', () {
        expect(UnitConversionService.kgfToN(1.0), closeTo(9.8067, 0.001));
      });

      test('N to lbf conversion', () {
        expect(UnitConversionService.nToLbf(4.4482), closeTo(1.0, 0.001));
      });

      test('lbf to N conversion', () {
        expect(UnitConversionService.lbfToN(1.0), closeTo(4.4482, 0.001));
      });
    });

    group('Resistance Conversions', () {
      test('Ω to kΩ conversion', () {
        expect(UnitConversionService.ohmToKohm(1000.0), equals(1.0));
      });

      test('kΩ to Ω conversion', () {
        expect(UnitConversionService.kohmToOhm(1.0), equals(1000.0));
      });

      test('Ω to MΩ conversion', () {
        expect(UnitConversionService.ohmToMohm(1000000.0), equals(1.0));
      });

      test('MΩ to Ω conversion', () {
        expect(UnitConversionService.mohmToOhm(1.0), equals(1000000.0));
      });

      test('Ω to mΩ conversion', () {
        expect(UnitConversionService.ohmToMilliohm(1.0), equals(1000.0));
      });

      test('mΩ to Ω conversion', () {
        expect(UnitConversionService.milliohmToOhm(1000.0), equals(1.0));
      });
    });

    group('Time Conversions', () {
      test('s to ms conversion', () {
        expect(UnitConversionService.secToMs(1.0), equals(1000.0));
      });

      test('ms to s conversion', () {
        expect(UnitConversionService.msToSec(1000.0), equals(1.0));
      });

      test('s to min conversion', () {
        expect(UnitConversionService.secToMin(60.0), equals(1.0));
      });

      test('min to s conversion', () {
        expect(UnitConversionService.minToSec(1.0), equals(60.0));
      });

      test('min to hr conversion', () {
        expect(UnitConversionService.minToHour(60.0), equals(1.0));
      });

      test('hr to min conversion', () {
        expect(UnitConversionService.hourToMin(1.0), equals(60.0));
      });

      test('hr to day conversion', () {
        expect(UnitConversionService.hourToDay(24.0), equals(1.0));
      });

      test('day to hr conversion', () {
        expect(UnitConversionService.dayToHour(1.0), equals(24.0));
      });
    });

    group('Angular Conversions', () {
      test('deg to rad conversion', () {
        expect(UnitConversionService.degToRad(180.0), closeTo(3.1416, 0.001));
        expect(UnitConversionService.degToRad(0.0), equals(0.0));
      });

      test('rad to deg conversion', () {
        expect(UnitConversionService.radToDeg(3.1416), closeTo(180.0, 0.001));
        expect(UnitConversionService.radToDeg(0.0), equals(0.0));
      });

      test('deg to grad conversion', () {
        expect(UnitConversionService.degToGrad(90.0), closeTo(100.0, 0.001));
      });

      test('grad to deg conversion', () {
        expect(UnitConversionService.gradToDeg(100.0), closeTo(90.0, 0.001));
      });
    });

    group('FLC and Affinity Laws', () {
      test('calculateFLC with valid inputs', () {
        final result = UnitConversionService.calculateFLC(5.5, 415.0, 0.9, 0.85, 3);
        expect(result, greaterThan(0));
        expect(result, closeTo(10.0, 0.1)); // Approximate expected value
      });

      test('calculateFLC with zero power', () {
        final result = UnitConversionService.calculateFLC(0.0, 415.0, 0.9, 0.85, 3);
        expect(result, equals(0.0));
      });

      test('calculateFLC with zero voltage', () {
        final result = UnitConversionService.calculateFLC(5.5, 0.0, 0.9, 0.85, 3);
        expect(result, equals(double.infinity));
      });

      test('affinityLaws with valid inputs', () {
        final result = UnitConversionService.affinityLaws(1000.0, 1200.0, 100.0, 5.5);
        expect(result['power2'], greaterThan(5.5));
        expect(result['flow2'], greaterThan(100.0));
        expect(result['pressure2'], greaterThan(100.0));
      });

      test('affinityLaws with same speeds', () {
        final result = UnitConversionService.affinityLaws(1000.0, 1000.0, 100.0, 5.5);
        expect(result['power2'], closeTo(5.5, 0.1));
        expect(result['flow2'], closeTo(100.0, 0.1));
        expect(result['pressure2'], closeTo(100.0, 0.1));
      });
    });
  });
}
