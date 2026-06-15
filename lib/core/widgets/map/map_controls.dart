import 'package:flutter/material.dart';

import '../buttons/glass_floating_button.dart';

/// Vertical cluster of glass map controls (layers, my-location, zoom).
/// Render only the buttons whose callbacks are provided.
class MapControls extends StatelessWidget {
  final VoidCallback? onMyLocation;
  final VoidCallback? onLayers;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;

  const MapControls({
    super.key,
    this.onMyLocation,
    this.onLayers,
    this.onZoomIn,
    this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onLayers != null) ...[
          GlassFloatingButton(icon: Icons.layers, onPressed: onLayers),
          const SizedBox(height: 12),
        ],
        if (onZoomIn != null || onZoomOut != null) ...[
          GlassFloatingButton(icon: Icons.add, onPressed: onZoomIn, size: 48),
          const SizedBox(height: 8),
          GlassFloatingButton(
              icon: Icons.remove, onPressed: onZoomOut, size: 48),
          const SizedBox(height: 12),
        ],
        if (onMyLocation != null)
          GlassFloatingButton(icon: Icons.my_location, onPressed: onMyLocation),
      ],
    );
  }
}
