import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/repositories/show_repository.dart';
import 'home_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.showRepository,
    required this.collectionRepository,
  });

  final ShowRepository showRepository;
  final CollectionRepository collectionRepository;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.86,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _timer = Timer(AppConstants.splashDuration, _openHome);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _openHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) => HomeShell(
          showRepository: widget.showRepository,
          collectionRepository: widget.collectionRepository,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF171208), AppTheme.background, Color(0xFF0A0F1B)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -130,
              right: -90,
              child: _GlowOrb(
                color: primary.withValues(alpha: 0.22),
                size: 340,
              ),
            ),
            Positioned(
              bottom: -160,
              left: -120,
              child: _GlowOrb(
                color: const Color(0xFF5C6BC0).withValues(alpha: 0.18),
                size: 400,
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.35),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.45),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.20),
                              blurRadius: 48,
                              spreadRadius: 6,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.movie_filter_rounded,
                          size: 78,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Cine',
                              style: TextStyle(color: primary),
                            ),
                            const TextSpan(text: 'Scope'),
                          ],
                        ),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        AppConstants.tagline,
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 96,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: const LinearProgressIndicator(
                            minHeight: 2,
                            backgroundColor: Color(0x1FFFFFFF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        AppConstants.apiAttribution,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white24,
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
