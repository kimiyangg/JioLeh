import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_page_header.dart';

class ShareCodePage extends StatelessWidget {
  final UserProfile profile;

  const ShareCodePage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final profileLink = Uri(
      scheme: 'com.gijios.jioleh',
      host: 'profile',
      pathSegments: [profile.id],
    ).toString();

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(title: 'Share Profile'),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.displayName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('@${profile.username}'),
                      const SizedBox(height: 24),
                      QrImageView(
                        data: profileLink,
                        version: QrVersions.auto,
                        size: 250,
                        backgroundColor: Colors.white,
                        semanticsLabel: '${profile.displayName} profile QR code',
                      ),
                      const SizedBox(height: 16),
                      const Text('Scan to view this profile'),
                    ],
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