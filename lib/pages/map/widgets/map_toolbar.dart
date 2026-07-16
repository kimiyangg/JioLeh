import 'package:flutter/material.dart';

class MapToolbar extends StatelessWidget {
  const MapToolbar({
    super.key,
    required this.onRecenter,
    required this.onSuggestions,
    required this.onToggleFog,
    required this.fogEnabled,
  });

  final VoidCallback onRecenter;
  final VoidCallback onSuggestions;
  final VoidCallback onToggleFog;
  final bool fogEnabled;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'fog',
            onPressed: onToggleFog,
            backgroundColor: Colors.white,
            child: Icon(
              fogEnabled ? Icons.cloud : Icons.cloud_off,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'suggestions',
            onPressed: onSuggestions,
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.thumb_up,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'recenter',
            onPressed: onRecenter,
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.my_location,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
