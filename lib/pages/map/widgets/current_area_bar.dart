import 'package:flutter/material.dart';

class CurrentAreaBar extends StatelessWidget {
  const CurrentAreaBar({super.key, required this.locationName});

  final String locationName;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 60,
      top: 10,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color.fromARGB(255, 10, 250, 186),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  locationName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}