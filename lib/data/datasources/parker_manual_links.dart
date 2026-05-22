class ParkerManualLink {
  final String modelName; // Must match vfd_models.name exactly
  final String manualType;
  final String url;

  const ParkerManualLink({
    required this.modelName,
    required this.manualType,
    required this.url,
  });
}

class ParkerManualLinks {
  static const List<ParkerManualLink> all = [
    // AC690
    ParkerManualLink(
      modelName: 'AC690',
      manualType: 'User Manual',
      url: 'https://www.google.com/search?q=AC690+manual',
    ),
    ParkerManualLink(
      modelName: 'AC690',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.google.com/search?q=AC690+fault',
    ),
    ParkerManualLink(
      modelName: 'AC690',
      manualType: 'Parameter Guide',
      url: 'https://www.google.com/search?q=AC690+communication',
    ),
    // AC890
    ParkerManualLink(
      modelName: 'AC890',
      manualType: 'User Manual',
      url: 'https://www.google.com/search?q=AC890+manual',
    ),
    ParkerManualLink(
      modelName: 'AC890',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.google.com/search?q=AC890+fault',
    ),
    ParkerManualLink(
      modelName: 'AC890',
      manualType: 'Parameter Guide',
      url: 'https://www.google.com/search?q=AC890+communication',
    ),
    // AC30
    ParkerManualLink(
      modelName: 'AC30',
      manualType: 'User Manual',
      url: 'https://www.google.com/search?q=AC30+manual',
    ),
    ParkerManualLink(
      modelName: 'AC30',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.google.com/search?q=AC30+fault',
    ),
    ParkerManualLink(
      modelName: 'AC30',
      manualType: 'Parameter Guide',
      url: 'https://www.google.com/search?q=AC30+communication',
    ),
    // AC10
    ParkerManualLink(
      modelName: 'AC10',
      manualType: 'User Manual',
      url: 'https://www.google.com/search?q=AC10+manual',
    ),
    ParkerManualLink(
      modelName: 'AC10',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.google.com/search?q=AC10+fault',
    ),
    ParkerManualLink(
      modelName: 'AC10',
      manualType: 'Parameter Guide',
      url: 'https://www.google.com/search?q=AC10+communication',
    ),
    // AC650
    ParkerManualLink(
      modelName: 'AC650',
      manualType: 'User Manual',
      url: 'https://www.google.com/search?q=AC650+manual',
    ),
    ParkerManualLink(
      modelName: 'AC650',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.google.com/search?q=AC650+fault',
    ),
    ParkerManualLink(
      modelName: 'AC650',
      manualType: 'Parameter Guide',
      url: 'https://www.google.com/search?q=AC650+communication',
    ),
    // AC10P
    ParkerManualLink(
      modelName: 'AC10P',
      manualType: 'User Manual',
      url: 'https://www.google.com/search?q=AC10P+manual',
    ),
    ParkerManualLink(
      modelName: 'AC10P',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.google.com/search?q=AC10P+fault',
    ),
    ParkerManualLink(
      modelName: 'AC10P',
      manualType: 'Parameter Guide',
      url: 'https://www.google.com/search?q=AC10P+communication',
    ),
    // AC650G
    ParkerManualLink(
      modelName: 'AC650G',
      manualType: 'User Manual',
      url: 'https://www.google.com/search?q=AC650G+manual',
    ),
    ParkerManualLink(
      modelName: 'AC650G',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.google.com/search?q=AC650G+fault',
    ),
    ParkerManualLink(
      modelName: 'AC650G',
      manualType: 'Parameter Guide',
      url: 'https://www.google.com/search?q=AC650G+communication',
    ),
    // AC650V
    ParkerManualLink(
      modelName: 'AC650V',
      manualType: 'User Manual',
      url: 'https://www.google.com/search?q=AC650V+manual',
    ),
    ParkerManualLink(
      modelName: 'AC650V',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.google.com/search?q=AC650V+fault',
    ),
    ParkerManualLink(
      modelName: 'AC650V',
      manualType: 'Parameter Guide',
      url: 'https://www.google.com/search?q=AC650V+communication',
    ),
    // AC650S
    ParkerManualLink(
      modelName: 'AC650S',
      manualType: 'User Manual',
      url: 'https://www.google.com/search?q=AC650S+manual',
    ),
    ParkerManualLink(
      modelName: 'AC650S',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.google.com/search?q=AC650S+fault',
    ),
    ParkerManualLink(
      modelName: 'AC650S',
      manualType: 'Parameter Guide',
      url: 'https://www.google.com/search?q=AC650S+communication',
    ),
    // AC690+
    ParkerManualLink(
      modelName: 'AC690+',
      manualType: 'User Manual',
      url: 'https://www.google.com/search?q=AC690++manual',
    ),
    ParkerManualLink(
      modelName: 'AC690+',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.google.com/search?q=AC690++fault',
    ),
    ParkerManualLink(
      modelName: 'AC690+',
      manualType: 'Parameter Guide',
      url: 'https://www.google.com/search?q=AC690++communication',
    ),
    // AC890PX
    ParkerManualLink(
      modelName: 'AC890PX',
      manualType: 'User Manual',
      url: 'https://www.google.com/search?q=AC890PX+manual',
    ),
    ParkerManualLink(
      modelName: 'AC890PX',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.google.com/search?q=AC890PX+fault',
    ),
    ParkerManualLink(
      modelName: 'AC890PX',
      manualType: 'Parameter Guide',
      url: 'https://www.google.com/search?q=AC890PX+communication',
    ),
    // Fastpack
    ParkerManualLink(
      modelName: 'Fastpack',
      manualType: 'User Manual',
      url: 'https://www.google.com/search?q=Fastpack+manual',
    ),
    ParkerManualLink(
      modelName: 'Fastpack',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.google.com/search?q=Fastpack+fault',
    ),
    ParkerManualLink(
      modelName: 'Fastpack',
      manualType: 'Parameter Guide',
      url: 'https://www.google.com/search?q=Fastpack+communication',
    ),
  ];
}
