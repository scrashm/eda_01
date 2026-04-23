import 'package:flutter/material.dart';

class DishImageCard extends StatelessWidget {
  const DishImageCard({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    this.aspectRatio = 4 / 5,
    this.borderRadius = 24,
    this.maxHeight = 280,
  });

  final String imageUrl;
  final String heroTag;
  final double aspectRatio;
  final double borderRadius;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
          ),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Container(
              color: const Color(0xFFE8ECE8),
              child: imageUrl.isEmpty
                  ? const SizedBox.shrink()
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) {
                          return child;
                        }
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                      errorBuilder: (_, __, ___) {
                        return const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE9F0EC), Color(0xFFF5EFE7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(Icons.image_outlined, size: 38),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
