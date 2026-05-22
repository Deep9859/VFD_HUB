class SchneiderManualLink {
  final String modelName; // Must match vfd_models.name exactly
  final String manualType;
  final String url;

  const SchneiderManualLink({
    required this.modelName,
    required this.manualType,
    required this.url,
  });
}

class SchneiderManualLinks {
  static const List<SchneiderManualLink> all = [
    // Altivar Process ATV600
    SchneiderManualLink(
      modelName: 'Altivar Process ATV600',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+Process+ATV600+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Process ATV600',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+Process+ATV600+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Process ATV600',
      manualType: 'Parameter Guide',
      url:
          'https://www.se.com/ww/en/search/Altivar+Process+ATV600+communication',
    ),
    // Altivar Process ATV900
    SchneiderManualLink(
      modelName: 'Altivar Process ATV900',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+Process+ATV900+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Process ATV900',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+Process+ATV900+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Process ATV900',
      manualType: 'Parameter Guide',
      url:
          'https://www.se.com/ww/en/search/Altivar+Process+ATV900+communication',
    ),
    // Easy Altivar ATV610
    SchneiderManualLink(
      modelName: 'Easy Altivar ATV610',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Easy+Altivar+ATV610+manual',
    ),
    SchneiderManualLink(
      modelName: 'Easy Altivar ATV610',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Easy+Altivar+ATV610+fault',
    ),
    SchneiderManualLink(
      modelName: 'Easy Altivar ATV610',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Easy+Altivar+ATV610+communication',
    ),
    // Altivar ATV12
    SchneiderManualLink(
      modelName: 'Altivar ATV12',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV12+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV12',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV12+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV12',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV12+communication',
    ),
    // Altivar Machine ATV320
    SchneiderManualLink(
      modelName: 'Altivar Machine ATV320',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+Machine+ATV320+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Machine ATV320',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+Machine+ATV320+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Machine ATV320',
      manualType: 'Parameter Guide',
      url:
          'https://www.se.com/ww/en/search/Altivar+Machine+ATV320+communication',
    ),
    // Altivar Machine ATV340
    SchneiderManualLink(
      modelName: 'Altivar Machine ATV340',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+Machine+ATV340+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Machine ATV340',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+Machine+ATV340+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Machine ATV340',
      manualType: 'Parameter Guide',
      url:
          'https://www.se.com/ww/en/search/Altivar+Machine+ATV340+communication',
    ),
    // Easy Altivar ATV310
    SchneiderManualLink(
      modelName: 'Easy Altivar ATV310',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Easy+Altivar+ATV310+manual',
    ),
    SchneiderManualLink(
      modelName: 'Easy Altivar ATV310',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Easy+Altivar+ATV310+fault',
    ),
    SchneiderManualLink(
      modelName: 'Easy Altivar ATV310',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Easy+Altivar+ATV310+communication',
    ),
    // Altivar ATV310 (second entry)
    SchneiderManualLink(
      modelName: 'Altivar ATV310',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV310+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV310',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV310+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV310',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV310+communication',
    ),
    // Altivar ATV212
    SchneiderManualLink(
      modelName: 'Altivar ATV212',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV212+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV212',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV212+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV212',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV212+communication',
    ),
    // Altivar ATV Solar
    SchneiderManualLink(
      modelName: 'Altivar ATV Solar',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV+Solar+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV Solar',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV+Solar+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV Solar',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV+Solar+communication',
    ),
    // Altivar ATV630
    SchneiderManualLink(
      modelName: 'Altivar Process ATV630',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV630+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Process ATV630',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV630+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Process ATV630',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV630+communication',
    ),
    // Altivar ATV650
    SchneiderManualLink(
      modelName: 'Altivar Process ATV650',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV650+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Process ATV650',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV650+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Process ATV650',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV650+communication',
    ),
    // Altivar ATV930
    SchneiderManualLink(
      modelName: 'Altivar Process ATV930',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV930+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Process ATV930',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV930+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Process ATV930',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV930+communication',
    ),
    // Altivar ATV950
    SchneiderManualLink(
      modelName: 'Altivar Process ATV950',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV950+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Process ATV950',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV950+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar Process ATV950',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV950+communication',
    ),
    // Altivar ATV31C
    SchneiderManualLink(
      modelName: 'Altivar ATV31C',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV31C+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV31C',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV31C+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV31C',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV31C+communication',
    ),
    // Altivar ATV303
    SchneiderManualLink(
      modelName: 'Altivar ATV303',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV303+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV303',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV303+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV303',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV303+communication',
    ),
    // Altivar ATV312
    SchneiderManualLink(
      modelName: 'Altivar ATV312',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV312+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV312',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV312+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV312',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV312+communication',
    ),
    // Altivar ATV312 Solar
    SchneiderManualLink(
      modelName: 'Altivar ATV312 Solar',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV312+Solar+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV312 Solar',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV312+Solar+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV312 Solar',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV312+Solar+communication',
    ),
    // Altivar ATV32
    SchneiderManualLink(
      modelName: 'Altivar ATV32',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV32+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV32',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV32+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV32',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV32+communication',
    ),
    // Altivar ATV61
    SchneiderManualLink(
      modelName: 'Altivar ATV61',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV61+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV61',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV61+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV61',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV61+communication',
    ),
    // Altivar ATV61 Plus
    SchneiderManualLink(
      modelName: 'Altivar ATV61 Plus',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV61+Plus+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV61 Plus',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV61+Plus+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV61 Plus',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV61+Plus+communication',
    ),
    // Altivar ATV61Q
    SchneiderManualLink(
      modelName: 'Altivar ATV61Q',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV61Q+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV61Q',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV61Q+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV61Q',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV61Q+communication',
    ),
    // Altivar ATV71
    SchneiderManualLink(
      modelName: 'Altivar ATV71',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV71+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV71',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV71+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV71',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV71+communication',
    ),
    // Altivar ATV71 Plus
    SchneiderManualLink(
      modelName: 'Altivar ATV71 Plus',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV71+Plus+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV71 Plus',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV71+Plus+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV71 Plus',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV71+Plus+communication',
    ),
    // Altivar ATV71Q
    SchneiderManualLink(
      modelName: 'Altivar ATV71Q',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV71Q+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV71Q',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV71Q+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV71Q',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV71+communication',
    ),
    // Altivar ATV31
    SchneiderManualLink(
      modelName: 'Altivar ATV31',
      manualType: 'User Manual',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV31+manual',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV31',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV31+fault',
    ),
    SchneiderManualLink(
      modelName: 'Altivar ATV31',
      manualType: 'Parameter Guide',
      url: 'https://www.se.com/ww/en/search/Altivar+ATV31+communication',
    ),
  ];
}
