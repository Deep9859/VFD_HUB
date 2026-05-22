// Sample VFD Parameters Data

class ParameterData {
  final String code;
  final String name;
  final String description;
  final String defaultValue;
  final String minValue;
  final String maxValue;
  final String group;

  const ParameterData({
    required this.code,
    required this.name,
    required this.description,
    required this.defaultValue,
    required this.minValue,
    required this.maxValue,
    required this.group,
  });
}

class VfdParametersData {
  // Hard I/O Parameters (Basic)
  static const List<ParameterData> hardIOParameters = [
    ParameterData(
      code: 'P00.01',
      name: 'Motor Rated Power',
      description: 'Motor nameplate power rating',
      defaultValue: '7.5',
      minValue: '0.75',
      maxValue: '250',
      group: 'Motor Parameters',
    ),
    ParameterData(
      code: 'P00.02',
      name: 'Motor Rated Voltage',
      description: 'Motor nameplate voltage',
      defaultValue: '400',
      minValue: '200',
      maxValue: '480',
      group: 'Motor Parameters',
    ),
    ParameterData(
      code: 'P00.03',
      name: 'Motor Rated Current',
      description: 'Motor nameplate current',
      defaultValue: '15.0',
      minValue: '0.1',
      maxValue: '1000',
      group: 'Motor Parameters',
    ),
    ParameterData(
      code: 'P00.04',
      name: 'Motor Rated Frequency',
      description: 'Motor nameplate frequency',
      defaultValue: '50',
      minValue: '0',
      maxValue: '400',
      group: 'Motor Parameters',
    ),
    ParameterData(
      code: 'P00.05',
      name: 'Motor Rated Speed',
      description: 'Motor nameplate speed (RPM)',
      defaultValue: '1440',
      minValue: '0',
      maxValue: '36000',
      group: 'Motor Parameters',
    ),
    ParameterData(
      code: 'P01.01',
      name: 'Command Source',
      description: '0=Keypad, 1=Terminal, 2=Comm',
      defaultValue: '1',
      minValue: '0',
      maxValue: '2',
      group: 'Control Parameters',
    ),
    ParameterData(
      code: 'P01.02',
      name: 'Frequency Source',
      description: '0=Keypad, 1=AI1, 2=AI2, 3=Comm',
      defaultValue: '1',
      minValue: '0',
      maxValue: '3',
      group: 'Control Parameters',
    ),
    ParameterData(
      code: 'P02.01',
      name: 'Maximum Frequency',
      description: 'Maximum output frequency',
      defaultValue: '50.00',
      minValue: '0.00',
      maxValue: '400.00',
      group: 'Frequency Parameters',
    ),
    ParameterData(
      code: 'P02.02',
      name: 'Minimum Frequency',
      description: 'Minimum output frequency',
      defaultValue: '0.00',
      minValue: '0.00',
      maxValue: '400.00',
      group: 'Frequency Parameters',
    ),
    ParameterData(
      code: 'P03.01',
      name: 'Acceleration Time 1',
      description: 'Time to accelerate from 0 to max freq',
      defaultValue: '10.0',
      minValue: '0.0',
      maxValue: '6500.0',
      group: 'Ramp Parameters',
    ),
    ParameterData(
      code: 'P03.02',
      name: 'Deceleration Time 1',
      description: 'Time to decelerate from max to 0 freq',
      defaultValue: '10.0',
      minValue: '0.0',
      maxValue: '6500.0',
      group: 'Ramp Parameters',
    ),
    ParameterData(
      code: 'P04.01',
      name: 'DI1 Function',
      description: 'Digital Input 1 function',
      defaultValue: '1',
      minValue: '0',
      maxValue: '50',
      group: 'I/O Parameters',
    ),
    ParameterData(
      code: 'P04.02',
      name: 'DI2 Function',
      description: 'Digital Input 2 function',
      defaultValue: '2',
      minValue: '0',
      maxValue: '50',
      group: 'I/O Parameters',
    ),
    ParameterData(
      code: 'P04.03',
      name: 'DI3 Function',
      description: 'Digital Input 3 function',
      defaultValue: '9',
      minValue: '0',
      maxValue: '50',
      group: 'I/O Parameters',
    ),
    ParameterData(
      code: 'P05.01',
      name: 'AI1 Min Frequency',
      description: 'Frequency at AI1 minimum (0V/4mA)',
      defaultValue: '0.00',
      minValue: '0.00',
      maxValue: '400.00',
      group: 'Analog Input',
    ),
    ParameterData(
      code: 'P05.02',
      name: 'AI1 Max Frequency',
      description: 'Frequency at AI1 maximum (10V/20mA)',
      defaultValue: '50.00',
      minValue: '0.00',
      maxValue: '400.00',
      group: 'Analog Input',
    ),
  ];

  // Communication Parameters (Additional)
  static const List<ParameterData> communicationParameters = [
    ParameterData(
      code: 'P14.01',
      name: 'Comm Address',
      description: 'Communication address (1-247)',
      defaultValue: '1',
      minValue: '1',
      maxValue: '247',
      group: 'Communication',
    ),
    ParameterData(
      code: 'P14.02',
      name: 'Baud Rate',
      description: '0=2400, 1=4800, 2=9600, 3=19200, 4=38400, 5=57600, 6=115200',
      defaultValue: '2',
      minValue: '0',
      maxValue: '6',
      group: 'Communication',
    ),
    ParameterData(
      code: 'P14.03',
      name: 'Data Format',
      description: '0=8-N-2, 1=8-E-1, 2=8-O-1, 3=8-N-1',
      defaultValue: '3',
      minValue: '0',
      maxValue: '3',
      group: 'Communication',
    ),
    ParameterData(
      code: 'P14.04',
      name: 'Comm Timeout',
      description: 'Communication timeout (0=No timeout)',
      defaultValue: '0.0',
      minValue: '0.0',
      maxValue: '60.0',
      group: 'Communication',
    ),
    ParameterData(
      code: 'P14.05',
      name: 'Protocol Type',
      description: '0=Modbus RTU, 1=Modbus ASCII',
      defaultValue: '0',
      minValue: '0',
      maxValue: '1',
      group: 'Communication',
    ),
  ];

  // Get parameters based on connection type
  static List<ParameterData> getParameters(bool isCommunication) {
    if (isCommunication) {
      return [...hardIOParameters, ...communicationParameters];
    }
    return hardIOParameters;
  }
}
