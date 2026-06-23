import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_field_box.dart';
import 'package:jio_leh/widgets/app_page_header.dart';
import 'package:jio_leh/widgets/app_snack_bar.dart';

import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ShareCodePage extends StatelessWidget {
  final UserProfile profile;

  const ShareCodePage({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    // Build the deep link the QR encodes and the share button sends: com.gijios.jioleh://profile/<id>.
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
                      AppFieldBox(
                        height: 290,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: QrImageView(
                            data: profileLink,
                            version: QrVersions.auto,
                            size: 250,
                            backgroundColor: Colors.white,
                            semanticsLabel:
                                '${profile.displayName} profile QR code',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Scan to view this profile'),
                      const SizedBox(height: 30),
                      AppPrimaryButton(
                        icon: Icons.share,
                        label: "Share my code",
                        onPressed: () async {
                          // Capture this button's rect so the iPad share popover has an anchor (phones ignore it).
                          final box = context.findRenderObject() as RenderBox?;
                          // Open the OS share sheet with the profile link.
                          try {
                            final result = await SharePlus.instance.share(
                              ShareParams(
                                text: profileLink,
                                sharePositionOrigin: box == null
                                    ? null
                                    : box.localToGlobal(Offset.zero) & box.size,
                              ),
                            );
                            debugPrint('Share status: ${result.status}');
                          } catch (error, stack) {
                            debugPrint('Share failed: $error\n$stack');
                          }
                        },
                      ),
                      SizedBox(height: 16,),
                      AppPrimaryButton(
                        backgroundColor: Colors.grey,
                        label: "Copy Link",
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: profileLink));
                          if (context.mounted) {
                            context.showAppSnackBar(
                              "Link Copied",
                              kind: SnackBarKind.success,
                            );
                          }
                        },
                      )
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