import 'package:flutter/material.dart';

class StaffStatsRow extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final int followersCount;

  const StaffStatsRow({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.followersCount,
  });

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          icon: Icons.star,
          iconColor: Colors.amber,
          value: rating.toStringAsFixed(1),
          label: 'Rating',
        ),
        const SizedBox(height: 40, child: VerticalDivider(thickness: 1)),
        _StatItem(
          value: _formatCount(reviewCount),
          label: 'Reviews',
        ),
        const SizedBox(height: 40, child: VerticalDivider(thickness: 1)),
        _StatItem(
          value: _formatCount(followersCount),
          label: 'Followers',
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String value;
  final String label;

  const _StatItem({
    this.icon,
    this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
