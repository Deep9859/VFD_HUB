class YaskawaManualLink {
  final String modelName; // Must match vfd_models.name exactly
  final String manualType;
  final String url;

  const YaskawaManualLink({
    required this.modelName,
    required this.manualType,
    required this.url,
  });
}

class YaskawaManualLinks {
  static const List<YaskawaManualLink> all = [
    // GA800
    YaskawaManualLink(
      modelName: 'GA800',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=GA800+manual',
    ),
    YaskawaManualLink(
      modelName: 'GA800',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=GA800+fault',
    ),
    YaskawaManualLink(
      modelName: 'GA800',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=GA800+communication',
    ),
    // A1000
    YaskawaManualLink(
      modelName: 'A1000',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=A1000+manual',
    ),
    YaskawaManualLink(
      modelName: 'A1000',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=A1000+fault',
    ),
    YaskawaManualLink(
      modelName: 'A1000',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=A1000+communication',
    ),
    // U1000
    YaskawaManualLink(
      modelName: 'U1000',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=U1000+manual',
    ),
    YaskawaManualLink(
      modelName: 'U1000',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=U1000+fault',
    ),
    YaskawaManualLink(
      modelName: 'U1000',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=U1000+communication',
    ),
    // GA500
    YaskawaManualLink(
      modelName: 'GA500',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=GA500+manual',
    ),
    YaskawaManualLink(
      modelName: 'GA500',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=GA500+fault',
    ),
    YaskawaManualLink(
      modelName: 'GA500',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=GA500+communication',
    ),
    // V1000
    YaskawaManualLink(
      modelName: 'V1000',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=V1000+manual',
    ),
    YaskawaManualLink(
      modelName: 'V1000',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=V1000+fault',
    ),
    YaskawaManualLink(
      modelName: 'V1000',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=V1000+communication',
    ),
    // V1000-4X
    YaskawaManualLink(
      modelName: 'V1000-4X',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=V1000-4X+manual',
    ),
    YaskawaManualLink(
      modelName: 'V1000-4X',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=V1000-4X+fault',
    ),
    YaskawaManualLink(
      modelName: 'V1000-4X',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=V1000-4X+communication',
    ),
    // FP605
    YaskawaManualLink(
      modelName: 'FP605',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=FP605+manual',
    ),
    YaskawaManualLink(
      modelName: 'FP605',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=FP605+fault',
    ),
    YaskawaManualLink(
      modelName: 'FP605',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=FP605+communication',
    ),
    // P1000
    YaskawaManualLink(
      modelName: 'P1000',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=P1000+manual',
    ),
    YaskawaManualLink(
      modelName: 'P1000',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=P1000+fault',
    ),
    YaskawaManualLink(
      modelName: 'P1000',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=P1000+communication',
    ),
    // D1000
    YaskawaManualLink(
      modelName: 'D1000',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=D1000+manual',
    ),
    YaskawaManualLink(
      modelName: 'D1000',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=D1000+fault',
    ),
    YaskawaManualLink(
      modelName: 'D1000',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=D1000+communication',
    ),
    // R1000
    YaskawaManualLink(
      modelName: 'R1000',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=R1000+manual',
    ),
    YaskawaManualLink(
      modelName: 'R1000',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=R1000+fault',
    ),
    YaskawaManualLink(
      modelName: 'R1000',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=R1000+communication',
    ),
    // HV600
    YaskawaManualLink(
      modelName: 'HV600',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=HV600+manual',
    ),
    YaskawaManualLink(
      modelName: 'HV600',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=HV600+fault',
    ),
    YaskawaManualLink(
      modelName: 'HV600',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=HV600+communication',
    ),
    // Z1000
    YaskawaManualLink(
      modelName: 'Z1000',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=Z1000+manual',
    ),
    YaskawaManualLink(
      modelName: 'Z1000',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=Z1000+fault',
    ),
    YaskawaManualLink(
      modelName: 'Z1000',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=Z1000+communication',
    ),
    // iQPump1000
    YaskawaManualLink(
      modelName: 'iQPump1000',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=iQPump1000+manual',
    ),
    YaskawaManualLink(
      modelName: 'iQPump1000',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=iQPump1000+fault',
    ),
    YaskawaManualLink(
      modelName: 'iQPump1000',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=iQPump1000+communication',
    ),
    // iQPump Micro
    YaskawaManualLink(
      modelName: 'iQPump Micro',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=iQPump+Micro+manual',
    ),
    YaskawaManualLink(
      modelName: 'iQPump Micro',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=iQPump+Micro+fault',
    ),
    YaskawaManualLink(
      modelName: 'iQPump Micro',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=iQPump+Micro+communication',
    ),
    // L1000A
    YaskawaManualLink(
      modelName: 'L1000A',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=L1000A+manual',
    ),
    YaskawaManualLink(
      modelName: 'L1000A',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=L1000A+fault',
    ),
    YaskawaManualLink(
      modelName: 'L1000A',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=L1000A+communication',
    ),
    // L1000E
    YaskawaManualLink(
      modelName: 'L1000E',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=L1000E+manual',
    ),
    YaskawaManualLink(
      modelName: 'L1000E',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=L1000E+fault',
    ),
    YaskawaManualLink(
      modelName: 'L1000E',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=L1000E+communication',
    ),
    // E7
    YaskawaManualLink(
      modelName: 'E7',
      manualType: 'User Manual',
      url: 'https://www.yaskawa.com/search?query=E7+manual',
    ),
    YaskawaManualLink(
      modelName: 'E7',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.yaskawa.com/search?query=E7+fault',
    ),
    YaskawaManualLink(
      modelName: 'E7',
      manualType: 'Parameter Guide',
      url: 'https://www.yaskawa.com/search?query=E7+communication',
    ),
  ];
}
