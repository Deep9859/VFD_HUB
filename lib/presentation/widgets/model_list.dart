import 'package:flutter/material.dart';

import '../../data/models/vfd_model.dart';

class ModelList extends StatelessWidget {
  final List<VfdModel> models;
  final Function(VfdModel) onModelTap;

  const ModelList({super.key, required this.models, required this.onModelTap});

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) {
      return const Center(
        child: Text('No models found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: models.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.memory, color: Colors.blue.shade700),
            ),
            title: Text(
              models[index].name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(models[index].series),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.electric_bolt,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('${models[index].powerRating} kW'),
                    const SizedBox(width: 16),
                    Icon(Icons.power, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(models[index].voltage),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onModelTap(models[index]),
          ),
        );
      },
    );
  }
}
