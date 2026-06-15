import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/unit_conversion_service.dart';
import '../../core/theme/app_form_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/calculation_result_box.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  int _selectedCategory = 0;
  final _inputCtrl = TextEditingController();
  String _fromUnit = '';
  String _toUnit = '';
  String _result = '';

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.flash_on, 'name': 'Power', 'color': AppTheme.primary},
    {'icon': Icons.battery_charging_full, 'name': 'Energy', 'color': AppTheme.primary},
    {'icon': Icons.electric_bolt, 'name': 'Current', 'color': AppTheme.primary},
    {'icon': Icons.thermostat, 'name': 'Temperature', 'color': AppTheme.primary},
    {'icon': Icons.speed, 'name': 'Speed', 'color': AppTheme.primary},
    {'icon': Icons.straighten, 'name': 'Length', 'color': AppTheme.primary},
    {'icon': Icons.scale, 'name': 'Mass', 'color': AppTheme.primary},
    {'icon': Icons.water_drop, 'name': 'Volume', 'color': AppTheme.primary},
    {'icon': Icons.crop_square, 'name': 'Area', 'color': AppTheme.primary},
    {'icon': Icons.fitness_center, 'name': 'Force', 'color': AppTheme.primary},
    {'icon': Icons.electrical_services, 'name': 'Resistance', 'color': AppTheme.primary},
    {'icon': Icons.timer, 'name': 'Time', 'color': AppTheme.primary},
    {'icon': Icons.rotate_right, 'name': 'Angular', 'color': AppTheme.primary},
  ];

  final Map<String, List<String>> _units = {
    'Power': ['kW', 'HP'],
    'Energy': ['kWh', 'MWh', 'BTU', 'Joules'],
    'Current': ['A', 'mA', 'kA'],
    'Temperature': ['°C', '°F'],
    'Speed': ['RPM', 'rad/s'],
    'Length': ['m', 'ft', 'mm', 'inch'],
    'Mass': ['kg', 'lb', 'oz', 'ton'],
    'Volume': ['L', 'gal', 'm³', 'ft³'],
    'Area': ['m²', 'ft²', 'cm²', 'acre'],
    'Force': ['N', 'kN', 'kgf', 'lbf'],
    'Resistance': ['Ω', 'kΩ', 'MΩ', 'mΩ'],
    'Time': ['s', 'ms', 'min', 'hr', 'day'],
    'Angular': ['deg', 'rad', 'grad'],
  };

  @override
  void initState() {
    super.initState();
    _updateUnits();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  void _updateUnits() {
    final category = _categories[_selectedCategory]['name'] as String;
    final units = _units[category]!;
    _fromUnit = units[0];
    _toUnit = units.length > 1 ? units[1] : units[0];
    _convert();
  }

  void _convert() {
    final value = double.tryParse(_inputCtrl.text) ?? 0;
    if (value == 0) {
      setState(() => _result = '');
      return;
    }

    if (_fromUnit == _toUnit) {
      setState(() => _result = value.toStringAsFixed(4));
      return;
    }

    double converted = value;
    final category = _categories[_selectedCategory]['name'] as String;

    switch (category) {
      case 'Power':
        if (_fromUnit == 'kW' && _toUnit == 'HP') {
          converted = UnitConversionService.kwToHp(value);
        } else if (_fromUnit == 'HP' && _toUnit == 'kW') {
          converted = UnitConversionService.hpToKw(value);
        }
        break;
      case 'Energy':
        if (_fromUnit == 'kWh' && _toUnit == 'MWh') {
          converted = UnitConversionService.kwhToMwh(value);
        } else if (_fromUnit == 'MWh' && _toUnit == 'kWh') {
          converted = UnitConversionService.mwhToKwh(value);
        } else if (_fromUnit == 'kWh' && _toUnit == 'BTU') {
          converted = UnitConversionService.kwhToBtu(value);
        } else if (_fromUnit == 'BTU' && _toUnit == 'kWh') {
          converted = UnitConversionService.btuToKwh(value);
        } else if (_fromUnit == 'kWh' && _toUnit == 'Joules') {
          converted = UnitConversionService.kwhToJoules(value);
        } else if (_fromUnit == 'Joules' && _toUnit == 'kWh') {
          converted = UnitConversionService.joulesToKwh(value);
        }
        break;
      case 'Current':
        if (_fromUnit == 'A' && _toUnit == 'mA') {
          converted = UnitConversionService.aToMa(value);
        } else if (_fromUnit == 'mA' && _toUnit == 'A') {
          converted = UnitConversionService.maToA(value);
        } else if (_fromUnit == 'A' && _toUnit == 'kA') {
          converted = UnitConversionService.aToKa(value);
        } else if (_fromUnit == 'kA' && _toUnit == 'A') {
          converted = UnitConversionService.kaToA(value);
        }
        break;
      case 'Temperature':
        if (_fromUnit == '°C' && _toUnit == '°F') {
          converted = UnitConversionService.celsiusToFahrenheit(value);
        } else if (_fromUnit == '°F' && _toUnit == '°C') {
          converted = UnitConversionService.fahrenheitToCelsius(value);
        }
        break;
      case 'Speed':
        if (_fromUnit == 'RPM' && _toUnit == 'rad/s') {
          converted = UnitConversionService.rpmToRadPerSec(value);
        } else if (_fromUnit == 'rad/s' && _toUnit == 'RPM') {
          converted = UnitConversionService.radPerSecToRpm(value);
        }
        break;
      case 'Length':
        if (_fromUnit == 'm' && _toUnit == 'ft') {
          converted = UnitConversionService.meterToFeet(value);
        } else if (_fromUnit == 'ft' && _toUnit == 'm') {
          converted = UnitConversionService.feetToMeter(value);
        } else if (_fromUnit == 'mm' && _toUnit == 'inch') {
          converted = UnitConversionService.mmToInch(value);
        } else if (_fromUnit == 'inch' && _toUnit == 'mm') {
          converted = UnitConversionService.inchToMm(value);
        }
        break;
      case 'Mass':
        if (_fromUnit == 'kg' && _toUnit == 'lb') {
          converted = UnitConversionService.kgToLb(value);
        } else if (_fromUnit == 'lb' && _toUnit == 'kg') {
          converted = UnitConversionService.lbToKg(value);
        } else if (_fromUnit == 'kg' && _toUnit == 'oz') {
          converted = UnitConversionService.kgToOz(value);
        } else if (_fromUnit == 'oz' && _toUnit == 'kg') {
          converted = UnitConversionService.ozToKg(value);
        } else if (_fromUnit == 'kg' && _toUnit == 'ton') {
          converted = UnitConversionService.kgToTon(value);
        } else if (_fromUnit == 'ton' && _toUnit == 'kg') {
          converted = UnitConversionService.tonToKg(value);
        }
        break;
      case 'Volume':
        if (_fromUnit == 'L' && _toUnit == 'gal') {
          converted = UnitConversionService.literToGallon(value);
        } else if (_fromUnit == 'gal' && _toUnit == 'L') {
          converted = UnitConversionService.gallonToLiter(value);
        } else if (_fromUnit == 'L' && _toUnit == 'm³') {
          converted = UnitConversionService.literToM3(value);
        } else if (_fromUnit == 'm³' && _toUnit == 'L') {
          converted = UnitConversionService.m3ToLiter(value);
        } else if (_fromUnit == 'm³' && _toUnit == 'ft³') {
          converted = UnitConversionService.m3ToFt3(value);
        } else if (_fromUnit == 'ft³' && _toUnit == 'm³') {
          converted = UnitConversionService.ft3ToM3(value);
        }
        break;
      case 'Area':
        if (_fromUnit == 'm²' && _toUnit == 'ft²') {
          converted = UnitConversionService.m2ToFt2(value);
        } else if (_fromUnit == 'ft²' && _toUnit == 'm²') {
          converted = UnitConversionService.ft2ToM2(value);
        } else if (_fromUnit == 'm²' && _toUnit == 'cm²') {
          converted = UnitConversionService.m2ToCm2(value);
        } else if (_fromUnit == 'cm²' && _toUnit == 'm²') {
          converted = UnitConversionService.cm2ToM2(value);
        } else if (_fromUnit == 'm²' && _toUnit == 'acre') {
          converted = UnitConversionService.m2ToAcre(value);
        } else if (_fromUnit == 'acre' && _toUnit == 'm²') {
          converted = UnitConversionService.acreToM2(value);
        }
        break;
      case 'Force':
        if (_fromUnit == 'N' && _toUnit == 'kN') {
          converted = UnitConversionService.nToKn(value);
        } else if (_fromUnit == 'kN' && _toUnit == 'N') {
          converted = UnitConversionService.knToN(value);
        } else if (_fromUnit == 'N' && _toUnit == 'kgf') {
          converted = UnitConversionService.nToKgf(value);
        } else if (_fromUnit == 'kgf' && _toUnit == 'N') {
          converted = UnitConversionService.kgfToN(value);
        } else if (_fromUnit == 'N' && _toUnit == 'lbf') {
          converted = UnitConversionService.nToLbf(value);
        } else if (_fromUnit == 'lbf' && _toUnit == 'N') {
          converted = UnitConversionService.lbfToN(value);
        }
        break;
      case 'Resistance':
        if (_fromUnit == 'Ω' && _toUnit == 'kΩ') {
          converted = UnitConversionService.ohmToKohm(value);
        } else if (_fromUnit == 'kΩ' && _toUnit == 'Ω') {
          converted = UnitConversionService.kohmToOhm(value);
        } else if (_fromUnit == 'Ω' && _toUnit == 'MΩ') {
          converted = UnitConversionService.ohmToMohm(value);
        } else if (_fromUnit == 'MΩ' && _toUnit == 'Ω') {
          converted = UnitConversionService.mohmToOhm(value);
        } else if (_fromUnit == 'Ω' && _toUnit == 'mΩ') {
          converted = UnitConversionService.ohmToMilliohm(value);
        } else if (_fromUnit == 'mΩ' && _toUnit == 'Ω') {
          converted = UnitConversionService.milliohmToOhm(value);
        }
        break;
      case 'Time':
        if (_fromUnit == 's' && _toUnit == 'ms') {
          converted = UnitConversionService.secToMs(value);
        } else if (_fromUnit == 'ms' && _toUnit == 's') {
          converted = UnitConversionService.msToSec(value);
        } else if (_fromUnit == 's' && _toUnit == 'min') {
          converted = UnitConversionService.secToMin(value);
        } else if (_fromUnit == 'min' && _toUnit == 's') {
          converted = UnitConversionService.minToSec(value);
        } else if (_fromUnit == 'min' && _toUnit == 'hr') {
          converted = UnitConversionService.minToHour(value);
        } else if (_fromUnit == 'hr' && _toUnit == 'min') {
          converted = UnitConversionService.hourToMin(value);
        } else if (_fromUnit == 'hr' && _toUnit == 'day') {
          converted = UnitConversionService.hourToDay(value);
        } else if (_fromUnit == 'day' && _toUnit == 'hr') {
          converted = UnitConversionService.dayToHour(value);
        }
        break;
      case 'Angular':
        if (_fromUnit == 'deg' && _toUnit == 'rad') {
          converted = UnitConversionService.degToRad(value);
        } else if (_fromUnit == 'rad' && _toUnit == 'deg') {
          converted = UnitConversionService.radToDeg(value);
        } else if (_fromUnit == 'deg' && _toUnit == 'grad') {
          converted = UnitConversionService.degToGrad(value);
        } else if (_fromUnit == 'grad' && _toUnit == 'deg') {
          converted = UnitConversionService.gradToDeg(value);
        }
        break;
    }

    setState(() => _result = converted.toStringAsFixed(4));
  }

  List<String> get _currentUnits =>
      _units[_categories[_selectedCategory]['name'] as String]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unit Converter')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 700;
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 132,
                  child: _buildCategoryRail(Axis.vertical),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildConverterCard(),
                  ),
                ),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 96, child: _buildCategoryRail(Axis.horizontal)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildConverterCard(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryRail(Axis axis) {
    final isVertical = axis == Axis.vertical;

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListView.separated(
        scrollDirection: axis,
        padding: EdgeInsets.symmetric(
          horizontal: isVertical ? 0 : 8,
          vertical: isVertical ? 8 : 0,
        ),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => SizedBox(
          width: isVertical ? 0 : 4,
          height: isVertical ? 4 : 0,
        ),
        itemBuilder: (ctx, i) => _buildCategoryButton(i, compact: !isVertical),
      ),
    );
  }

  Widget _buildConverterCard() {
    final category = _categories[_selectedCategory];
    final color = category['color'] as Color;
    final name = category['name'] as String;

    return AppCard(
      title: name,
      subtitle: 'Convert $_fromUnit to $_toUnit',
      accentColor: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _inputCtrl,
            decoration: AppFormStyles.decoration(
              context,
              labelText: 'Enter value ($_fromUnit)',
            ),
            style: AppFormStyles.fieldText(context),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _convert(),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _fromUnit,
            decoration: AppFormStyles.decoration(context, labelText: 'From unit'),
            items: _currentUnits
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _fromUnit = v;
                _convert();
              });
            },
          ),
          const SizedBox(height: 16),
          const Icon(Icons.arrow_downward, size: 32),
          const SizedBox(height: 16),
          CalculationResultBox(
            text: _result.isEmpty ? '0' : '$_result $_toUnit',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            accentColor: color,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _toUnit,
            decoration: AppFormStyles.decoration(context, labelText: 'To unit'),
            items: _currentUnits
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _toUnit = v;
                _convert();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(int index, {required bool compact}) {
    final cat = _categories[index];
    final color = cat['color'] as Color;
    final selected = _selectedCategory == index;

    return InkWell(
      onTap: () => setState(() {
        _selectedCategory = index;
        _updateUnits();
      }),
      child: Container(
        width: compact ? 72 : null,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : null,
          border: Border(
            left: BorderSide(
              color: selected && !compact ? color : Colors.transparent,
              width: 4,
            ),
            bottom: BorderSide(
              color: selected && compact ? color : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(cat['icon'] as IconData, color: color, size: compact ? 22 : 28),
            const SizedBox(height: 4),
            Text(
              cat['name'] as String,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: compact ? 9 : 10),
            ),
          ],
        ),
      ),
    );
  }
}
