import 'dart:math' as math;

class UnitConversionService {
  // Power Conversions
  static double kwToHp(double kw) => kw * 1.34102;
  static double hpToKw(double hp) => hp / 1.34102;

  // Energy Conversions
  static double kwhToMwh(double kwh) => kwh / 1000;
  static double mwhToKwh(double mwh) => mwh * 1000;
  static double kwhToBtu(double kwh) => kwh * 3412.14;
  static double btuToKwh(double btu) => btu / 3412.14;
  static double kwhToJoules(double kwh) => kwh * 3600000;
  static double joulesToKwh(double joules) => joules / 3600000;

  // Apparent Power Conversions
  static double kvaToVa(double kva) => kva * 1000;
  static double vaToKva(double va) => va / 1000;
  static double kvaToMva(double kva) => kva / 1000;
  static double mvaToKva(double mva) => mva * 1000;

  // Reactive Power Conversions
  static double kvarToVar(double kvar) => kvar * 1000;
  static double varToKvar(double var_) => var_ / 1000;
  static double kvarToMvar(double kvar) => kvar / 1000;
  static double mvarToKvar(double mvar) => mvar * 1000;

  // Current Extended Conversions
  static double aToMa(double a) => a * 1000;
  static double maToA(double ma) => ma / 1000;
  static double aToKa(double a) => a / 1000;
  static double kaToA(double ka) => ka * 1000;

  // Cable Size Conversions
  static double mm2ToAwg(double mm2) {
    if (mm2 <= 0) return 0;
    return (4.31 - (10 * (math.log(mm2.clamp(0.05, 107)) / 2.302585)));
  }

  static double awgToMm2(double awg) =>
      0.012668 * math.pow(92.0, (36 - awg) / 19.5);
  static double mm2ToSwg(double mm2) {
    if (mm2 <= 0) return 0;
    return (36.0 - 19.5 * (math.log(mm2 / 0.012668) / math.log(92.0)));
  }

  // Motor Calculators
  static double calculateFLC(
      double kw, double voltage, double efficiency, double pf, int phases) {
    if (phases == 3) {
      return (kw * 1000) / (1.732 * voltage * efficiency * pf);
    }
    return (kw * 1000) / (voltage * efficiency * pf);
  }

  static double calculateMotorSlip(double syncSpeed, double actualSpeed) {
    return ((syncSpeed - actualSpeed) / syncSpeed) * 100;
  }

  static double calculateMotorEfficiency(double outputKw, double inputKw) {
    return (outputKw / inputKw) * 100;
  }

  static double calculateVfRatio(double voltage, double frequency) {
    return voltage / frequency;
  }

  // Affinity Laws Calculator (Pump/Fan)
  static Map<String, double> affinityLaws(
      double speed1, double speed2, double flow1, double power1) {
    final ratio = speed2 / speed1;
    return {
      'flow2': flow1 * ratio,
      'pressure2': flow1 * ratio * ratio,
      'power2': power1 * ratio * ratio * ratio,
    };
  }

  // Mass/Weight Conversions
  static double kgToLb(double kg) => kg * 2.20462;
  static double lbToKg(double lb) => lb / 2.20462;
  static double kgToOz(double kg) => kg * 35.274;
  static double ozToKg(double oz) => oz / 35.274;
  static double kgToTon(double kg) => kg / 1000;
  static double tonToKg(double ton) => ton * 1000;

  // Volume Conversions
  static double literToGallon(double liter) => liter * 0.264172;
  static double gallonToLiter(double gallon) => gallon / 0.264172;
  static double literToM3(double liter) => liter / 1000;
  static double m3ToLiter(double m3) => m3 * 1000;
  static double m3ToFt3(double m3) => m3 * 35.3147;
  static double ft3ToM3(double ft3) => ft3 / 35.3147;

  // Area Conversions
  static double m2ToFt2(double m2) => m2 * 10.7639;
  static double ft2ToM2(double ft2) => ft2 / 10.7639;
  static double m2ToCm2(double m2) => m2 * 10000;
  static double cm2ToM2(double cm2) => cm2 / 10000;
  static double m2ToAcre(double m2) => m2 / 4046.86;
  static double acreToM2(double acre) => acre * 4046.86;

  // Force Conversions
  static double nToKn(double n) => n / 1000;
  static double knToN(double kn) => kn * 1000;
  static double nToKgf(double n) => n / 9.80665;
  static double kgfToN(double kgf) => kgf * 9.80665;
  static double nToLbf(double n) => n / 4.44822;
  static double lbfToN(double lbf) => lbf * 4.44822;

  // Resistance Conversions
  static double ohmToKohm(double ohm) => ohm / 1000;
  static double kohmToOhm(double kohm) => kohm * 1000;
  static double ohmToMohm(double ohm) => ohm / 1000000;
  static double mohmToOhm(double mohm) => mohm * 1000000;
  static double ohmToMilliohm(double ohm) => ohm * 1000;
  static double milliohmToOhm(double milliohm) => milliohm / 1000;

  // Capacitance Conversions
  static double fToUf(double f) => f * 1000000;
  static double ufToF(double uf) => uf / 1000000;
  static double fToNf(double f) => f * 1000000000;
  static double nfToF(double nf) => nf / 1000000000;
  static double fToPf(double f) => f * 1000000000000;
  static double pfToF(double pf) => pf / 1000000000000;

  // Inductance Conversions
  static double hToMh(double h) => h * 1000;
  static double mhToH(double mh) => mh / 1000;
  static double hToUh(double h) => h * 1000000;
  static double uhToH(double uh) => uh / 1000000;

  // Time Conversions
  static double secToMs(double sec) => sec * 1000;
  static double msToSec(double ms) => ms / 1000;
  static double secToMin(double sec) => sec / 60;
  static double minToSec(double min) => min * 60;
  static double minToHour(double min) => min / 60;
  static double hourToMin(double hour) => hour * 60;
  static double hourToDay(double hour) => hour / 24;
  static double dayToHour(double day) => day * 24;

  // Angular Conversions
  static double degToRad(double deg) => deg * 0.0174533;
  static double radToDeg(double rad) => rad / 0.0174533;
  static double degToGrad(double deg) => deg * 1.11111;
  static double gradToDeg(double grad) => grad / 1.11111;

  // Voltage Conversions
  static double voltToKv(double volt) => volt / 1000;
  static double kvToVolt(double kv) => kv * 1000;

  // Speed Conversions
  static double rpmToRadPerSec(double rpm) => rpm * 0.10472;
  static double radPerSecToRpm(double radPerSec) => radPerSec / 0.10472;

  // Torque Conversions
  static double nmToLbFt(double nm) => nm * 0.737562;
  static double lbFtToNm(double lbFt) => lbFt / 0.737562;

  // Temperature Conversions
  static double celsiusToFahrenheit(double celsius) => (celsius * 9 / 5) + 32;
  static double fahrenheitToCelsius(double fahrenheit) =>
      (fahrenheit - 32) * 5 / 9;

  // Length Conversions
  static double meterToFeet(double meter) => meter * 3.28084;
  static double feetToMeter(double feet) => feet / 3.28084;
  static double mmToInch(double mm) => mm * 0.0393701;
  static double inchToMm(double inch) => inch / 0.0393701;

  // Pressure Conversions
  static double barToPsi(double bar) => bar * 14.5038;
  static double psiToBar(double psi) => psi / 14.5038;
  static double paToBar(double pa) => pa / 100000;
  static double barToPa(double bar) => bar * 100000;

  // Flow Rate Conversions
  static double m3hToGpm(double m3h) => m3h * 4.40287;
  static double gpmToM3h(double gpm) => gpm / 4.40287;
  static double lsToGpm(double ls) => ls * 15.8503;
  static double gpmToLs(double gpm) => gpm / 15.8503;

  // Frequency Conversions
  static double hzToRpm(double hz, int poles) => (hz * 120) / poles;
  static double rpmToHz(double rpm, int poles) => (rpm * poles) / 120;

  // Format with unit
  static String formatPower(double value, String unit) {
    return '${value.toStringAsFixed(2)} $unit';
  }

  static String formatEnergy(double value, String unit) {
    return '${value.toStringAsFixed(2)} $unit';
  }

  static String formatApparentPower(double value, String unit) {
    return '${value.toStringAsFixed(2)} $unit';
  }

  static String formatReactivePower(double value, String unit) {
    return '${value.toStringAsFixed(2)} $unit';
  }

  static String formatVoltage(double value) {
    return '${value.toStringAsFixed(0)} V';
  }

  static String formatCurrent(double value) {
    return '${value.toStringAsFixed(2)} A';
  }

  static String formatSpeed(double value) {
    return '${value.toStringAsFixed(0)} RPM';
  }

  static String formatFrequency(double value) {
    return '${value.toStringAsFixed(1)} Hz';
  }

  static String formatTemperature(double value, String unit) {
    return '${value.toStringAsFixed(1)} °$unit';
  }

  static String formatPressure(double value, String unit) {
    return '${value.toStringAsFixed(2)} $unit';
  }

  static String formatFlowRate(double value, String unit) {
    return '${value.toStringAsFixed(2)} $unit';
  }
}
