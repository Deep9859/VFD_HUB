class NidecManualLink {
  final String modelName;
  final String manualType;
  final String url;

  const NidecManualLink({
    required this.modelName,
    required this.manualType,
    required this.url,
  });
}

class NidecManualLinks {
  static const List<NidecManualLink> all = [
    // NIDEC Model
    NidecManualLink(
      modelName: 'NIDEC Model',
      manualType: 'User Manual',
      url: '',
    ),
    NidecManualLink(
      modelName: 'NIDEC Model',
      manualType: 'Troubleshooting Guide',
      url: '',
    ),
    NidecManualLink(
      modelName: 'NIDEC Model',
      manualType: 'Parameter Guide',
      url: '',
    ),
    // Commander S
    NidecManualLink(
      modelName: 'Commander S',
      manualType: 'User Manual',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/general-purpose-drives/commander-s',
    ),
    NidecManualLink(
      modelName: 'Commander S',
      manualType: 'Troubleshooting Guide',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/general-purpose-drives/commander-s',
    ),
    NidecManualLink(
      modelName: 'Commander S',
      manualType: 'Parameter Guide',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/general-purpose-drives/commander-s',
    ),
    // Commander C200
    NidecManualLink(
      modelName: 'Commander C200',
      manualType: 'User Manual',
      url: 'https://www.leroy-somer.com/documentation_pdf/notices_pdf/CommanderC200_PRG_Open-Loop.pdf',
    ),
    NidecManualLink(
      modelName: 'Commander C200',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.leroy-somer.com/documentation_pdf/notices_pdf/CommanderC200_PRG_Open-Loop.pdf',
    ),
    NidecManualLink(
      modelName: 'Commander C200',
      manualType: 'Parameter Guide',
      url: 'https://www.leroy-somer.com/documentation_pdf/notices_pdf/CommanderC200_PRG_Open-Loop.pdf',
    ),
    // Commander C300
    NidecManualLink(
      modelName: 'Commander C300',
      manualType: 'User Manual',
      url: 'https://moen.nidec.com/drives/-/media/Project/Nidec/ControlTechniques/Documents/Technical/Control-User-Guides/Commander-C/Commander-C300-PM-HS30-PM-Control-User-Guide-Issue-4.pdf',
    ),
    NidecManualLink(
      modelName: 'Commander C300',
      manualType: 'Troubleshooting Guide',
      url: 'https://moen.nidec.com/drives/-/media/Project/Nidec/ControlTechniques/Documents/Technical/Control-User-Guides/Commander-C/Commander-C300-PM-HS30-PM-Control-User-Guide-Issue-4.pdf',
    ),
    NidecManualLink(
      modelName: 'Commander C300',
      manualType: 'Parameter Guide',
      url: 'https://moen.nidec.com/drives/-/media/Project/Nidec/ControlTechniques/Documents/Technical/Control-User-Guides/Commander-C/Commander-C300-PM-HS30-PM-Control-User-Guide-Issue-4.pdf',
    ),
    // DFS Series
    NidecManualLink(
      modelName: 'DFS Series',
      manualType: 'User Manual',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'DFS Series',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'DFS Series',
      manualType: 'Parameter Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    // HVAC Drive H300
    NidecManualLink(
      modelName: 'HVAC Drive H300',
      manualType: 'User Manual',
      url: 'https://www.nidec-netherlands.nl/media/4953-frequentieregelaars-hvac-drive-h300-user-guide-en-iss3-0479-0001-03.pdf',
    ),
    NidecManualLink(
      modelName: 'HVAC Drive H300',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.nidec-netherlands.nl/media/4953-frequentieregelaars-hvac-drive-h300-user-guide-en-iss3-0479-0001-03.pdf',
    ),
    NidecManualLink(
      modelName: 'HVAC Drive H300',
      manualType: 'Parameter Guide',
      url: 'https://www.nidec-netherlands.nl/media/4953-frequentieregelaars-hvac-drive-h300-user-guide-en-iss3-0479-0001-03.pdf',
    ),
    // Pump Drive F600
    NidecManualLink(
      modelName: 'Pump Drive F600',
      manualType: 'User Manual',
      url: 'https://www.nidec-netherlands.nl/media/4827-frequentieregelaars-pump-drive-f600-user-guide-en-iss5-0478-0622-05.pdf',
    ),
    NidecManualLink(
      modelName: 'Pump Drive F600',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.nidec-netherlands.nl/media/4827-frequentieregelaars-pump-drive-f600-user-guide-en-iss5-0478-0622-05.pdf',
    ),
    NidecManualLink(
      modelName: 'Pump Drive F600',
      manualType: 'Parameter Guide',
      url: 'https://www.nidec-netherlands.nl/media/4827-frequentieregelaars-pump-drive-f600-user-guide-en-iss5-0478-0622-05.pdf',
    ),
    // Powerdrive F300
    NidecManualLink(
      modelName: 'Powerdrive F300',
      manualType: 'User Manual',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/high-power-drives/powerdrive-f300',
    ),
    NidecManualLink(
      modelName: 'Powerdrive F300',
      manualType: 'Troubleshooting Guide',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/high-power-drives/powerdrive-f300',
    ),
    NidecManualLink(
      modelName: 'Powerdrive F300',
      manualType: 'Parameter Guide',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/high-power-drives/powerdrive-f300',
    ),
    // Unidrive M700
    NidecManualLink(
      modelName: 'Unidrive M700',
      manualType: 'User Manual',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/high-performance-drives/unidrive-m700',
    ),
    NidecManualLink(
      modelName: 'Unidrive M700',
      manualType: 'Troubleshooting Guide',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/high-performance-drives/unidrive-m700',
    ),
    NidecManualLink(
      modelName: 'Unidrive M700',
      manualType: 'Parameter Guide',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/high-performance-drives/unidrive-m700',
    ),
    // Unidrive M600
    NidecManualLink(
      modelName: 'Unidrive M600',
      manualType: 'User Manual',
      url: 'https://www.nidec-netherlands.nl/media/2082-frequentieregelaars-unidrive-m600-control-user-guide-en-iss2-0478-0337-02.pdf',
    ),
    NidecManualLink(
      modelName: 'Unidrive M600',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.nidec-netherlands.nl/media/2082-frequentieregelaars-unidrive-m600-control-user-guide-en-iss2-0478-0337-02.pdf',
    ),
    NidecManualLink(
      modelName: 'Unidrive M600',
      manualType: 'Parameter Guide',
      url: 'https://www.nidec-netherlands.nl/media/2082-frequentieregelaars-unidrive-m600-control-user-guide-en-iss2-0478-0337-02.pdf',
    ),
    // Unidrive M400
    NidecManualLink(
      modelName: 'Unidrive M400',
      manualType: 'User Manual',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/high-performance-drives/unidrive-m400',
    ),
    NidecManualLink(
      modelName: 'Unidrive M400',
      manualType: 'Troubleshooting Guide',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/high-performance-drives/unidrive-m400',
    ),
    NidecManualLink(
      modelName: 'Unidrive M400',
      manualType: 'Parameter Guide',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/high-performance-drives/unidrive-m400',
    ),
    // Unidrive HS30
    NidecManualLink(
      modelName: 'Unidrive HS30',
      manualType: 'User Manual',
      url: 'https://moen.nidec.com/drives/-/media/Project/Nidec/ControlTechniques/Documents/Technical/Control-User-Guides/Commander-C/Commander-C300-PM-HS30-PM-Control-User-Guide-Issue-4.pdf',
    ),
    NidecManualLink(
      modelName: 'Unidrive HS30',
      manualType: 'Troubleshooting Guide',
      url: 'https://moen.nidec.com/drives/-/media/Project/Nidec/ControlTechniques/Documents/Technical/Control-User-Guides/Commander-C/Commander-C300-PM-HS30-PM-Control-User-Guide-Issue-4.pdf',
    ),
    NidecManualLink(
      modelName: 'Unidrive HS30',
      manualType: 'Parameter Guide',
      url: 'https://moen.nidec.com/drives/-/media/Project/Nidec/ControlTechniques/Documents/Technical/Control-User-Guides/Commander-C/Commander-C300-PM-HS30-PM-Control-User-Guide-Issue-4.pdf',
    ),
    // Unidrive HS70
    NidecManualLink(
      modelName: 'Unidrive HS70',
      manualType: 'User Manual',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/high-performance-drives/unidrive-hs70',
    ),
    NidecManualLink(
      modelName: 'Unidrive HS70',
      manualType: 'Troubleshooting Guide',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/high-performance-drives/unidrive-hs70',
    ),
    NidecManualLink(
      modelName: 'Unidrive HS70',
      manualType: 'Parameter Guide',
      url: 'https://acim.nidec.com/drives/control-techniques/products/ac-drives/high-performance-drives/unidrive-hs70',
    ),
    // NE200 & NE300
    NidecManualLink(
      modelName: 'NE200 & NE300',
      manualType: 'User Manual',
      url: 'https://www.scribd.com/document/867134431/NE200-and-NE300-User-Guide-1',
    ),
    NidecManualLink(
      modelName: 'NE200 & NE300',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.scribd.com/document/867134431/NE200-and-NE300-User-Guide-1',
    ),
    NidecManualLink(
      modelName: 'NE200 & NE300',
      manualType: 'Parameter Guide',
      url: 'https://www.scribd.com/document/867134431/NE200-and-NE300-User-Guide-1',
    ),
    // E300 Elevator
    NidecManualLink(
      modelName: 'E300 Elevator',
      manualType: 'User Manual',
      url: 'https://www.nidec-netherlands.nl/media/3363-frequentieregelaars-elevator-drive-e300-installation-and-system-design-guide-en-iss2-0479-0033-02.pdf',
    ),
    NidecManualLink(
      modelName: 'E300 Elevator',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.nidec-netherlands.nl/media/3363-frequentieregelaars-elevator-drive-e300-installation-and-system-design-guide-en-iss2-0479-0033-02.pdf',
    ),
    NidecManualLink(
      modelName: 'E300 Elevator',
      manualType: 'Parameter Guide',
      url: 'https://www.nidec-netherlands.nl/media/3363-frequentieregelaars-elevator-drive-e300-installation-and-system-design-guide-en-iss2-0479-0033-02.pdf',
    ),
    // Unidrive M100
    NidecManualLink(
      modelName: 'Unidrive M100',
      manualType: 'User Manual',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'Unidrive M100',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'Unidrive M100',
      manualType: 'Parameter Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    // Unidrive M200
    NidecManualLink(
      modelName: 'Unidrive M200',
      manualType: 'User Manual',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'Unidrive M200',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'Unidrive M200',
      manualType: 'Parameter Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    // Unidrive M300
    NidecManualLink(
      modelName: 'Unidrive M300',
      manualType: 'User Manual',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'Unidrive M300',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'Unidrive M300',
      manualType: 'Parameter Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    // Commander SE
    NidecManualLink(
      modelName: 'Commander SE',
      manualType: 'User Manual',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'Commander SE',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'Commander SE',
      manualType: 'Parameter Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    // Commander SX
    NidecManualLink(
      modelName: 'Commander SX',
      manualType: 'User Manual',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'Commander SX',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'Commander SX',
      manualType: 'Parameter Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    // Commander SK
    NidecManualLink(
      modelName: 'Commander SK',
      manualType: 'User Manual',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'Commander SK',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'Commander SK',
      manualType: 'Parameter Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    // Unidrive SP
    NidecManualLink(
      modelName: 'Unidrive SP',
      manualType: 'User Manual',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'Unidrive SP',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
    NidecManualLink(
      modelName: 'Unidrive SP',
      manualType: 'Parameter Guide',
      url: 'https://www.saddlebrookcontrols.com/wp-content/uploads/Control-Techniques-Product-Catalog.pdf',
    ),
  ];
}