
import 'package:flutter/material.dart';

class HoverImage extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const HoverImage({
    required this.imagePath,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  State<HoverImage> createState() => _HoverImageState();
}

class _HoverImageState extends State<HoverImage> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: isHovered ? 1.0 : 0.7,
          child: Image.asset(
            widget.imagePath,
            width: widget.width,
            height: widget.height,
          ),
        ),
      ),
    );
  }
}