import 'package:flutter/material.dart';

class TechnicalProfileMultiSelector extends StatelessWidget {
  final List<String> options;
  final List<String> selectedValues;
  final Function(String) onChanged;
  final bool isSaving;
  const TechnicalProfileMultiSelector({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option);
        return FilterChip(
          label: Text(
            option,
            style: TextStyle(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (isSaving) return;
            onChanged(option);
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          checkmarkColor: Theme.of(context).colorScheme.primary,
        );
      }).toList(),
    );
  }
} 