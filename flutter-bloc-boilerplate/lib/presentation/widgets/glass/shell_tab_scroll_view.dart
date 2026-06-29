import 'package:flutter/material.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_style.dart';

/// Scrollable body for tabs rendered inside [GlassShell] with a floating nav bar.
class ShellTabScrollView extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ShellTabScrollView({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final base = padding ?? GlassStyle.shellTabPadding(context);
    final resolved = base.resolve(Directionality.of(context));
    final scrollPadding = EdgeInsets.fromLTRB(
      resolved.left,
      resolved.top,
      resolved.right,
      resolved.bottom + viewInsets.bottom,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: scrollPadding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight -
                  scrollPadding.top -
                  scrollPadding.bottom,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
