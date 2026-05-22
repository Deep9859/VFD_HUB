import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/vfd_provider.dart';
import '../widgets/app_card.dart';

class CommunicationCardScreen extends StatefulWidget {
  const CommunicationCardScreen({super.key});

  @override
  State<CommunicationCardScreen> createState() => _CommunicationCardScreenState();
}

class _CommunicationCardScreenState extends State<CommunicationCardScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<VfdProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectCommCard),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Communication Protocol and Card',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            // Protocol Selection
            AppCard(
              title: 'Protocol',
              subtitle: 'Choose communication protocol',
              accentColor: AppTheme.primary,
              child: DropdownButton<String>(
                value: provider.selectedProtocol?.name,
                hint: const Text('Select Protocol'),
                isExpanded: true,
                items: provider.protocols.map((protocol) {
                  return DropdownMenuItem(
                    value: protocol.name,
                    child: Text(protocol.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final protocol = provider.protocols.firstWhere(
                      (p) => p.name == value,
                    );
                    provider.selectProtocol(protocol);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            // Comm Card Selection
            if (provider.selectedProtocol != null) ...[
              AppCard(
                title: 'Communication Card',
                subtitle: 'Choose card for ${provider.selectedProtocol!.name}',
                accentColor: AppTheme.primary,
                child: DropdownButton<String>(
                  value: provider.selectedCommCard,
                  hint: const Text('Select Card'),
                  isExpanded: true,
                  items: provider.commCardOptions.map((card) {
                    return DropdownMenuItem(
                      value: card,
                      child: Row(
                        children: [
                          Icon(
                            card.startsWith('Built-in')
                                ? Icons.check_circle_outline
                                : Icons.memory,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(card,
                                style: const TextStyle(fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.selectCommCard(value);
                    }
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (provider.selectedCommCard != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Selected: ${provider.selectedCommCard}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}