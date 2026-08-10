import 'package:flutter/material.dart';

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isCompact = screenWidth < 600;

    return Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: isCompact ? 16 : 24,
            vertical: isCompact ? 12 : 20,
          ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isCompact ? screenWidth : 900),
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  const ResponsiveRow({super.key, required this.children, this.spacing = 12.0});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children:
            children
                .expand((child) => [child, const SizedBox(height: 12)])
                .toList()
              ..removeLast(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children
          .asMap()
          .entries
          .map((entry) => Expanded(child: entry.value))
          .toList(),
    );
  }
}
