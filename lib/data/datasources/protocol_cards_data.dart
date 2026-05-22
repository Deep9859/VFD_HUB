// Protocol and Communication Card Data for VFD Models

class CommCard {
  final String name;
  final String description;
  final bool isLegacy;
  
  const CommCard({
    required this.name,
    required this.description,
    this.isLegacy = false,
  });
}

class ProtocolSupport {
  final String protocolName;
  final List<CommCard> cards;
  
  const ProtocolSupport({
    required this.protocolName,
    required this.cards,
  });
}

class ProtocolCardsData {
  // ABB ACS580 Example
  static const Map<String, Map<String, List<ProtocolSupport>>> modelProtocols = {
    'ABB': {
      'ACS580': [
        ProtocolSupport(
          protocolName: 'Modbus RTU',
          cards: [
            CommCard(name: 'Built-in RS-485', description: 'Standard Modbus RTU'),
          ],
        ),
        ProtocolSupport(
          protocolName: 'Modbus TCP',
          cards: [
            CommCard(name: 'FENA-21', description: 'Ethernet/IP + Modbus TCP'),
            CommCard(name: 'FENA-11', description: 'Ethernet Adapter', isLegacy: true),
          ],
        ),
        ProtocolSupport(
          protocolName: 'Profibus DP',
          cards: [
            CommCard(name: 'FPBA-01', description: 'Profibus DP Adapter'),
            CommCard(name: 'FPNO-01', description: 'Profibus DP (Old)', isLegacy: true),
          ],
        ),
        ProtocolSupport(
          protocolName: 'EtherNet/IP',
          cards: [
            CommCard(name: 'FENA-21', description: 'Ethernet/IP + Modbus TCP'),
          ],
        ),
        ProtocolSupport(
          protocolName: 'DeviceNet',
          cards: [
            CommCard(name: 'FDNA-01', description: 'DeviceNet Adapter'),
          ],
        ),
      ],
      'ACS880': [
        ProtocolSupport(
          protocolName: 'Modbus RTU',
          cards: [
            CommCard(name: 'Built-in RS-485', description: 'Standard Modbus RTU'),
          ],
        ),
        ProtocolSupport(
          protocolName: 'Modbus TCP',
          cards: [
            CommCard(name: 'FENA-21', description: 'Ethernet/IP + Modbus TCP'),
          ],
        ),
        ProtocolSupport(
          protocolName: 'Profibus DP',
          cards: [
            CommCard(name: 'FPBA-01', description: 'Profibus DP Adapter'),
          ],
        ),
        ProtocolSupport(
          protocolName: 'Profinet',
          cards: [
            CommCard(name: 'FENA-21', description: 'Profinet IO'),
          ],
        ),
      ],
    },
    'Delta': {
      'VFD-E': [
        ProtocolSupport(
          protocolName: 'Modbus RTU',
          cards: [
            CommCard(name: 'Built-in RS-485', description: 'Standard Modbus RTU'),
          ],
        ),
        ProtocolSupport(
          protocolName: 'Modbus TCP',
          cards: [
            CommCard(name: 'DVP-ENET', description: 'Ethernet Module'),
          ],
        ),
        ProtocolSupport(
          protocolName: 'CANopen',
          cards: [
            CommCard(name: 'DVP-CAN', description: 'CANopen Module'),
          ],
        ),
      ],
      'C2000': [
        ProtocolSupport(
          protocolName: 'Modbus RTU',
          cards: [
            CommCard(name: 'Built-in RS-485', description: 'Standard Modbus RTU'),
          ],
        ),
        ProtocolSupport(
          protocolName: 'Modbus TCP',
          cards: [
            CommCard(name: 'DMCNET-01', description: 'Ethernet Module'),
          ],
        ),
        ProtocolSupport(
          protocolName: 'Profibus DP',
          cards: [
            CommCard(name: 'DMPB-01', description: 'Profibus DP Module'),
          ],
        ),
        ProtocolSupport(
          protocolName: 'DeviceNet',
          cards: [
            CommCard(name: 'DMDN-01', description: 'DeviceNet Module'),
          ],
        ),
      ],
    },
    'Siemens': {
      'SINAMICS G120': [
        ProtocolSupport(
          protocolName: 'Profibus DP',
          cards: [
            CommCard(name: 'CU250S-2 PN', description: 'Profibus DP Built-in'),
          ],
        ),
        ProtocolSupport(
          protocolName: 'Profinet',
          cards: [
            CommCard(name: 'CU250S-2 PN', description: 'Profinet IO Built-in'),
          ],
        ),
        ProtocolSupport(
          protocolName: 'EtherNet/IP',
          cards: [
            CommCard(name: 'CU250S-2 DP/PN', description: 'EtherNet/IP Option'),
          ],
        ),
      ],
    },
  };

  // Get protocols for a specific vendor and model
  static List<ProtocolSupport> getProtocolsForModel(String vendor, String model) {
    return modelProtocols[vendor]?[model] ?? [];
  }

  // Get all protocol names for a model
  static List<String> getProtocolNames(String vendor, String model) {
    final protocols = getProtocolsForModel(vendor, model);
    return protocols.map((p) => p.protocolName).toList();
  }

  // Get communication cards for a specific protocol
  static List<CommCard> getCardsForProtocol(String vendor, String model, String protocol) {
    final protocols = getProtocolsForModel(vendor, model);
    final protocolSupport = protocols.firstWhere(
      (p) => p.protocolName == protocol,
      orElse: () => const ProtocolSupport(protocolName: '', cards: []),
    );
    return protocolSupport.cards;
  }
}
