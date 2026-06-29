import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_bloc_app/core/theme/theme_context.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_style.dart';

class GlassBottomBar extends StatelessWidget {
  final Widget child;

  const GlassBottomBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GlassStyle.radiusXl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: GlassStyle.glassFill(context),
              borderRadius: BorderRadius.circular(GlassStyle.radiusXl),
              border: Border.all(color: GlassStyle.glassBorder(context), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: context.isDarkMode ? 0.28 : 0.08,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: Colors.transparent,
                indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                elevation: 0,
                height: 68,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
