import 'package:flutter/material.dart';

import '../../domain/recipe.dart';

/// Network image tuned for scrolling lists:
/// - the server resizes the picture to the rendered width (fewer bytes),
/// - `cacheWidth` makes the engine decode at display size (less memory, no
///   decode jank on the raster thread),
/// - it is only requested when built, i.e. when the lazy list scrolls it in,
/// - a placeholder keeps the layout stable while loading or on error.
class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.recipe,
    this.semanticLabel,
    this.heroTag,
  });

  final Recipe recipe;
  final String? semanticLabel;
  final Object? heroTag;

  /// Widths are bucketed so the same picture reuses the same cache entry.
  static int bucketWidth(double logicalWidth, double pixelRatio) {
    final physical = (logicalWidth * pixelRatio).ceil();
    const buckets = [200, 400, 600, 800, 1080];
    for (final b in buckets) {
      if (physical <= b) return b;
    }
    return buckets.last;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.restaurant, color: scheme.onSurfaceVariant),
      ),
    );

    final image = LayoutBuilder(
      builder: (context, constraints) {
        final width = bucketWidth(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 400,
          MediaQuery.devicePixelRatioOf(context),
        );
        return Image.network(
          recipe.imageUrlForWidth(width),
          cacheWidth: width,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          semanticLabel: semanticLabel,
          excludeFromSemantics: semanticLabel == null,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: child,
            );
          },
          errorBuilder: (_, _, _) => placeholder,
        );
      },
    );

    final stacked = Stack(fit: StackFit.expand, children: [placeholder, image]);
    return heroTag == null ? stacked : Hero(tag: heroTag!, child: stacked);
  }
}
