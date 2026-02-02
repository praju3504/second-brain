import 'package:flutter/material.dart';

/// Inline chip widget for rendered wiki links
class LinkChip extends StatelessWidget {
  final String linkText;
  final bool exists;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const LinkChip({
    super.key,
    required this.linkText,
    required this.exists,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final color = exists
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              exists ? Icons.link : Icons.link_off,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              linkText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
