import 'package:flutter/material.dart';

import '../classification/classifier.dart';
import '../classification/category.dart';

class ClassificationTestScreen extends StatefulWidget {
  const ClassificationTestScreen({super.key});

  @override
  State<ClassificationTestScreen> createState() =>
      _ClassificationTestScreenState();
}

class _ClassificationTestScreenState extends State<ClassificationTestScreen> {
  final controller = TextEditingController();
  ClassificationResult? result;
  CategoryId? userOverride;

  @override
  Widget build(BuildContext context) {
    final shown = userOverride ?? result?.category;

    return Scaffold(
      appBar: AppBar(title: const Text("Classification MVP (EN)")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Input",
                hintText: "watching ted talks for 1 hour",
              ),
              onChanged: (_) {
                final r = Classifier.classifyEn(controller.text);
                setState(() {
                  result = r;
                  userOverride = null;
                });
              },
            ),
            const SizedBox(height: 12),
            if (result != null) ...[
              Row(
                children: [
                  const Text("Category chip: "),
                  const SizedBox(width: 8),
                  DropdownButton<CategoryId>(
                    value: shown,
                    hint: const Text("Select"),
                    items: kCategories
                        .map((m) => DropdownMenuItem(
                              value: m.id,
                              child: Text(m.label),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => userOverride = v),
                  ),
                  const SizedBox(width: 12),
                  Text("conf: ${(result!.confidence * 100).round()}%"),
                ],
              ),
              const SizedBox(height: 8),
              Text("Suggested: ${_label(result!.category)}"),
              if (userOverride != null)
                Text("User override: ${_label(userOverride!)}"),
              const SizedBox(height: 16),
              const Text("Quick tests:"),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _pill("watching ted talks for 1 hour"),
                  _pill("watching netflix for 1 hour"),
                  _pill("clean the shower"),
                  _pill("take a shower"),
                  _pill("1 hour violin practice"),
                  _pill("gym workout 45 min"),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        controller.text = text;
        final r = Classifier.classifyEn(text);
        setState(() {
          result = r;
          userOverride = null;
        });
      },
    );
  }

  String _label(CategoryId id) =>
      kCategories.firstWhere((e) => e.id == id).label;
}
