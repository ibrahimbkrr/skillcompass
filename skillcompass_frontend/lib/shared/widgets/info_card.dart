import 'package:flutter/material.dart';

/// Ortak bilgi kartı widget'ı. Hem tekli hem çoklu değerler için kullanılabilir.
class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final String? value;
  final List<String>? values;
  final Widget? customContent;
  final Color? iconColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.value,
    this.values,
    this.customContent,
    this.iconColor,
  }) : assert(value != null || values != null || customContent != null, 'En az bir içerik tipi verilmelidir.');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (iconColor ?? theme.colorScheme.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (customContent != null) ...[
              customContent!,
            ] else if (values != null) ...[
              ...values!.isNotEmpty
                  ? values!.map((v) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          v,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ))
                  : [
                      Text(
                        'Belirtilmemiş',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
            ] else if (value != null) ...[
              Text(
                value!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: value == 'Belirtilmemiş'
                      ? theme.colorScheme.onSurface.withOpacity(0.5)
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 