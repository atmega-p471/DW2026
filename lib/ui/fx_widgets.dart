import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Светлый минималистичный фон в стиле референса
class MoneyFlowBackground extends StatelessWidget {
  const MoneyFlowBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
            Color(0xFFE2E8F0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// Карточка-герой: белая с мягкой тенью, как на референсе
class GradientHeroCard extends StatelessWidget {
  const GradientHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.gradientColors,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final isAccent = gradientColors != null;
    final trailingWidget = trailing;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isAccent ? null : Colors.white,
        gradient: isAccent
            ? LinearGradient(
                colors: gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0x05000000),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isAccent ? Colors.white : const Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isAccent
                        ? Colors.white.withValues(alpha: 0.9)
                        : const Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (trailingWidget case final widget?) widget,
        ],
      ),
    );
  }
}

/// Метрика: белая карточка с мягкой тенью
class AnimatedMetricPill extends StatelessWidget {
  const AnimatedMetricPill({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.suffix = '',
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0, end: value.toDouble()),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${animated.round()}$suffix',
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Прогресс-бар: мягкий, минималистичный
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    required this.height,
    this.gradientColors,
  });

  final double value;
  final double height;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final fillColor = gradientColors?.first ?? const Color(0xFF0D9488);
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      tween: Tween(begin: 0, end: value.clamp(0, 1)),
      builder: (context, animated, _) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: const Color(0xFFE2E8F0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      width: constraints.maxWidth * animated,
                      decoration: BoxDecoration(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

Widget staggerChild(Widget child, {int index = 0}) {
  return child
      .animate()
      .fadeIn(duration: 400.ms, delay: (index * 50).ms)
      .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
}

Future<void> showActionFxDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  required bool positive,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierLabel: 'fx',
    barrierColor: Colors.black.withValues(alpha: 0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _ActionFxView(
        title: title,
        subtitle: subtitle,
        positive: positive,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: curved, child: child),
      );
    },
  );
}

class _ActionFxView extends StatefulWidget {
  const _ActionFxView({
    required this.title,
    required this.subtitle,
    required this.positive,
  });

  final String title;
  final String subtitle;
  final bool positive;

  @override
  State<_ActionFxView> createState() => _ActionFxViewState();
}

class _ActionFxViewState extends State<_ActionFxView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.positive
        ? const Color(0xFF0D9488)
        : const Color(0xFFDC2626);
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final pulse = 1 + sin(_controller.value * pi * 2) * 0.04;
                  return Transform.scale(
                    scale: pulse,
                    child: Icon(
                      widget.positive
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      size: 48,
                      color: color,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
