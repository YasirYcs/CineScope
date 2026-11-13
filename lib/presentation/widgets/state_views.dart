import 'package:flutter/material.dart';

class StateView extends StatelessWidget {
  const StateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon = Icons.refresh_rounded,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData actionIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.08),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Icon(icon, size: 44, color: scheme.primary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
                height: 1.4,
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon, size: 18),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline mode - showing cached results',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.primary.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: scheme.primary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class SkeletonGrid extends StatefulWidget {
  const SkeletonGrid({super.key});

  @override
  State<SkeletonGrid> createState() => _SkeletonGridState();
}

class _SkeletonGridState extends State<SkeletonGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final color = Color.lerp(
          const Color(0xFF161923),
          const Color(0xFF232838),
          _controller.value,
        )!;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 190,
            childAspectRatio: 0.60,
            crossAxisSpacing: 14,
            mainAxisSpacing: 18,
          ),
          itemCount: 8,
          itemBuilder: (context, index) => _SkeletonCard(color: color),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: const Color(0xFF14161F),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ColoredBox(color: color)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    width: 80,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
