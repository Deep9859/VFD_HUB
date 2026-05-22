class DanfossManualLink {
  final String modelName;
  final String manualType;
  final String url;

  const DanfossManualLink({
    required this.modelName,
    required this.manualType,
    required this.url,
  });
}

class DanfossManualLinks {
  static const List<DanfossManualLink> all = [
    // Danfoss Model
    DanfossManualLink(
      modelName: 'Danfoss Model',
      manualType: 'User Manual',
      url: '',
    ),
    DanfossManualLink(
      modelName: 'Danfoss Model',
      manualType: 'Troubleshooting Guide',
      url: '',
    ),
    DanfossManualLink(
      modelName: 'Danfoss Model',
      manualType: 'Parameter Guide',
      url: '',
    ),
    // VLT Micro Drive FC51
    DanfossManualLink(
      modelName: 'VLT Micro Drive FC51',
      manualType: 'User Manual',
      url: 'https://pim.galco.com/Manufacturer/Danfoss%20Electronics/TechDocument/Programming%20Manual/driv_ac_fc51_pman.pdf',
    ),
    DanfossManualLink(
      modelName: 'VLT Micro Drive FC51',
      manualType: 'Troubleshooting Guide',
      url: 'https://click2electro.com/danfoss-vlt-micro-drive-fc51-fault-codes-list-2026/',
    ),
    DanfossManualLink(
      modelName: 'VLT Micro Drive FC51',
      manualType: 'Parameter Guide',
      url: 'https://studylib.net/doc/18634895/danfoss-vlt-micro-drive-fc-51-manual',
    ),
    // VLT HVAC Drive FC102
    DanfossManualLink(
      modelName: 'VLT HVAC Drive FC102',
      manualType: 'User Manual',
      url: 'https://assets.danfoss.com/documents/latest/435027/AU430028034214en-011901.pdf',
    ),
    DanfossManualLink(
      modelName: 'VLT HVAC Drive FC102',
      manualType: 'Troubleshooting Guide',
      url: 'https://assets.danfoss.com/documents/latest/435027/AU430028034214en-011901.pdf',
    ),
    DanfossManualLink(
      modelName: 'VLT HVAC Drive FC102',
      manualType: 'Parameter Guide',
      url: 'https://www.tacocomfort.com/documents/FileLibrary/SmartDRIVE_BACnet_Manual.pdf',
    ),
    // VLT Midi Drive FC280
    DanfossManualLink(
      modelName: 'VLT Midi Drive FC280',
      manualType: 'User Manual',
      url: 'https://owre-johnsen.no/media/multicase/documents/programmeringsguide%20-%20danfoss%20vlt%C2%AE%20midi%20drive%20fc%20280.pdf',
    ),
    DanfossManualLink(
      modelName: 'VLT Midi Drive FC280',
      manualType: 'Troubleshooting Guide',
      url: 'https://owre-johnsen.no/media/multicase/documents/programmeringsguide%20-%20danfoss%20vlt%C2%AE%20midi%20drive%20fc%20280.pdf',
    ),
    DanfossManualLink(
      modelName: 'VLT Midi Drive FC280',
      manualType: 'Parameter Guide',
      url: 'https://owre-johnsen.no/media/multicase/documents/programmeringsguide%20-%20danfoss%20vlt%C2%AE%20midi%20drive%20fc%20280.pdf',
    ),
    // VLT Automation Drive FC301 / FC302
    DanfossManualLink(
      modelName: 'VLT Automation Drive FC301 / FC302',
      manualType: 'User Manual',
      url: 'https://files.danfoss.com/download/Drives/DrivesM0013101.pdf',
    ),
    DanfossManualLink(
      modelName: 'VLT Automation Drive FC301 / FC302',
      manualType: 'Troubleshooting Guide',
      url: 'https://click2electro.com/danfoss-vlt-fc302-drive-fault-codes-list-2026/',
    ),
    DanfossManualLink(
      modelName: 'VLT Automation Drive FC301 / FC302',
      manualType: 'Parameter Guide',
      url: 'https://files.danfoss.com/download/Drives/DrivesM0013101.pdf',
    ),
    // VLT Refrigeration Drive FC103
    DanfossManualLink(
      modelName: 'VLT Refrigeration Drive FC103',
      manualType: 'User Manual',
      url: 'https://files.danfoss.com/download/Drives/MG16H102.pdf',
    ),
    DanfossManualLink(
      modelName: 'VLT Refrigeration Drive FC103',
      manualType: 'Troubleshooting Guide',
      url: 'https://files.danfoss.com/download/Drives/MG16H102.pdf',
    ),
    DanfossManualLink(
      modelName: 'VLT Refrigeration Drive FC103',
      manualType: 'Parameter Guide',
      url: 'https://files.danfoss.com/download/Drives/MG16H102.pdf',
    ),
    // VLT Lift Drive LD302
    DanfossManualLink(
      modelName: 'VLT Lift Drive LD302',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/vlt-lift-drive-ld-302/',
    ),
    DanfossManualLink(
      modelName: 'VLT Lift Drive LD302',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/vlt-lift-drive-ld-302/',
    ),
    DanfossManualLink(
      modelName: 'VLT Lift Drive LD302',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VLT Automation Drive FC360
    DanfossManualLink(
      modelName: 'VLT Automation Drive FC360',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/vlt-automationdrive-fc-360/',
    ),
    DanfossManualLink(
      modelName: 'VLT Automation Drive FC360',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/vlt-automationdrive-fc-360/',
    ),
    DanfossManualLink(
      modelName: 'VLT Automation Drive FC360',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VLT AQUA Drive FC202
    DanfossManualLink(
      modelName: 'VLT AQUA Drive FC202',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/vlt-aqua-drive-fc-202/',
    ),
    DanfossManualLink(
      modelName: 'VLT AQUA Drive FC202',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/vlt-aqua-drive-fc-202/',
    ),
    DanfossManualLink(
      modelName: 'VLT AQUA Drive FC202',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VACON 20
    DanfossManualLink(
      modelName: 'VACON 20',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/vacon-20/',
    ),
    DanfossManualLink(
      modelName: 'VACON 20',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/vacon-20/',
    ),
    DanfossManualLink(
      modelName: 'VACON 20',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VACON 20 Cold Plate
    DanfossManualLink(
      modelName: 'VACON 20 Cold Plate',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/vacon-20-cold-plate/',
    ),
    DanfossManualLink(
      modelName: 'VACON 20 Cold Plate',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/vacon-20-cold-plate/',
    ),
    DanfossManualLink(
      modelName: 'VACON 20 Cold Plate',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VACON 100 FLOW
    DanfossManualLink(
      modelName: 'VACON 100 FLOW',
      manualType: 'User Manual',
      url: 'https://files.danfoss.com/download/Drives/VACON-100-FLOW-Application-Guide_DPD01083I-EN.pdf',
    ),
    DanfossManualLink(
      modelName: 'VACON 100 FLOW',
      manualType: 'Troubleshooting Guide',
      url: 'https://files.danfoss.com/download/Drives/VACON-100-FLOW-Application-Guide_DPD01083I-EN.pdf',
    ),
    DanfossManualLink(
      modelName: 'VACON 100 FLOW',
      manualType: 'Parameter Guide',
      url: 'https://drivecentre.ca/wp-content/uploads/2017/03/Vacon-100-Modbus-User-Manual-DPD00156D-UK.pdf',
    ),
    // VACON NXP Air Cooled
    DanfossManualLink(
      modelName: 'VACON NXP Air Cooled',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/vacon-nxp-air-cooled/',
    ),
    DanfossManualLink(
      modelName: 'VACON NXP Air Cooled',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/vacon-nxp-air-cooled/',
    ),
    DanfossManualLink(
      modelName: 'VACON NXP Air Cooled',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VACON 100 INDUSTRIAL
    DanfossManualLink(
      modelName: 'VACON 100 INDUSTRIAL',
      manualType: 'User Manual',
      url: 'https://www.radion.co.il/wp-content/uploads/2017/08/Vacon-100-INDUSTRIAL_X-Application-Manual-DPD00927J-UK.pdf',
    ),
    DanfossManualLink(
      modelName: 'VACON 100 INDUSTRIAL',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.radion.co.il/wp-content/uploads/2017/08/Vacon-100-INDUSTRIAL_X-Application-Manual-DPD00927J-UK.pdf',
    ),
    DanfossManualLink(
      modelName: 'VACON 100 INDUSTRIAL',
      manualType: 'Parameter Guide',
      url: 'https://drivecentre.ca/wp-content/uploads/2017/03/Vacon-100-Modbus-User-Manual-DPD00156D-UK.pdf',
    ),
    // IC7-Automation
    DanfossManualLink(
      modelName: 'IC7-Automation',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/ic7-drives/ic7-automation/',
    ),
    DanfossManualLink(
      modelName: 'IC7-Automation',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/ic7-drives/ic7-automation/',
    ),
    DanfossManualLink(
      modelName: 'IC7-Automation',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // IC2-Micro
    DanfossManualLink(
      modelName: 'IC2-Micro',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/ic2-drives/ic2-micro/',
    ),
    DanfossManualLink(
      modelName: 'IC2-Micro',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/ic2-drives/ic2-micro/',
    ),
    DanfossManualLink(
      modelName: 'IC2-Micro',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VLT 2800
    DanfossManualLink(
      modelName: 'VLT 2800',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/vlt-2800/',
    ),
    DanfossManualLink(
      modelName: 'VLT 2800',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/vlt-2800/',
    ),
    DanfossManualLink(
      modelName: 'VLT 2800',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VLT 3000
    DanfossManualLink(
      modelName: 'VLT 3000',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT 3000',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT 3000',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VLT 3500
    DanfossManualLink(
      modelName: 'VLT 3500',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT 3500',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT 3500',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VLT 5000
    DanfossManualLink(
      modelName: 'VLT 5000',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT 5000',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT 5000',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VLT 6000
    DanfossManualLink(
      modelName: 'VLT 6000',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT 6000',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT 6000',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VLT 8000
    DanfossManualLink(
      modelName: 'VLT 8000',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT 8000',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT 8000',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VACON 10
    DanfossManualLink(
      modelName: 'VACON 10',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/vacon-10/',
    ),
    DanfossManualLink(
      modelName: 'VACON 10',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/vacon-10/',
    ),
    DanfossManualLink(
      modelName: 'VACON 10',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VACON NXL
    DanfossManualLink(
      modelName: 'VACON NXL',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/',
    ),
    DanfossManualLink(
      modelName: 'VACON NXL',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/',
    ),
    DanfossManualLink(
      modelName: 'VACON NXL',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VACON CX
    DanfossManualLink(
      modelName: 'VACON CX',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/',
    ),
    DanfossManualLink(
      modelName: 'VACON CX',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/',
    ),
    DanfossManualLink(
      modelName: 'VACON CX',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VLT Decentral Drive FCD300
    DanfossManualLink(
      modelName: 'VLT Decentral Drive FCD300',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT Decentral Drive FCD300',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT Decentral Drive FCD300',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VLT DriveMotor FCM106
    DanfossManualLink(
      modelName: 'VLT DriveMotor FCM106',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT DriveMotor FCM106',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT DriveMotor FCM106',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VLT DriveMotor FCM300
    DanfossManualLink(
      modelName: 'VLT DriveMotor FCM300',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT DriveMotor FCM300',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT DriveMotor FCM300',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VLT Decentral Drive FCD 302
    DanfossManualLink(
      modelName: 'VLT Decentral Drive FCD 302',
      manualType: 'User Manual',
      url: 'https://files.valinonline.com/userfiles/documents/danfoss-fcd-302-manual.pdf',
    ),
    DanfossManualLink(
      modelName: 'VLT Decentral Drive FCD 302',
      manualType: 'Troubleshooting Guide',
      url: 'https://files.valinonline.com/userfiles/documents/danfoss-fcd-302-manual.pdf',
    ),
    DanfossManualLink(
      modelName: 'VLT Decentral Drive FCD 302',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VLT Drive Motor FCP 106
    DanfossManualLink(
      modelName: 'VLT Drive Motor FCP 106',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT Drive Motor FCP 106',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vlt-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT Drive Motor FCP 106',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VLT Decentral Servo Drive DSD 510
    DanfossManualLink(
      modelName: 'VLT Decentral Servo Drive DSD 510',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT Decentral Servo Drive DSD 510',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/',
    ),
    DanfossManualLink(
      modelName: 'VLT Decentral Servo Drive DSD 510',
      manualType: 'Parameter Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/accessories/option-cards/',
    ),
    // VACON 20X
    DanfossManualLink(
      modelName: 'VACON 20X',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/vacon-20-x/',
    ),
    DanfossManualLink(
      modelName: 'VACON 20X',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/vacon-20-x/',
    ),
    DanfossManualLink(
      modelName: 'VACON 20X',
      manualType: 'Parameter Guide',
      url: 'https://drivecentre.ca/wp-content/uploads/2017/03/Vacon-100-Modbus-User-Manual-DPD00156D-UK.pdf',
    ),
    // VACON 100X
    DanfossManualLink(
      modelName: 'VACON 100X',
      manualType: 'User Manual',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/vacon-100-x/',
    ),
    DanfossManualLink(
      modelName: 'VACON 100X',
      manualType: 'Troubleshooting Guide',
      url: 'https://www.danfoss.com/en/products/dds/low-voltage-drives/vacon-drives/vacon-100-x/',
    ),
    DanfossManualLink(
      modelName: 'VACON 100X',
      manualType: 'Parameter Guide',
      url: 'https://drivecentre.ca/wp-content/uploads/2017/03/Vacon-100-Modbus-User-Manual-DPD00156D-UK.pdf',
    ),
  ];
}