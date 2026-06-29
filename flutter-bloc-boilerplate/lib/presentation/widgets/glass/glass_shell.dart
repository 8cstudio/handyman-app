import 'package:flutter/material.dart';
import 'package:my_bloc_app/presentation/widgets/glass/liquid_background.dart';

class GlassShell extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final bool extendBody;

  const GlassShell({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.bottomNavigationBar,
    this.extendBody = true,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: extendBody,
        resizeToAvoidBottomInset: true,
        appBar: appBar,
        drawer: drawer,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}
