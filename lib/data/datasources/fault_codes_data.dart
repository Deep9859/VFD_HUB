class FaultCodesData {
  static const List<Map<String, dynamic>> defaultFaultCodes = [
    // ABB Fault Codes
    {
      'vendorId': 'ABB',
      'errorCode': 'E1',
      'description': 'Overcurrent during acceleration',
      'solution':
          'Check motor load, reduce acceleration time, check motor connections',
      'severity': 'High'
    },
    {
      'vendorId': 'ABB',
      'errorCode': 'E2',
      'description': 'Overcurrent during deceleration',
      'solution':
          'Increase deceleration time, check motor braking resistor if used',
      'severity': 'High'
    },
    {
      'vendorId': 'ABB',
      'errorCode': 'E3',
      'description': 'Overcurrent during constant speed',
      'solution':
          'Check motor load, check for mechanical problems, verify parameter settings',
      'severity': 'High'
    },
    {
      'vendorId': 'ABB',
      'errorCode': 'E4',
      'description': 'Overvoltage in DC link',
      'solution':
          'Check input voltage, check braking resistor, increase deceleration time',
      'severity': 'Medium'
    },
    {
      'vendorId': 'ABB',
      'errorCode': 'E5',
      'description': 'Undervoltage in DC link',
      'solution': 'Check input voltage, check mains supply, check fuses',
      'severity': 'Medium'
    },
    {
      'vendorId': 'ABB',
      'errorCode': 'E6',
      'description': 'Motor overtemperature',
      'solution':
          'Check motor cooling, reduce motor load, check motor thermistor',
      'severity': 'High'
    },
    {
      'vendorId': 'ABB',
      'errorCode': 'E7',
      'description': 'Drive overtemperature',
      'solution':
          'Check drive cooling, clean heat sink, check ambient temperature',
      'severity': 'High'
    },

    // Siemens Fault Codes
    {
      'vendorId': 'Siemens',
      'errorCode': 'F0001',
      'description': 'Overcurrent',
      'solution': 'Check motor connections, reduce load, check parameter P0304',
      'severity': 'High'
    },
    {
      'vendorId': 'Siemens',
      'errorCode': 'F0002',
      'description': 'Overvoltage',
      'solution':
          'Check supply voltage, check braking resistor, increase deceleration time',
      'severity': 'Medium'
    },
    {
      'vendorId': 'Siemens',
      'errorCode': 'F0003',
      'description': 'Undervoltage',
      'solution': 'Check mains supply, check fuses, verify voltage settings',
      'severity': 'Medium'
    },
    {
      'vendorId': 'Siemens',
      'errorCode': 'F0011',
      'description': 'Overtemperature drive',
      'solution': 'Check cooling, clean heat sink, check ambient temperature',
      'severity': 'High'
    },
    {
      'vendorId': 'Siemens',
      'errorCode': 'F0012',
      'description': 'Overtemperature motor',
      'solution':
          'Check motor cooling, reduce load, check thermistor connection',
      'severity': 'High'
    },

    // Schneider Fault Codes
    {
      'vendorId': 'Schneider',
      'errorCode': 'OCF',
      'description': 'Overcurrent fault',
      'solution':
          'Check motor load, verify parameter settings, check motor connections',
      'severity': 'High'
    },
    {
      'vendorId': 'Schneider',
      'errorCode': 'OHF',
      'description': 'Drive overtemperature',
      'solution':
          'Check ventilation, clean heat sink, reduce switching frequency',
      'severity': 'High'
    },
    {
      'vendorId': 'Schneider',
      'errorCode': 'OLF',
      'description': 'Motor overload',
      'solution':
          'Reduce motor load, check motor rating, verify parameter settings',
      'severity': 'Medium'
    },
    {
      'vendorId': 'Schneider',
      'errorCode': 'OPF',
      'description': 'Overvoltage fault',
      'solution':
          'Check input voltage, check braking resistor, increase deceleration time',
      'severity': 'Medium'
    },
    {
      'vendorId': 'Schneider',
      'errorCode': 'USF',
      'description': 'Undervoltage fault',
      'solution': 'Check mains supply, check fuses, verify voltage settings',
      'severity': 'Medium'
    },

    // Delta Fault Codes
    {
      'vendorId': 'Delta',
      'errorCode': 'Oc',
      'description': 'Overcurrent during acceleration',
      'solution':
          'Check motor load, increase acceleration time, check motor connections',
      'severity': 'High'
    },
    {
      'vendorId': 'Delta',
      'errorCode': 'Ocd',
      'description': 'Overcurrent during deceleration',
      'solution': 'Increase deceleration time, check braking resistor',
      'severity': 'High'
    },
    {
      'vendorId': 'Delta',
      'errorCode': 'Ov',
      'description': 'Overvoltage',
      'solution':
          'Check input voltage, check braking circuit, increase deceleration time',
      'severity': 'Medium'
    },
    {
      'vendorId': 'Delta',
      'errorCode': 'Lv',
      'description': 'Low voltage',
      'solution': 'Check mains supply, check fuses, verify voltage settings',
      'severity': 'Medium'
    },
    {
      'vendorId': 'Delta',
      'errorCode': 'OH',
      'description': 'Drive overtemperature',
      'solution':
          'Check cooling fan, clean heat sink, check ambient temperature',
      'severity': 'High'
    },
    {
      'vendorId': 'Delta',
      'errorCode': 'OL',
      'description': 'Motor overload',
      'solution':
          'Reduce motor load, check motor rating, verify parameter settings',
      'severity': 'Medium'
    },

    // Mitsubishi Fault Codes
    {
      'vendorId': 'Mitsubishi',
      'errorCode': 'E.OC1',
      'description': 'Overcurrent trip during acceleration',
      'solution':
          'Check motor load, increase acceleration time, check motor connections',
      'severity': 'High'
    },
    {
      'vendorId': 'Mitsubishi',
      'errorCode': 'E.OC2',
      'description': 'Overcurrent trip during deceleration',
      'solution': 'Increase deceleration time, check braking resistor',
      'severity': 'High'
    },
    {
      'vendorId': 'Mitsubishi',
      'errorCode': 'E.OV',
      'description': 'Regenerative overvoltage trip',
      'solution':
          'Check input voltage, check braking resistor, increase deceleration time',
      'severity': 'Medium'
    },
    {
      'vendorId': 'Mitsubishi',
      'errorCode': 'E.LU',
      'description': 'Undervoltage trip',
      'solution': 'Check mains supply, check fuses, verify voltage settings',
      'severity': 'Medium'
    },
    {
      'vendorId': 'Mitsubishi',
      'errorCode': 'E.OH',
      'description': 'Drive unit overtemperature trip',
      'solution': 'Check cooling, clean heat sink, check ambient temperature',
      'severity': 'High'
    },
    {
      'vendorId': 'Mitsubishi',
      'errorCode': 'E.OL',
      'description': 'Motor overload trip',
      'solution':
          'Reduce motor load, check motor rating, verify parameter settings',
      'severity': 'Medium'
    },
  ];
}
