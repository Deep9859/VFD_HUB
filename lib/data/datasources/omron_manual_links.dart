class OmronManualLink {
  final String modelName;
  final String manualType;
  final String url;

  const OmronManualLink({
    required this.modelName,
    required this.manualType,
    required this.url,
  });
}

class OmronManualLinks {
  static const List<OmronManualLink> all = [
    // OMRON Model
    OmronManualLink(
      modelName: 'OMRON Model',
      manualType: 'User Manual',
      url: '',
    ),
    OmronManualLink(
      modelName: 'OMRON Model',
      manualType: 'Troubleshooting Guide',
      url: '',
    ),
    OmronManualLink(
      modelName: 'OMRON Model',
      manualType: 'Parameter Guide',
      url: '',
    ),
    // 3G3MX2-V2
    OmronManualLink(
      modelName: '3G3MX2-V2',
      manualType: 'User Manual',
      url: 'https://files.omron.eu/downloads/latest/manual/en/i666_mx2-ev2_users_manual_en.pdf?v=2',
    ),
    OmronManualLink(
      modelName: '3G3MX2-V2',
      manualType: 'Troubleshooting Guide',
      url: 'https://files.omron.eu/downloads/latest/manual/en/i666_mx2-ev2_users_manual_en.pdf?v=2',
    ),
    OmronManualLink(
      modelName: '3G3MX2-V2',
      manualType: 'Parameter Guide',
      url: 'https://www.omron-ap.co.in/products/family/3912/download/manual.html',
    ),
    // 3GRX2
    OmronManualLink(
      modelName: '3GRX2',
      manualType: 'User Manual',
      url: 'https://files.omron.eu/downloads/latest/manual/en/2824133-4_rx2_series_instruction_manual_en.pdf?v=2',
    ),
    OmronManualLink(
      modelName: '3GRX2',
      manualType: 'Troubleshooting Guide',
      url: 'https://files.omron.eu/downloads/latest/manual/en/2824133-4_rx2_series_instruction_manual_en.pdf?v=2',
    ),
    OmronManualLink(
      modelName: '3GRX2',
      manualType: 'Parameter Guide',
      url: 'https://files.omron.eu/downloads/latest/manual/en/2824133-4_rx2_series_instruction_manual_en.pdf?v=2',
    ),
    // 3G3MX2-V1
    OmronManualLink(
      modelName: '3G3MX2-V1',
      manualType: 'User Manual',
      url: 'https://edata.omron.com.au/eData/Inverters/I570-E2-02B.pdf',
    ),
    OmronManualLink(
      modelName: '3G3MX2-V1',
      manualType: 'Troubleshooting Guide',
      url: 'https://edata.omron.com.au/eData/Inverters/I570-E2-02B.pdf',
    ),
    OmronManualLink(
      modelName: '3G3MX2-V1',
      manualType: 'Parameter Guide',
      url: 'https://edata.omron.com.au/eData/Inverters/I570-E2-02B.pdf',
    ),
  ];
}