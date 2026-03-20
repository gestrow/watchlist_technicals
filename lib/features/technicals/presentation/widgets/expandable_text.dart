import 'package:flutter/material.dart';

/// A text widget that clamps to [maxLines] with a "Show more / Show less" toggle.
///
/// Usage:
/// ```dart
/// ExpandableText(
///   text: overview.description,
///   maxLines: 3,
///   style: theme.textTheme.bodySmall,
/// )
/// ```
class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;

  const ExpandableText({
    super.key,
    required this.text,
    this.maxLines = 3,
    this.style,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final linkStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w500,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.text,
          style: widget.style,
          maxLines: _expanded ? null : widget.maxLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        // Only show toggle if text might overflow — use LayoutBuilder to check.
        _OverflowDetector(
          text: widget.text,
          style: widget.style,
          maxLines: widget.maxLines,
          child: GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _expanded ? 'Show less' : 'Show more',
                style: linkStyle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Renders [child] only when [text] actually overflows [maxLines].
class _OverflowDetector extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final Widget child;

  const _OverflowDetector({
    required this.text,
    required this.style,
    required this.maxLines,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: text, style: style);
        final tp = TextPainter(
          text: span,
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        return tp.didExceedMaxLines ? child : const SizedBox.shrink();
      },
    );
  }
}
