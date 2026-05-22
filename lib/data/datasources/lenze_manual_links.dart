class LenzeManualLink {
  final String modelName;
  final String manualType;
  final String url;

  const LenzeManualLink({
    required this.modelName,
    required this.manualType,
    required this.url,
  });
}

class LenzeManualLinks {
  static const List<LenzeManualLink> all = [
    // LENZE Model
    LenzeManualLink(
      modelName: 'LENZE Model',
      manualType: 'User Manual',
      url: '',
    ),
    LenzeManualLink(
      modelName: 'LENZE Model',
      manualType: 'Troubleshooting Guide',
      url: '',
    ),
    LenzeManualLink(
      modelName: 'LENZE Model',
      manualType: 'Parameter Guide',
      url: '',
    ),
    // i550 motec
    LenzeManualLink(
      modelName: 'i550 motec',
      manualType: 'User Manual',
      url: 'https://file.hstatic.net/1000288684/file/bien_tan_lenze_i550_motec_operating_instructions_5769644acda94b80a7cecc07ad413c23.pdf',
    ),
    LenzeManualLink(
      modelName: 'i550 motec',
      manualType: 'Troubleshooting Guide',
      url: 'https://file.hstatic.net/1000288684/file/bien_tan_lenze_i550_motec_operating_instructions_5769644acda94b80a7cecc07ad413c23.pdf',
    ),
    LenzeManualLink(
      modelName: 'i550 motec',
      manualType: 'Parameter Guide',
      url: 'https://file.hstatic.net/1000288684/file/bien_tan_lenze_i550_motec_operating_instructions_5769644acda94b80a7cecc07ad413c23.pdf',
    ),
    // i550 cabinet
    LenzeManualLink(
      modelName: 'i550 cabinet',
      manualType: 'User Manual',
      url: 'https://www.lenze.com/en-de/products/inverters/frequency-inverters/i550-cabinet-frequency-inverter/',
    ),
    LenzeManualLink(
      modelName: 'i550 cabinet',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.lenze.com/en-de/products/inverters/frequency-inverters/i550-cabinet-frequency-inverter/',
    ),
    LenzeManualLink(
      modelName: 'i550 cabinet',
      manualType: 'Parameter Guide',
      url: 'https://www.lenze.com/en-de/products/inverters/frequency-inverters/i550-cabinet-frequency-inverter/',
    ),
    // 8400 protec
    LenzeManualLink(
      modelName: '8400 protec',
      manualType: 'User Manual',
      url: 'https://www.lenze.com/en-de/products/inverters/inverter-drives-8400-protec/',
    ),
    LenzeManualLink(
      modelName: '8400 protec',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.lenze.com/en-de/products/inverters/inverter-drives-8400-protec/',
    ),
    LenzeManualLink(
      modelName: '8400 protec',
      manualType: 'Parameter Guide',
      url: 'https://www.lenze.com/en-de/products/inverters/inverter-drives-8400-protec/',
    ),
    // MC
    LenzeManualLink(
      modelName: 'MC',
      manualType: 'User Manual',
      url: 'https://www.lenze.com/en-de/products/servo-drives/controllers/mc300/',
    ),
    LenzeManualLink(
      modelName: 'MC',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.lenze.com/en-de/products/servo-drives/controllers/mc300/',
    ),
    LenzeManualLink(
      modelName: 'MC',
      manualType: 'Parameter Guide',
      url: 'https://www.lenze.com/en-de/products/servo-drives/controllers/mc300/',
    ),
    // 8400 BaseLine
    LenzeManualLink(
      modelName: '8400 BaseLine',
      manualType: 'User Manual',
      url: 'https://www.lenze.com/en-de/products/inverters/inverter-drives-8400-baseline/',
    ),
    LenzeManualLink(
      modelName: '8400 BaseLine',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.lenze.com/en-de/products/inverters/inverter-drives-8400-baseline/',
    ),
    LenzeManualLink(
      modelName: '8400 BaseLine',
      manualType: 'Parameter Guide',
      url: 'https://www.lenze.com/en-de/products/inverters/inverter-drives-8400-baseline/',
    ),
    // 8200 motec
    LenzeManualLink(
      modelName: '8200 motec',
      manualType: 'User Manual',
      url: 'https://www.lenze.com/en-de/products/inverters/frequency-inverters/8200-motec/',
    ),
    LenzeManualLink(
      modelName: '8200 motec',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.lenze.com/en-de/products/inverters/frequency-inverters/8200-motec/',
    ),
    LenzeManualLink(
      modelName: '8200 motec',
      manualType: 'Parameter Guide',
      url: 'https://www.lenze.com/en-de/products/inverters/frequency-inverters/8200-motec/',
    ),
    // i510
    LenzeManualLink(
      modelName: 'i510',
      manualType: 'User Manual',
      url: 'https://www.motionworld.com/assets/Lenze-i510-cabinet-frequency-inverter-manual.pdf',
    ),
    LenzeManualLink(
      modelName: 'i510',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.motionworld.com/assets/Lenze-i510-cabinet-frequency-inverter-manual.pdf',
    ),
    LenzeManualLink(
      modelName: 'i510',
      manualType: 'Parameter Guide',
      url: 'https://www.motionworld.com/assets/Lenze-i510-cabinet-frequency-inverter-manual.pdf',
    ),
    // 8400 stateline
    LenzeManualLink(
      modelName: '8400 stateline',
      manualType: 'User Manual',
      url: 'https://www.lenze.org.ua/pdf/8400/SW_E84AVSCxx_Parameterisation_StateLineC_v7-1_EN.pdf',
    ),
    LenzeManualLink(
      modelName: '8400 stateline',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.lenze.org.ua/pdf/8400/SW_E84AVSCxx_Parameterisation_StateLineC_v7-1_EN.pdf',
    ),
    LenzeManualLink(
      modelName: '8400 stateline',
      manualType: 'Parameter Guide',
      url: 'https://www.lenze.org.ua/pdf/8400/SW_E84AVSCxx_Parameterisation_StateLineC_v7-1_EN.pdf',
    ),
    // 8400 motec
    LenzeManualLink(
      modelName: '8400 motec',
      manualType: 'User Manual',
      url: 'https://fcrmotion.com.au/wp-content/uploads/2021/10/Lenze-8400-Motec-Manual.pdf',
    ),
    LenzeManualLink(
      modelName: '8400 motec',
      manualType: 'Troubleshooting Guide',
      url: 'https://fcrmotion.com.au/wp-content/uploads/2021/10/Lenze-8400-Motec-Manual.pdf',
    ),
    LenzeManualLink(
      modelName: '8400 motec',
      manualType: 'Parameter Guide',
      url: 'https://fcrmotion.com.au/wp-content/uploads/2021/10/Lenze-8400-Motec-Manual.pdf',
    ),
    // SCF
    LenzeManualLink(
      modelName: 'SCF',
      manualType: 'User Manual',
      url: 'https://www.lenze.com/en-de/products/servo-drives/controllers/scf/',
    ),
    LenzeManualLink(
      modelName: 'SCF',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.lenze.com/en-de/products/servo-drives/controllers/scf/',
    ),
    LenzeManualLink(
      modelName: 'SCF',
      manualType: 'Parameter Guide',
      url: 'https://www.lenze.com/en-de/products/servo-drives/controllers/scf/',
    ),
    // 9300 vector
    LenzeManualLink(
      modelName: '9300 vector',
      manualType: 'User Manual',
      url: 'https://www.scribd.com/document/478087629/Frequency-Inverters-8200-9300-vector-filters-pdf',
    ),
    LenzeManualLink(
      modelName: '9300 vector',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.scribd.com/document/478087629/Frequency-Inverters-8200-9300-vector-filters-pdf',
    ),
    LenzeManualLink(
      modelName: '9300 vector',
      manualType: 'Parameter Guide',
      url: 'https://www.scribd.com/document/478087629/Frequency-Inverters-8200-9300-vector-filters-pdf',
    ),
    // SMD
    LenzeManualLink(
      modelName: 'SMD',
      manualType: 'User Manual',
      url: 'https://www.unisgroup.nl/pdf/EN/Lenze-SMD-Frequency-Converter-Datasheet.pdf',
    ),
    LenzeManualLink(
      modelName: 'SMD',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.unisgroup.nl/pdf/EN/Lenze-SMD-Frequency-Converter-Datasheet.pdf',
    ),
    LenzeManualLink(
      modelName: 'SMD',
      manualType: 'Parameter Guide',
      url: 'https://www.unisgroup.nl/pdf/EN/Lenze-SMD-Frequency-Converter-Datasheet.pdf',
    ),
    // i550 protec
    LenzeManualLink(
      modelName: 'i550 protec',
      manualType: 'User Manual',
      url: 'https://www.wolfautomation.com/content/lenze-i550-protec-commission-manual-21.pdf',
    ),
    LenzeManualLink(
      modelName: 'i550 protec',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.wolfautomation.com/content/lenze-i550-protec-commission-manual-21.pdf',
    ),
    LenzeManualLink(
      modelName: 'i550 protec',
      manualType: 'Parameter Guide',
      url: 'https://www.wolfautomation.com/content/lenze-i550-protec-commission-manual-21.pdf',
    ),
    // 8400 high line
    LenzeManualLink(
      modelName: '8400 high line',
      manualType: 'User Manual',
      url: 'https://www.lenze.com/en-de/products/inverters/inverter-drives-8400-highline/',
    ),
    LenzeManualLink(
      modelName: '8400 high line',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.lenze.com/en-de/products/inverters/inverter-drives-8400-highline/',
    ),
    LenzeManualLink(
      modelName: '8400 high line',
      manualType: 'Parameter Guide',
      url: 'https://www.lenze.com/en-de/products/inverters/inverter-drives-8400-highline/',
    ),
    // sm vector
    LenzeManualLink(
      modelName: 'sm vector',
      manualType: 'User Manual',
      url: 'https://www.lenze.com/en-de/products/inverters/frequency-inverters/smvector/',
    ),
    LenzeManualLink(
      modelName: 'sm vector',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.lenze.com/en-de/products/inverters/frequency-inverters/smvector/',
    ),
    LenzeManualLink(
      modelName: 'sm vector',
      manualType: 'Parameter Guide',
      url: 'https://www.lenze.com/en-de/products/inverters/frequency-inverters/smvector/',
    ),
    // SCM/SCL
    LenzeManualLink(
      modelName: 'SCM/SCL',
      manualType: 'User Manual',
      url: 'https://www.uvm.edu/cosmolab/om/SCL_SCMseriesmanual.pdf',
    ),
    LenzeManualLink(
      modelName: 'SCM/SCL',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.uvm.edu/cosmolab/om/SCL_SCMseriesmanual.pdf',
    ),
    LenzeManualLink(
      modelName: 'SCM/SCL',
      manualType: 'Parameter Guide',
      url: 'https://www.uvm.edu/cosmolab/om/SCL_SCMseriesmanual.pdf',
    ),
    // 8200 vector
    LenzeManualLink(
      modelName: '8200 vector',
      manualType: 'User Manual',
      url: 'https://fcrmotion.com.au/wp-content/uploads/2021/10/Lenze-8200-Vector-Manual.pdf',
    ),
    LenzeManualLink(
      modelName: '8200 vector',
      manualType: 'Troubleshooting Guide',
      url: 'https://fcrmotion.com.au/wp-content/uploads/2021/10/Lenze-8200-Vector-Manual.pdf',
    ),
    LenzeManualLink(
      modelName: '8200 vector',
      manualType: 'Parameter Guide',
      url: 'https://assets.euautomation.com/uploads/parts/pdf/epmt110.pdf',
    ),
    // OCU
    LenzeManualLink(
      modelName: 'OCU',
      manualType: 'User Manual',
      url: 'https://www.lenze.com/en-de/products/accessories/keypads/',
    ),
    LenzeManualLink(
      modelName: 'OCU',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.lenze.com/en-de/products/accessories/keypads/',
    ),
    LenzeManualLink(
      modelName: 'OCU',
      manualType: 'Parameter Guide',
      url: 'https://www.lenze.com/en-de/products/accessories/keypads/',
    ),
  ];
}