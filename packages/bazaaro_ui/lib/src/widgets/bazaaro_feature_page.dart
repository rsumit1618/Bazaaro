import 'package:flutter/material.dart';

class BazaaroFeaturePage extends StatelessWidget {
  const BazaaroFeaturePage({
    super.key,
    required this.title,
    required this.child,
    this.maxWidth = 980,
    this.padding = const EdgeInsets.all(16),
    this.actions,
  });

  final String title;
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: padding,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
