import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'logging_service.dart';

class VFDWidgetData {
  final String vendorName;
  final String modelName;
  final String powerRating;
  final DateTime lastAccessed;
  final String? configName;

  VFDWidgetData({
    required this.vendorName,
    required this.modelName,
    required this.powerRating,
    required this.lastAccessed,
    this.configName,
  });

  Map<String, dynamic> toJson() => {
    'vendorName': vendorName,
    'modelName': modelName,
    'powerRating': powerRating,
    'lastAccessed': lastAccessed.toIso8601String(),
    'configName': configName,
  };

  factory VFDWidgetData.fromJson(Map<String, dynamic> json) => VFDWidgetData(
    vendorName: json['vendorName'],
    modelName: json['modelName'],
    powerRating: json['powerRating'],
    lastAccessed: DateTime.parse(json['lastAccessed']),
    configName: json['configName'],
  );
}

class HomeScreenWidgetService {
  static const _channel = MethodChannel('com.vfdapp.vfd_param_app/widget');

  static Future<void> saveWidgetData(VFDWidgetData data) async {
    try {
      await _channel.invokeMethod('updateWidget', data.toJson());
    } catch (_) {
      // Platform channel not available on all platforms - silently ignore
    }
    LoggingService.info('Widget data saved: ${data.vendorName} - ${data.modelName}', tag: 'WIDGET');
  }

  static Future<List<VFDWidgetData>> getRecentConfigs() async {
    return [];
  }

  static Future<void> updateWidget() async {
    try {
      await _channel.invokeMethod('updateWidget');
    } catch (_) {}
    LoggingService.info('Widget update triggered', tag: 'WIDGET');
  }

  static Future<void> clearWidget() async {
    try {
      await _channel.invokeMethod('clearWidget');
    } catch (_) {}
    LoggingService.info('Widget data cleared', tag: 'WIDGET');
  }
}

// Widget Preview (for in-app display)
class VFDWidgetPreview extends StatelessWidget {
  final VFDWidgetData data;

  const VFDWidgetPreview({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_input_component, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'VFD Hub',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.configName ?? 'Recent Configuration',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            '${data.vendorName} ${data.modelName}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.powerRating,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tap to open',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              const Icon(Icons.arrow_forward, color: Colors.white70, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget Configuration Screen
class WidgetConfigScreen extends StatelessWidget {
  const WidgetConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen Widget')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Widget Preview', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  FutureBuilder<List<VFDWidgetData>>(
                    future: HomeScreenWidgetService.getRecentConfigs(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text('No recent configurations');
                      }
                      return VFDWidgetPreview(data: snapshot.data!.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_to_home_screen),
              title: const Text('Add Widget to Home Screen'),
              subtitle: const Text('Long press on home screen to add widget'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Long press on home screen to add VFD Hub widget')),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Update Widget'),
              subtitle: const Text('Refresh widget with latest data'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () async {
                await HomeScreenWidgetService.updateWidget();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Widget updated!')),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Clear Widget'),
              subtitle: const Text('Remove widget data'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () async {
                await HomeScreenWidgetService.clearWidget();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Widget cleared!')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
