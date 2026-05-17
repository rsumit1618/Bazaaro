import 'package:flutter/widgets.dart';

enum BazaaroBreakpoint { compact, medium, expanded }

class Responsive extends StatelessWidget {
  const Responsive({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final Widget compact;
  final Widget? medium;
  final Widget? expanded;

  static BazaaroBreakpoint breakpointOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1024) return BazaaroBreakpoint.expanded;
    if (width >= 720) return BazaaroBreakpoint.medium;
    return BazaaroBreakpoint.compact;
  }

  static int gridColumns(BuildContext context) {
    return switch (breakpointOf(context)) {
      BazaaroBreakpoint.compact => 2,
      BazaaroBreakpoint.medium => 3,
      BazaaroBreakpoint.expanded => 5,
    };
  }

  @override
  Widget build(BuildContext context) {
    return switch (breakpointOf(context)) {
      BazaaroBreakpoint.expanded => expanded ?? medium ?? compact,
      BazaaroBreakpoint.medium => medium ?? compact,
      BazaaroBreakpoint.compact => compact,
    };
  }
}
