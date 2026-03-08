import 'package:flutter/widgets.dart';

import '../core/sdui_context.dart';
import '../models/sdui_node.dart';

/// Builds a network [Image] widget.
///
/// Supported props:
/// - `url` (String) — image URL
/// - `aspect_ratio` (num) — if provided, wraps the image in an [AspectRatio]
/// - `corner_radius` (num) — clips with rounded corners
/// - `width` (num)
/// - `height` (num)
/// - `fit` (String) — "cover", "contain", "fill", etc.
Widget imageBuilder(SduiNode node, SduiContext context) {
  final url = node.props['url'] as String? ?? '';
  final aspectRatio = (node.props['aspect_ratio'] as num?)?.toDouble();
  final cornerRadius =
      (node.props['corner_radius'] as num?)?.toDouble() ?? 0;
  final fit = _parseBoxFit(node.props['fit'] as String?);

  Widget image = Image.network(
    url,
    fit: fit,
    errorBuilder: (_, error, stackTrace) => const SizedBox.shrink(),
  );

  if (cornerRadius > 0) {
    image = ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: image,
    );
  }

  if (aspectRatio != null) {
    image = AspectRatio(aspectRatio: aspectRatio, child: image);
  }

  return image;
}

BoxFit _parseBoxFit(String? value) {
  return switch (value) {
    'cover' => BoxFit.cover,
    'contain' => BoxFit.contain,
    'fill' => BoxFit.fill,
    'fitWidth' => BoxFit.fitWidth,
    'fitHeight' => BoxFit.fitHeight,
    'none' => BoxFit.none,
    _ => BoxFit.cover,
  };
}
