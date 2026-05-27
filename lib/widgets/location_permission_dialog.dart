import 'package:flutter/material.dart';
import 'package:jio_leh/services/location_services.dart';

String _locationErrorMessage(Object? error) {
  if (error is LocationServiceOff) {
    return 'Location services are turned off. Please enable them and try again.';
  }
  if (error is LocationBlocked) {
    return 'Location permission was permanently denied. Open settings to grant access.';
  }
  if (error is LocationDenied) {
    return 'Location permission is required to use the map.';
  }
  return 'Unable to fetch your location. Please try again.';
}

Future<void> showLocationErrorDialog({
  required BuildContext context,
  required Object error,
  required LocationServices locationService,
  required VoidCallback onRetry,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(Icons.location_off, size: 40, color: Colors.grey),
      title: const Text('Location unavailable'),
      content: Text(_locationErrorMessage(error)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancel'),
        ),
        if (error is LocationServiceOff)
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              locationService.openLocationSettings();
            },
            child: const Text('Open location settings'),
          ),
        if (error is LocationBlocked)
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              locationService.openAppSettings();
            },
            child: const Text('Open app settings'),
          ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            onRetry();
          },
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
