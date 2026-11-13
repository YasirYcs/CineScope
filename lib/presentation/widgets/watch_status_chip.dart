import 'package:flutter/material.dart';

import '../../data/models/saved_show.dart';

class WatchStatusChip extends StatelessWidget {
  const WatchStatusChip({super.key, required this.status});

  final WatchStatus status;

  Color get _color {
    switch (status) {
      case WatchStatus.planToWatch:
        return const Color(0xFF64B5F6);
      case WatchStatus.watching:
        return const Color(0xFF66BB6A);
      case WatchStatus.completed:
        return const Color(0xFFFFC857);
      case WatchStatus.dropped:
        return const Color(0xFFEF5350);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
