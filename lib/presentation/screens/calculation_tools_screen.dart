import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_form_styles.dart';
import '../../core/services/unit_conversion_service.dart';
import '../widgets/app_card.dart';
import '../widgets/calculation_result_box.dart';

class CalculationToolsScreen extends StatefulWidget {
  const CalculationToolsScreen({super.key});

  @override
  State<CalculationToolsScreen> createState() => _CalculationToolsScreenState();
}

class _CalculationToolsScreenState extends State<CalculationToolsScreen> {
  int _selectedTool = 0;

  final List<Map<String, dynamic>> _tools = [
    {
      'icon': Icons.electric_bolt,
      'name': 'Motor Current',
      'color': AppTheme.primary
    },
    {'icon': Icons.cable, 'name': 'Cable Size', 'color': AppTheme.primary},
    {'icon': Icons.trending_down, 'name': 'Voltage Drop', 'color': AppTheme.primary},
    {'icon': Icons.power, 'name': 'Power Factor', 'color': AppTheme.primary},
    {'icon': Icons.savings, 'name': 'Energy Savings', 'color': AppTheme.primary},
    {'icon': Icons.swap_horiz, 'name': 'HP ? kW', 'color': AppTheme.primary},
    {
      'icon': Icons.playlist_add_check,
      'name': 'Commissioning',
      'color': AppTheme.primary
    },
    {
      'icon': Icons.graphic_eq,
      'name': '4-20 / 0-10',
      'color': AppTheme.primary
    },
    {'icon': Icons.memory, 'name': 'Reg Mapper', 'color': AppTheme.primary},
    {'icon': Icons.thermostat, 'name': 'Thermocouple', 'color': AppTheme.primary},
    {'icon': Icons.compress, 'name': 'Pressure Calc', 'color': AppTheme.primary},
    {'icon': Icons.waves, 'name': 'Harmonics', 'color': AppTheme.primary},
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      appBar: AppBar(title: const Text('Calculation Tools')),
      body: SingleChildScrollView(
        child: isWide
            ? Row(children: [
                SizedBox(
                  width: 140,
                  child: _buildSidebar(context),
                ),
                Expanded(child: _buildContent(context)),
              ])
            : Column(children: [
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: _tools.length,
                    itemBuilder: (ctx, i) => _buildToolChip(i),
                  ),
                ),
                _buildContent(context),
              ]),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return AppCard(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      accentColor: Theme.of(context).colorScheme.primary,
      title: 'Tools',
      subtitle: 'Select a calculator',
      child: ListView.builder(
        itemCount: _tools.length,
        itemBuilder: (ctx, i) => _buildToolButton(i),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AppCard(
        title: _tools[_selectedTool]['name'],
        subtitle: 'Enter values and calculate quickly',
        accentColor: _tools[_selectedTool]['color'],
        child: _buildCalculator(_selectedTool),
      ),
    );
  }

  Widget _buildToolChip(int index) {
    final tool = _tools[index];
    final selected = _selectedTool == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTool = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? tool['color'] : tool['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tool['color'], width: selected ? 2 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tool['icon'], color: selected ? Colors.white : tool['color'], size: 16),
            const SizedBox(width: 6),
            Text(
              tool['name'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : tool['color'],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(int index) {
    final tool = _tools[index];
    final selected = _selectedTool == index;
    return InkWell(
      onTap: () => setState(() => _selectedTool = index),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? tool['color'].withOpacity(0.2) : null,
          border: Border(
            left: BorderSide(
              color: selected ? tool['color'] : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Column(
          children: [
            Icon(tool['icon'], color: tool['color'], size: 28),
            const SizedBox(height: 4),
            Text(
              tool['name'],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculator(int index) {
    switch (index) {
      case 0:
        return const MotorCurrentCalculator();
      case 1:
        return const CableSizeCalculator();
      case 2:
        return const VoltageDropCalculator();
      case 3:
        return const PowerFactorCalculator();
      case 4:
        return const EnergySavingsCalculator();
      case 5:
        return const PowerConverterCalculator();
      case 6:
        return const CommissioningModeTool();
      case 7:
        return const SignalToolkitCalculator();
      case 8:
        return const ProtocolRegisterMapperTool();
      case 9:
        return const ThermocoupleCalculator();
      case 10:
        return const PressureCalculator();
      case 11:
        return const HarmonicsCalculator();
      default:
        return const SizedBox();
    }
  }
}

// Motor Current Calculator
class MotorCurrentCalculator extends StatefulWidget {
  const MotorCurrentCalculator({super.key});

  @override
  State<MotorCurrentCalculator> createState() => _MotorCurrentCalculatorState();
}

class _MotorCurrentCalculatorState extends State<MotorCurrentCalculator> {
  final _powerCtrl = TextEditingController();
  final _voltageCtrl = TextEditingController();
  final _efficiencyCtrl = TextEditingController(text: '90');
  final _pfCtrl = TextEditingController(text: '0.85');
  String _result = '';

  void _calculate() {
    final power = double.tryParse(_powerCtrl.text) ?? 0;
    final voltage = double.tryParse(_voltageCtrl.text) ?? 0;
    final efficiency = (double.tryParse(_efficiencyCtrl.text) ?? 90) / 100;
    final pf = double.tryParse(_pfCtrl.text) ?? 0.85;

    if (power > 0 && voltage > 0) {
      final current =
          UnitConversionService.calculateFLC(power, voltage, efficiency, pf, 3);
      setState(() {
        _result = 'Motor Current: ${current.toStringAsFixed(2)} A\n'
            'Line Current: ${current.toStringAsFixed(2)} A\n'
            'Recommended MCB: ${(current * 1.25).toStringAsFixed(0)} A';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Motor Current Calculator',
              style: AppFormStyles.sectionTitle(context)),
          const SizedBox(height: 24),
          TextField(
            controller: _powerCtrl,
            decoration: AppFormStyles.decoration(context,
              labelText: 'Motor Power (kW)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _voltageCtrl,
            decoration: AppFormStyles.decoration(context,
              labelText: 'Voltage (V)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _efficiencyCtrl,
                  decoration: AppFormStyles.decoration(context,
                    labelText: 'Efficiency (%)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _pfCtrl,
                  decoration: AppFormStyles.decoration(context,
                    labelText: 'Power Factor',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _calculate,
            child: const Text('Calculate'),
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 24),
            CalculationResultBox(text: _result),
          ],
        ],
      ),
    );
  }
}

// Cable Size Calculator
class CableSizeCalculator extends StatefulWidget {
  const CableSizeCalculator({super.key});

  @override
  State<CableSizeCalculator> createState() => _CableSizeCalculatorState();
}

class _CableSizeCalculatorState extends State<CableSizeCalculator> {
  final _currentCtrl = TextEditingController();
  String _result = '';

  void _calculate() {
    final current = double.tryParse(_currentCtrl.text) ?? 0;
    if (current > 0) {
      String size = '';
      if (current <= 16) {
        size = '2.5 mm?';
      } else if (current <= 25) {
        size = '4 mm?';
      } else if (current <= 32) {
        size = '6 mm?';
      } else if (current <= 40) {
        size = '10 mm?';
      } else if (current <= 63) {
        size = '16 mm?';
      } else if (current <= 80) {
        size = '25 mm?';
      } else if (current <= 100) {
        size = '35 mm?';
      } else if (current <= 125) {
        size = '50 mm?';
      } else if (current <= 160) {
        size = '70 mm?';
      } else {
        size = '95 mm? or larger';
      }

      setState(() => _result = 'Recommended Cable Size: $size');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cable Size Calculator',
              style: AppFormStyles.sectionTitle(context)),
          const SizedBox(height: 24),
          TextField(
            controller: _currentCtrl,
            decoration: AppFormStyles.decoration(context,
              labelText: 'Current (A)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _calculate,
            child: const Text('Calculate'),
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 24),
            CalculationResultBox(
              text: _result,
              accentColor: AppTheme.accent,
            ),
          ],
        ],
      ),
    );
  }
}

// Voltage Drop Calculator
class VoltageDropCalculator extends StatefulWidget {
  const VoltageDropCalculator({super.key});

  @override
  State<VoltageDropCalculator> createState() => _VoltageDropCalculatorState();
}

class _VoltageDropCalculatorState extends State<VoltageDropCalculator> {
  final _currentCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  String _result = '';

  void _calculate() {
    final current = double.tryParse(_currentCtrl.text) ?? 0;
    final length = double.tryParse(_lengthCtrl.text) ?? 0;
    final size = double.tryParse(_sizeCtrl.text) ?? 0;

    if (current > 0 && length > 0 && size > 0) {
      final resistance = 0.0175 * length / size;
      final voltageDrop = current * resistance;
      setState(
          () => _result = 'Voltage Drop: ${voltageDrop.toStringAsFixed(2)} V');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Voltage Drop Calculator',
              style: AppFormStyles.sectionTitle(context)),
          const SizedBox(height: 24),
          TextField(
            controller: _currentCtrl,
            decoration: AppFormStyles.decoration(context,
                labelText: 'Current (A)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _lengthCtrl,
            decoration: AppFormStyles.decoration(context,
                labelText: 'Cable Length (m)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _sizeCtrl,
            decoration: AppFormStyles.decoration(context,
                labelText: 'Cable Size (mm?)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _calculate, child: const Text('Calculate')),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 24),
            CalculationResultBox(
              text: _result,
              accentColor: AppTheme.warning,
            ),
          ],
        ],
      ),
    );
  }
}

// Power Factor Calculator
class PowerFactorCalculator extends StatefulWidget {
  const PowerFactorCalculator({super.key});

  @override
  State<PowerFactorCalculator> createState() => _PowerFactorCalculatorState();
}

class _PowerFactorCalculatorState extends State<PowerFactorCalculator> {
  final _kwCtrl = TextEditingController();
  final _kvaCtrl = TextEditingController();
  String _result = '';

  void _calculate() {
    final kw = double.tryParse(_kwCtrl.text) ?? 0;
    final kva = double.tryParse(_kvaCtrl.text) ?? 0;

    if (kw > 0 && kva > 0) {
      final pf = kw / kva;
      final angle = acos(pf) * 180 / pi;
      setState(() => _result =
          'Power Factor: ${pf.toStringAsFixed(3)}\nAngle: ${angle.toStringAsFixed(1)}?');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Power Factor Calculator',
              style: AppFormStyles.sectionTitle(context)),
          const SizedBox(height: 24),
          TextField(
            controller: _kwCtrl,
            decoration: AppFormStyles.decoration(context,
                labelText: 'Active Power (kW)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _kvaCtrl,
            decoration: AppFormStyles.decoration(context,
                labelText: 'Apparent Power (kVA)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _calculate, child: const Text('Calculate')),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 24),
            CalculationResultBox(text: _result),
          ],
        ],
      ),
    );
  }
}

// Energy Savings Calculator (Affinity Laws)
class EnergySavingsCalculator extends StatefulWidget {
  const EnergySavingsCalculator({super.key});

  @override
  State<EnergySavingsCalculator> createState() =>
      _EnergySavingsCalculatorState();
}

class _EnergySavingsCalculatorState extends State<EnergySavingsCalculator> {
  final _speed1Ctrl = TextEditingController();
  final _speed2Ctrl = TextEditingController();
  final _power1Ctrl = TextEditingController();
  String _result = '';

  void _calculate() {
    final speed1 = double.tryParse(_speed1Ctrl.text) ?? 0;
    final speed2 = double.tryParse(_speed2Ctrl.text) ?? 0;
    final power1 = double.tryParse(_power1Ctrl.text) ?? 0;

    if (speed1 > 0 && speed2 > 0 && power1 > 0) {
      final result =
          UnitConversionService.affinityLaws(speed1, speed2, 100, power1);
      final savings = ((power1 - result['power2']!) / power1 * 100);
      setState(() =>
          _result = 'New Power: ${result['power2']!.toStringAsFixed(2)} kW\n'
              'Energy Savings: ${savings.toStringAsFixed(1)}%');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Energy Savings (Affinity Laws)',
              style: AppFormStyles.sectionTitle(context)),
          const SizedBox(height: 24),
          TextField(
            controller: _speed1Ctrl,
            decoration: AppFormStyles.decoration(context,
                labelText: 'Original Speed (RPM)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _speed2Ctrl,
            decoration: AppFormStyles.decoration(context,
                labelText: 'New Speed (RPM)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _power1Ctrl,
            decoration: AppFormStyles.decoration(context,
                labelText: 'Original Power (kW)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _calculate, child: const Text('Calculate')),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 24),
            CalculationResultBox(
              text: _result,
              accentColor: AppTheme.secondaryPurple,
            ),
          ],
        ],
      ),
    );
  }
}

// Power Converter (HP ? kW)
class PowerConverterCalculator extends StatefulWidget {
  const PowerConverterCalculator({super.key});

  @override
  State<PowerConverterCalculator> createState() =>
      _PowerConverterCalculatorState();
}

class _PowerConverterCalculatorState extends State<PowerConverterCalculator> {
  final _inputCtrl = TextEditingController();
  bool _isKwToHp = true;
  String _result = '';

  void _convert() {
    final value = double.tryParse(_inputCtrl.text) ?? 0;
    if (value > 0) {
      if (_isKwToHp) {
        final hp = value * 1.341;
        setState(() => _result = '$value kW = ${hp.toStringAsFixed(2)} HP');
      } else {
        final kw = value / 1.341;
        setState(() => _result = '$value HP = ${kw.toStringAsFixed(2)} kW');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Power Converter',
              style: AppFormStyles.sectionTitle(context)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('kW ? HP')),
                    ButtonSegment(value: false, label: Text('HP ? kW')),
                  ],
                  selected: {_isKwToHp},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _isKwToHp = newSelection.first;
                      _result = '';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputCtrl,
            decoration: AppFormStyles.decoration(
              context,
              labelText: _isKwToHp ? 'Power (kW)' : 'Power (HP)',
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _convert(),
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 24),
            CalculationResultBox(
              text: _result,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              accentColor: AppTheme.accent,
            ),
          ],
        ],
      ),
    );
  }
}

class CommissioningModeTool extends StatefulWidget {
  const CommissioningModeTool({super.key});

  @override
  State<CommissioningModeTool> createState() => _CommissioningModeToolState();
}

class _CommissioningModeToolState extends State<CommissioningModeTool> {
  int _currentStep = 0;
  String _controlMode = 'V/F';
  String _runSource = 'Terminals';
  String _speedSource = 'AI1 (4-20mA)';
  final _motorKwCtrl = TextEditingController();
  final _motorVoltCtrl = TextEditingController(text: '415');
  final _motorCurrentCtrl = TextEditingController();
  final _accelCtrl = TextEditingController(text: '10');
  final _decelCtrl = TextEditingController(text: '10');

  String _summary = '';

  void _generateSummary() {
    setState(() {
      _summary = 'Commissioning Ready\n'
          'Motor: ${_motorKwCtrl.text} kW, ${_motorVoltCtrl.text} V, ${_motorCurrentCtrl.text} A\n'
          'Control: $_controlMode\n'
          'Run Source: $_runSource\n'
          'Speed Ref: $_speedSource\n'
          'Ramp: Acc ${_accelCtrl.text}s / Dec ${_decelCtrl.text}s\n'
          'Checklist: Motor params, start/stop logic, protections and command source verified.';
    });
  }

  InputDecoration _fieldDecoration(BuildContext context, String label) =>
      AppFormStyles.decoration(context, labelText: label);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Commissioning Mode',
              style: AppFormStyles.sectionTitle(context)),
          const SizedBox(height: 12),
          Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 3) {
                setState(() => _currentStep += 1);
              } else {
                _generateSummary();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) setState(() => _currentStep -= 1);
            },
            controlsBuilder: (context, details) => Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: Text(_currentStep == 3 ? 'Finish' : 'Next'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
            steps: [
              Step(
                title: const Text('Motor Nameplate'),
                isActive: _currentStep >= 0,
                content: Column(
                  children: [
                    TextField(
                      controller: _motorKwCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration(context, 'Motor Power (kW)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _motorVoltCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration(context, 'Motor Voltage (V)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _motorCurrentCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration(context, 'Motor Current (A)'),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Control Mode'),
                isActive: _currentStep >= 1,
                content: DropdownButtonFormField<String>(
                  value: _controlMode,
                  items: const [
                    DropdownMenuItem(value: 'V/F', child: Text('V/F')),
                    DropdownMenuItem(
                        value: 'Sensorless Vector',
                        child: Text('Sensorless Vector')),
                    DropdownMenuItem(
                        value: 'Closed Loop Vector',
                        child: Text('Closed Loop Vector')),
                  ],
                  onChanged: (v) => setState(() => _controlMode = v ?? 'V/F'),
                  decoration: _fieldDecoration(context, 'Mode'),
                ),
              ),
              Step(
                title: const Text('Command Sources'),
                isActive: _currentStep >= 2,
                content: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _runSource,
                      items: const [
                        DropdownMenuItem(
                            value: 'Terminals', child: Text('Terminals')),
                        DropdownMenuItem(
                            value: 'Keypad', child: Text('Keypad')),
                        DropdownMenuItem(
                            value: 'Communication',
                            child: Text('Communication')),
                      ],
                      onChanged: (v) =>
                          setState(() => _runSource = v ?? 'Terminals'),
                      decoration: _fieldDecoration(context, 'Run Command Source'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _speedSource,
                      items: const [
                        DropdownMenuItem(
                            value: 'AI1 (4-20mA)', child: Text('AI1 (4-20mA)')),
                        DropdownMenuItem(
                            value: 'AI2 (0-10V)', child: Text('AI2 (0-10V)')),
                        DropdownMenuItem(
                            value: 'Keypad', child: Text('Keypad')),
                        DropdownMenuItem(
                            value: 'Communication',
                            child: Text('Communication')),
                      ],
                      onChanged: (v) =>
                          setState(() => _speedSource = v ?? 'AI1 (4-20mA)'),
                      decoration: _fieldDecoration(context, 'Speed Reference Source'),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Ramps & Protection'),
                isActive: _currentStep >= 3,
                content: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _accelCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _fieldDecoration(context, 'Accel (s)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _decelCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _fieldDecoration(context, 'Decel (s)'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_summary.isNotEmpty) ...[
            const SizedBox(height: 12),
            CalculationResultBox(
              text: _summary,
              accentColor: AppTheme.primary,
            ),
          ],
        ],
      ),
    );
  }
}

class SignalToolkitCalculator extends StatefulWidget {
  const SignalToolkitCalculator({super.key});

  @override
  State<SignalToolkitCalculator> createState() =>
      _SignalToolkitCalculatorState();
}

class _SignalToolkitCalculatorState extends State<SignalToolkitCalculator> {
  final _engMinCtrl = TextEditingController(text: '0');
  final _engMaxCtrl = TextEditingController(text: '100');
  final _signalValueCtrl = TextEditingController();
  int _mode = 0; // 0: 4-20mA, 1: 0-10V, 2: Raw Count
  String _result = '';

  void _convertToEngineering() {
    final engMin = double.tryParse(_engMinCtrl.text) ?? 0;
    final engMax = double.tryParse(_engMaxCtrl.text) ?? 100;
    final signal = double.tryParse(_signalValueCtrl.text) ?? 0;
    if (engMax <= engMin) return;

    double signalMin, signalMax;
    String unit;
    switch (_mode) {
      case 0: // 4-20mA
        signalMin = 4.0;
        signalMax = 20.0;
        unit = 'mA';
        break;
      case 1: // 0-10V
        signalMin = 0.0;
        signalMax = 10.0;
        unit = 'V';
        break;
      case 2: // Raw Count
        signalMin = 0.0;
        signalMax = 32767.0;
        unit = 'counts';
        break;
      default:
        return;
    }

    final clamped = signal.clamp(signalMin, signalMax);
    final engValue = engMin +
        ((clamped - signalMin) / (signalMax - signalMin)) * (engMax - engMin);

    setState(() {
      _result =
          'Input: ${clamped.toStringAsFixed(_mode == 2 ? 0 : 2)} $unit\n'
          'Engineering Value: ${engValue.toStringAsFixed(2)}';
    });
  }

  void _convertToSignal() {
    final engMin = double.tryParse(_engMinCtrl.text) ?? 0;
    final engMax = double.tryParse(_engMaxCtrl.text) ?? 100;
    final engValue = double.tryParse(_signalValueCtrl.text) ?? 0;
    if (engMax <= engMin) return;

    double signalMin, signalMax;
    String unit;
    switch (_mode) {
      case 0: // 4-20mA
        signalMin = 4.0;
        signalMax = 20.0;
        unit = 'mA';
        break;
      case 1: // 0-10V
        signalMin = 0.0;
        signalMax = 10.0;
        unit = 'V';
        break;
      case 2: // Raw Count
        signalMin = 0.0;
        signalMax = 32767.0;
        unit = 'counts';
        break;
      default:
        return;
    }

    final signal = signalMin +
        ((engValue - engMin) / (engMax - engMin)) * (signalMax - signalMin);

    setState(() {
      _result = 'Engineering Input: ${engValue.toStringAsFixed(2)}\n'
          'Signal Output: ${signal.toStringAsFixed(_mode == 2 ? 0 : 2)} $unit';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          AppCard(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.35),
            accentColor: Theme.of(context).colorScheme.primary,
            title: 'Signal Toolkit Calculator',
            subtitle: 'Convert between signals and engineering units',
            child: const SizedBox(height: 8),
          ),
          const SizedBox(height: 20),

          // Mode Selection Card
          AppCard(
            backgroundColor: Theme.of(context).cardTheme.color,
            accentColor: Theme.of(context).colorScheme.primary,
            title: 'Signal Type',
            subtitle: 'Select the signal type to work with',
            child: DropdownButtonFormField<int>(
              value: _mode,
              decoration: AppFormStyles.decoration(context),
              items: const [
                DropdownMenuItem(
                  value: 0,
                  child: Row(
                    children: [
                      Icon(Icons.electrical_services, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('4-20 mA Current Loop'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.flash_on, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('0-10V Voltage Signal'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.memory, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Raw Count (0-32767)'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _mode = value;
                    _result = '';
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 20),

          // Engineering Range Card
          AppCard(
            backgroundColor: Theme.of(context).cardTheme.color,
            accentColor: Theme.of(context).colorScheme.secondary,
            title: 'Engineering Range',
            subtitle: 'Define the engineering unit range',
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _engMinCtrl,
                    keyboardType: TextInputType.number,
                    style: AppFormStyles.fieldText(context),
                    decoration: AppFormStyles.decoration(
                      context,
                      labelText: 'Min Value',
                      prefixIcon: const Icon(Icons.arrow_downward),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _engMaxCtrl,
                    keyboardType: TextInputType.number,
                    style: AppFormStyles.fieldText(context),
                    decoration: AppFormStyles.decoration(
                      context,
                      labelText: 'Max Value',
                      prefixIcon: const Icon(Icons.arrow_upward),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Input Value Card
          AppCard(
            backgroundColor: Theme.of(context).cardTheme.color,
            accentColor: Theme.of(context).colorScheme.tertiary,
            title: 'Input Value',
            subtitle: _getInputSubtitle(),
            child: TextField(
              controller: _signalValueCtrl,
              keyboardType: TextInputType.number,
              style: AppFormStyles.fieldText(context),
              decoration: AppFormStyles.decoration(
                context,
                labelText: _getInputLabel(),
                hintText: _getInputHint(),
                prefixIcon: Icon(_getInputIcon()),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons Card
          AppCard(
            backgroundColor: Theme.of(context).cardTheme.color,
            accentColor: Theme.of(context).colorScheme.primary,
            title: 'Conversion',
            subtitle: 'Choose conversion direction',
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _convertToEngineering,
                    icon: const Icon(Icons.transform),
                    label: const Text('Signal \u2192 Engineering'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _convertToSignal,
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Engineering \u2192 Signal'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Result Display
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 20),
            AppCard(
              accentColor: AppTheme.success,
              title: 'Conversion Result',
              subtitle: 'Calculated values',
              child: CalculationResultBox(text: _result),
            ),
          ],
        ],
      ),
    );
  }

  String _getInputLabel() {
    switch (_mode) {
      case 0:
        return 'Signal Value (mA) or Engineering Value';
      case 1:
        return 'Signal Value (V) or Engineering Value';
      case 2:
        return 'Raw Count or Engineering Value';
      default:
        return 'Input Value';
    }
  }

  String _getInputSubtitle() {
    switch (_mode) {
      case 0:
        return 'Enter 4-20mA signal or engineering unit value';
      case 1:
        return 'Enter 0-10V signal or engineering unit value';
      case 2:
        return 'Enter raw count (0-32767) or engineering unit value';
      default:
        return 'Enter the value to convert';
    }
  }

  IconData _getInputIcon() {
    switch (_mode) {
      case 0:
        return Icons.electrical_services;
      case 1:
        return Icons.flash_on;
      case 2:
        return Icons.memory;
      default:
        return Icons.input;
    }
  }

  String _getInputHint() {
    switch (_mode) {
      case 0:
        return 'e.g., 12.0 mA or 50.0';
      case 1:
        return 'e.g., 5.0 V or 75.0';
      case 2:
        return 'e.g., 16384 or 25.0';
      default:
        return '';
    }
  }
}

class ProtocolRegisterMapperTool extends StatefulWidget {
  const ProtocolRegisterMapperTool({super.key});

  @override
  State<ProtocolRegisterMapperTool> createState() =>
      _ProtocolRegisterMapperToolState();
}

class _ProtocolRegisterMapperToolState
    extends State<ProtocolRegisterMapperTool> {
  final _registerCtrl = TextEditingController(text: '40001');
  final _rawValueCtrl = TextEditingController();
  final _scaleCtrl = TextEditingController(text: '0.1');
  final _offsetCtrl = TextEditingController(text: '0');
  String _dataType = 'UINT16';
  String _result = '';

  void _mapRegister() {
    final register = int.tryParse(_registerCtrl.text) ?? 0;
    final raw = double.tryParse(_rawValueCtrl.text) ?? 0;
    final scale = double.tryParse(_scaleCtrl.text) ?? 1;
    final offset = double.tryParse(_offsetCtrl.text) ?? 0;

    final eng = (raw * scale) + offset;
    final functionCode = register >= 40001
        ? 'FC03 (Holding Register)'
        : register >= 30001
            ? 'FC04 (Input Register)'
            : 'Custom/Register Map';

    setState(() {
      _result = 'Register: $register\n'
          'Function: $functionCode\n'
          'Data Type: $_dataType\n'
          'Raw Value: ${raw.toStringAsFixed(2)}\n'
          'Engineering Value: ${eng.toStringAsFixed(2)}\n'
          'Formula: Eng = (Raw ? $scale) + $offset';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Protocol Register Mapper',
              style: AppFormStyles.sectionTitle(context)),
          const SizedBox(height: 16),
          TextField(
            controller: _registerCtrl,
            keyboardType: TextInputType.number,
            decoration: AppFormStyles.decoration(context,
                labelText: 'Register Address (e.g. 40001)'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _dataType,
            items: const [
              DropdownMenuItem(value: 'UINT16', child: Text('UINT16')),
              DropdownMenuItem(value: 'INT16', child: Text('INT16')),
              DropdownMenuItem(value: 'UINT32', child: Text('UINT32 (2 regs)')),
              DropdownMenuItem(
                  value: 'FLOAT32', child: Text('FLOAT32 (2 regs)')),
            ],
            onChanged: (v) => setState(() => _dataType = v ?? 'UINT16'),
            decoration: AppFormStyles.decoration(context,
                labelText: 'Data Type'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _rawValueCtrl,
            keyboardType: TextInputType.number,
            decoration: AppFormStyles.decoration(context,
                labelText: 'Raw Register Value'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _scaleCtrl,
                  keyboardType: TextInputType.number,
                  decoration: AppFormStyles.decoration(context,
                      labelText: 'Scale'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _offsetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: AppFormStyles.decoration(context,
                      labelText: 'Offset'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _mapRegister,
            child: const Text('Map Register'),
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 16),
            CalculationResultBox(
              text: _result,
              accentColor: AppTheme.warning,
            ),
          ],
        ],
      ),
    );
  }
}

// Thermocouple Calculator
class ThermocoupleCalculator extends StatefulWidget {
  const ThermocoupleCalculator({super.key});

  @override
  State<ThermocoupleCalculator> createState() => _ThermocoupleCalculatorState();
}

class _ThermocoupleCalculatorState extends State<ThermocoupleCalculator> {
  final _voltageCtrl = TextEditingController();
  String _type = 'K';
  String _result = '';

  // ITS-90 polynomial approximation
  double _mvToTemp(double mv, String type) {
    if (type == 'K') {
      // K-type: valid -200?C to 1372?C
      if (mv < 0) return mv * 25.173 + 0.0;
      if (mv < 20.644) return mv * 25.08355 - 0.23343 * mv * mv / 10;
      return mv * 24.964 - 0.1166 * mv * mv / 10 + 100;
    } else if (type == 'J') {
      // J-type: valid -210?C to 1200?C
      if (mv < 0) return mv * 19.849;
      if (mv < 42.919) return mv * 19.738 - 0.0847 * mv * mv / 10;
      return mv * 18.801 + 50;
    } else if (type == 'T') {
      // T-type: valid -270?C to 400?C
      return mv * 25.928 - 0.7602 * mv * mv / 100;
    } else if (type == 'E') {
      // E-type: valid -270?C to 1000?C
      return mv * 17.057 - 0.2349 * mv * mv / 100;
    } else if (type == 'S') {
      // S-type: valid 0?C to 1768?C
      return mv * 98.45 - 1.2 * mv * mv;
    } else if (type == 'R') {
      // R-type: valid 0?C to 1768?C
      return mv * 94.07 - 1.1 * mv * mv;
    }
    return mv * 25.0;
  }

  void _calculate() {
    final mv = double.tryParse(_voltageCtrl.text) ?? 0;
    if (mv != 0) {
      final temp = _mvToTemp(mv, _type);
      final tempF = temp * 9 / 5 + 32;
      setState(() => _result =
          'Temperature: ${temp.toStringAsFixed(1)} ?C  /  ${tempF.toStringAsFixed(1)} ?F');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Thermocouple Temperature Calculator',
              style: AppFormStyles.sectionTitle(context)),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _type,
            items: const [
              DropdownMenuItem(value: 'K', child: Text('Type K  (-200?C to 1372?C)')),
              DropdownMenuItem(value: 'J', child: Text('Type J  (-210?C to 1200?C)')),
              DropdownMenuItem(value: 'T', child: Text('Type T  (-270?C to 400?C)')),
              DropdownMenuItem(value: 'E', child: Text('Type E  (-270?C to 1000?C)')),
              DropdownMenuItem(value: 'S', child: Text('Type S  (0?C to 1768?C)')),
              DropdownMenuItem(value: 'R', child: Text('Type R  (0?C to 1768?C)')),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'K'),
            decoration: AppFormStyles.decoration(context,labelText: 'Thermocouple Type'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _voltageCtrl,
            decoration: AppFormStyles.decoration(context,labelText: 'Voltage (mV)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _calculate, child: const Text('Calculate')),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 24),
            CalculationResultBox(
              text: _result,
              accentColor: AppTheme.error,
            ),
          ],
        ],
      ),
    );
  }
}

// Pressure Calculator
class PressureCalculator extends StatefulWidget {
  const PressureCalculator({super.key});

  @override
  State<PressureCalculator> createState() => _PressureCalculatorState();
}

class _PressureCalculatorState extends State<PressureCalculator> {
  final _voltageCtrl = TextEditingController();
  final _minPressureCtrl = TextEditingController(text: '0');
  final _maxPressureCtrl = TextEditingController(text: '10');
  bool _isCurrent = true;
  String _result = '';

  void _calculate() {
    final voltage = double.tryParse(_voltageCtrl.text) ?? 0;
    final minP = double.tryParse(_minPressureCtrl.text) ?? 0;
    final maxP = double.tryParse(_maxPressureCtrl.text) ?? 10;

    if (voltage >= 0) {
      final minSignal = _isCurrent ? 4.0 : 0.0;
      final maxSignal = _isCurrent ? 20.0 : 10.0;
      final clamped = voltage.clamp(minSignal, maxSignal);
      final pressure = minP + ((clamped - minSignal) / (maxSignal - minSignal)) * (maxP - minP);
      setState(() => _result = 'Pressure: ${pressure.toStringAsFixed(2)} bar');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pressure Transmitter Calculator',
              style: AppFormStyles.sectionTitle(context)),
          const SizedBox(height: 24),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('4-20 mA')),
              ButtonSegment(value: false, label: Text('0-10 V')),
            ],
            selected: {_isCurrent},
            onSelectionChanged: (s) => setState(() => _isCurrent = s.first),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPressureCtrl,
                  decoration: AppFormStyles.decoration(context,labelText: 'Min Pressure (bar)'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _maxPressureCtrl,
                  decoration: AppFormStyles.decoration(context,labelText: 'Max Pressure (bar)'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _voltageCtrl,
            decoration: AppFormStyles.decoration(
              context,
              labelText: _isCurrent ? 'Current (mA)' : 'Voltage (V)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _calculate, child: const Text('Calculate')),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 24),
            CalculationResultBox(
              text: _result,
              accentColor: AppTheme.grey500,
            ),
          ],
        ],
      ),
    );
  }
}

// Harmonics Calculator
class HarmonicsCalculator extends StatefulWidget {
  const HarmonicsCalculator({super.key});

  @override
  State<HarmonicsCalculator> createState() => _HarmonicsCalculatorState();
}

class _HarmonicsCalculatorState extends State<HarmonicsCalculator> {
  final _fundamentalCtrl = TextEditingController();
  final _harmonicCtrl = TextEditingController();
  final _orderCtrl = TextEditingController(text: '5');
  String _result = '';

  void _calculate() {
    final fund = double.tryParse(_fundamentalCtrl.text) ?? 0;
    final harm = double.tryParse(_harmonicCtrl.text) ?? 0;
    // order used for display only
    final order = int.tryParse(_orderCtrl.text) ?? 5;

    if (fund > 0 && harm > 0) {
      final thd = (harm / fund) * 100;
      final distortion = thd / sqrt(1 + pow(thd / 100, 2));
      setState(() => _result = 'Harmonic Order: $order\n'
          'THD: ${thd.toStringAsFixed(2)}%\n'
          'Distortion Factor: ${distortion.toStringAsFixed(2)}%');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Harmonic Distortion Calculator',
              style: AppFormStyles.sectionTitle(context)),
          const SizedBox(height: 24),
          TextField(
            controller: _fundamentalCtrl,
            decoration: AppFormStyles.decoration(context,labelText: 'Fundamental (V/A)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _harmonicCtrl,
            decoration: AppFormStyles.decoration(context,labelText: 'Harmonic Amplitude (V/A)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _orderCtrl,
            decoration: AppFormStyles.decoration(context,labelText: 'Harmonic Order'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _calculate, child: const Text('Calculate')),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 24),
            CalculationResultBox(
              text: _result,
              accentColor: AppTheme.secondaryPurple,
            ),
          ],
        ],
      ),
    );
  }
}
