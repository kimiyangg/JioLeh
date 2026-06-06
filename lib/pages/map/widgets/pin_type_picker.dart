import 'package:flutter/material.dart';
import 'package:jio_leh/pages/map/models/pin_type.dart';

Future<PinType?> showPinTypePicker(BuildContext context) async {
  // ? means may return null, or the selected option
  return showModalBottomSheet<PinType>(
    // shows bottom sheet,
    // PinType mean can only return 1 pin type
    context: context,
    showDragHandle: true, // drag handle on top of sheet
    builder: (context) {
      return SafeArea(
        child: SizedBox(
          height:
              MediaQuery.sizeOf(context).height *
              0.5, // makes sheet half screen ht
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Choose location type',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2, // 2 column button grid
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.4,
                    children: [
                      for (final option in PinType.values)
                        // loops through restaurant, ...
                        FilledButton(
                          // one button per option
                          onPressed: () => Navigator.pop(context, option),
                          child: Text(
                            '${option.emoji} ${option.label}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}