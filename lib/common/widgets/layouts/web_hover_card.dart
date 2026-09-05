import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebHoverCard extends StatefulWidget {
  const WebHoverCard({
    super.key,
    required this.child,
    this.lift = 6,
    this.scale = 1.02,
    this.glowColor,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 280),
  });

  final Widget child;
  final double lift;
  final double scale;
  final Color? glowColor;
  final BorderRadius? borderRadius;
  final Duration duration;

  @override
  State<WebHoverCard> createState() => _WebHoverCardState();
}

class _WebHoverCardState extends State<WebHoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;

    final effectiveGlow = widget.glowColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFFD4AF37).withValues(alpha: 0.18)
            : const Color(0xFFD4AF37).withValues(alpha: 0.12));

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, _hovered ? -widget.lift : 0.0)
          ..scale(_hovered ? widget.scale : 1.0),
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: effectiveGlow,
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: widget.child,
      ),
    );
  }
}
