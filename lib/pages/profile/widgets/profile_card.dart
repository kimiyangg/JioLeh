import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/util/birthday.dart';
import 'package:jio_leh/widgets/app_secondary_button.dart';

/// Organism — the profile card: avatar + name/username, bio, birthday, and
/// either the owner actions (Edit / Share) or the Add-Friend button.
///
/// A dumb widget: it takes the [profile] and callbacks; the page owns the state
/// and navigation.
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.isOwnProfile,
    required this.onEdit,
    required this.onShare,
    required this.isSendingRequest,
    required this.requestSent,
    required this.onAddFriend,
  });

  final UserProfile? profile;
  final bool isOwnProfile;
  final VoidCallback? onEdit;
  final VoidCallback? onShare;
  final bool isSendingRequest;
  final bool requestSent;
  final VoidCallback? onAddFriend;

  @override
  Widget build(BuildContext context) {
    final nameSize = context.scaledFont(AppTextSizes.button);
    final labelSize = context.scaledFont(AppTextSizes.label);

    final avatarUrl = profile?.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.elements),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.darkWidgetBackground,
                  foregroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                  child: hasAvatar
                      ? null
                      : const Icon(Icons.person, color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.displayName ?? "",
                        style: TextStyle(
                          fontSize: nameSize,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text("@${profile?.username ?? ""}"),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.bio ?? UserProfile.defaultBio,
                    style: TextStyle(fontSize: labelSize),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.cake, size: 15),
                      const SizedBox(width: 10),
                      Text(formatBirthday(profile?.birthday)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            if (isOwnProfile)
              Row(
                children: [
                  Expanded(
                    child: AppSecondaryButton(
                      label: "Edit Profile",
                      icon: Icons.edit,
                      backgroundColor: AppColors.darkButton,
                      onPressed: onEdit,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: AppSecondaryButton(
                      label: "Share Code",
                      icon: Icons.share,
                      onPressed: onShare,
                    ),
                  ),
                ],
              )
            else if (!isOwnProfile && profile != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        isSendingRequest || requestSent ? null : onAddFriend,
                    icon: isSendingRequest
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(requestSent ? Icons.check : Icons.person_add),
                    label: Text(
                      requestSent
                          ? 'Friend Request Sent'
                          : isSendingRequest
                              ? 'Sending...'
                              : 'Add as Friend',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
