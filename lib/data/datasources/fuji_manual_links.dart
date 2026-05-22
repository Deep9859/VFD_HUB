class FujiManualLink {
  final String modelName;
  final String manualType;
  final String url;

  const FujiManualLink({
    required this.modelName,
    required this.manualType,
    required this.url,
  });
}

class FujiManualLinks {
  static const List<FujiManualLink> all = [
    // Fuji Model
    FujiManualLink(
      modelName: 'Fuji Model',
      manualType: 'User Manual',
      url: '',
    ),
    FujiManualLink(
      modelName: 'Fuji Model',
      manualType: 'Troubleshooting Guide',
      url: '',
    ),
    FujiManualLink(
      modelName: 'Fuji Model',
      manualType: 'Parameter Guide',
      url: '',
    ),
    // FRENIC-VG
    FujiManualLink(
      modelName: 'FRENIC-VG',
      manualType: 'User Manual',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-vg/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FRENIC-VG',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-vg/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FRENIC-VG',
      manualType: 'Parameter Guide',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-vg/en/download/index.html',
    ),
    // FRENIC-Mini
    FujiManualLink(
      modelName: 'FRENIC-Mini',
      manualType: 'User Manual',
      url: 'https://www.instrumart.com/assets/Fuji-FRENICmini-instructionmanual.pdf',
    ),
    FujiManualLink(
      modelName: 'FRENIC-Mini',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.instrumart.com/assets/Fuji-FRENICmini-instructionmanual.pdf',
    ),
    FujiManualLink(
      modelName: 'FRENIC-Mini',
      manualType: 'Parameter Guide',
      url: 'https://americas.fujielectric.com/files/RS-485_Users_Manual_24A7-E-0082.pdf',
    ),
    // FRENIC-HVAC
    FujiManualLink(
      modelName: 'FRENIC-HVAC',
      manualType: 'User Manual',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-hvac/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FRENIC-HVAC',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-hvac/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FRENIC-HVAC',
      manualType: 'Parameter Guide',
      url: 'https://americas.fujielectric.com/files/RS-485_Users_Manual_24A7-E-0082.pdf',
    ),
    // FRENIC-eHVAC
    FujiManualLink(
      modelName: 'FRENIC-eHVAC',
      manualType: 'User Manual',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-ehvac/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FRENIC-eHVAC',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-ehvac/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FRENIC-eHVAC',
      manualType: 'Parameter Guide',
      url: 'https://americas.fujielectric.com/files/RS-485_Users_Manual_24A7-E-0082.pdf',
    ),
    // FRENIC-MEGA (G2)
    FujiManualLink(
      modelName: 'FRENIC-MEGA (G2)',
      manualType: 'User Manual',
      url: 'https://www.india.fujielectric.com/hubfs/FRENIC-MEGA(G2)%20User_s%20Manual.pdf',
    ),
    FujiManualLink(
      modelName: 'FRENIC-MEGA (G2)',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.india.fujielectric.com/hubfs/FRENIC-MEGA(G2)%20User_s%20Manual.pdf',
    ),
    FujiManualLink(
      modelName: 'FRENIC-MEGA (G2)',
      manualType: 'Parameter Guide',
      url: 'https://americas.fujielectric.com/files/RS-485_Users_Manual_24A7-E-0082.pdf',
    ),
    // FVR-Micro
    FujiManualLink(
      modelName: 'FVR-Micro',
      manualType: 'User Manual',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/fvr-micro/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FVR-Micro',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/fvr-micro/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FVR-Micro',
      manualType: 'Parameter Guide',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/fvr-micro/en/download/index.html',
    ),
    // FRENIC-Eco
    FujiManualLink(
      modelName: 'FRENIC-Eco',
      manualType: 'User Manual',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-eco/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FRENIC-Eco',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-eco/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FRENIC-Eco',
      manualType: 'Parameter Guide',
      url: 'https://americas.fujielectric.com/files/RS-485_Users_Manual_24A7-E-0082.pdf',
    ),
    // FRENIC-Lift
    FujiManualLink(
      modelName: 'FRENIC-Lift',
      manualType: 'User Manual',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-lift/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FRENIC-Lift',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-lift/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FRENIC-Lift',
      manualType: 'Parameter Guide',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-lift/en/download/index.html',
    ),
    // FRENIC-Ace (E3)
    FujiManualLink(
      modelName: 'FRENIC-Ace (E3)',
      manualType: 'User Manual',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-ace/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FRENIC-Ace (E3)',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-ace/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FRENIC-Ace (E3)',
      manualType: 'Parameter Guide',
      url: 'https://www.instrumart.com/assets/FRENIC-Ace-user-manual.pdf',
    ),
    // FRENIC-Ace (E2)
    FujiManualLink(
      modelName: 'FRENIC-Ace (E2)',
      manualType: 'User Manual',
      url: 'https://www.instrumart.com/assets/FRENIC-Ace-user-manual.pdf',
    ),
    FujiManualLink(
      modelName: 'FRENIC-Ace (E2)',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.instrumart.com/assets/FRENIC-Ace-user-manual.pdf',
    ),
    FujiManualLink(
      modelName: 'FRENIC-Ace (E2)',
      manualType: 'Parameter Guide',
      url: 'https://www.instrumart.com/assets/FRENIC-Ace-user-manual.pdf',
    ),
    // FRENIC-AQUA
    FujiManualLink(
      modelName: 'FRENIC-AQUA',
      manualType: 'User Manual',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-aqua/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FRENIC-AQUA',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.fujielectric.com/products/ac_drives_lv/frenic-aqua/en/download/index.html',
    ),
    FujiManualLink(
      modelName: 'FRENIC-AQUA',
      manualType: 'Parameter Guide',
      url: 'https://americas.fujielectric.com/files/RS-485_Users_Manual_24A7-E-0082.pdf',
    ),
    // FRENIC-Ace (E2)
    FujiManualLink(
      modelName: 'FRENIC-Ace (E2)',
      manualType: 'User Manual',
      url: 'https://www.instrumart.com/assets/FRENIC-Ace-user-manual.pdf',
    ),
    FujiManualLink(
      modelName: 'FRENIC-Ace (E2)',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.instrumart.com/assets/FRENIC-Ace-user-manual.pdf',
    ),
    FujiManualLink(
      modelName: 'FRENIC-Ace (E2)',
      manualType: 'Parameter Guide',
      url: 'https://www.instrumart.com/assets/FRENIC-Ace-user-manual.pdf',
    ),
  ];
}