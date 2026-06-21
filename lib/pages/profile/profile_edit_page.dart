import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/util/birthday.dart';
import 'package:jio_leh/widgets/app_field_box.dart';
import 'package:jio_leh/widgets/app_page_header.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';
import 'package:jio_leh/widgets/app_section_label.dart';
import 'package:jio_leh/widgets/app_snack_bar.dart';
import 'package:jio_leh/widgets/app_text_field.dart';
import 'package:jio_leh/widgets/birthday_row.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _dayController;
  late final TextEditingController _yearController;
  String? _selectedMonth;
  bool _saving = false;

  
  final _imagePicker = ImagePicker();
  XFile? _avatarFile;

  @override
  void initState() {
    super.initState();
    final birthday = widget.profile.birthday;

    _displayNameController = TextEditingController(
      text: widget.profile.displayName,
    );
    _bioController = TextEditingController(text: widget.profile.bio ?? '');
    _dayController = TextEditingController(
      text: birthday == null ? '' : birthday.day.toString(),
    );
    _yearController = TextEditingController(
      text: birthday == null ? '' : birthday.year.toString(),
    );
    _selectedMonth = birthday == null ? null : kMonthNames[birthday.month - 1];
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

    Future<void> _pickAvatar() async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 80,
    );

    if (photo != null && mounted) {
      setState(() => _avatarFile = photo);
    }
  }

  /// Preview shown inside the photo box: a circular avatar of the freshly-picked
  /// image if there is one, otherwise the saved avatar, otherwise a placeholder.
  Widget _buildAvatarPreview() {
    final avatarFile = _avatarFile;
    final existingUrl = widget.profile.avatarUrl;

    final ImageProvider? image;
    if (avatarFile != null) {
      image = FileImage(File(avatarFile.path));
    } else if (existingUrl != null && existingUrl.isNotEmpty) {
      image = NetworkImage(existingUrl);
    } else {
      image = null;
    }

    return Center(
      child: CircleAvatar(
        radius: 50,
        backgroundColor: AppColors.darkWidgetBackground,
        foregroundImage: image,
        child: image == null
            ? const Icon(Icons.add_a_photo, color: Colors.white)
            : null,
      ),
    );
  }

  Future<void> _saveProfile() async {
    final displayName = _displayNameController.text.trim();
    final bio = _bioController.text.trim();

    if (displayName.isEmpty) {
      context.showAppSnackBar(
        'Display name cannot be empty.',
        kind: SnackBarKind.error,
      );
      return;
    }

    DateTime? birthday;
    try {
      birthday = parseBirthday(
        day: _dayController.text,
        year: _yearController.text,
        month: _selectedMonth,
      );
    } on FormatException catch (error) {
      context.showAppSnackBar(error.message, kind: SnackBarKind.error);
      return;
    }

    // Read the service from the provider before the first await (context is
    // valid here because this runs from a button tap after build).
    final account = ServiceProvider.of(context)!.account;

    setState(() => _saving = true);
    try {
      final updatedProfile = await account.updateProfile(
        displayName: displayName,
        bio: bio.isEmpty ? null : bio,
        birthday: birthday,
        avatarFile: _avatarFile,
      );

      if (mounted) {
        Navigator.pop(context, updatedProfile);
      }
    } catch (error) {
      if (mounted) {
        context.showAppSnackBar(
          'Could not save profile: $error',
          kind: SnackBarKind.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppPageHeader(title: "Edit Profile"),
                    const SizedBox(height: 5),
                    const AppSectionLabel(text: "PROFILE PHOTO"),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _saving ? null : _pickAvatar,
                      child: AppFieldBox(
                        height: AppFieldHeights.photo,
                        child: _buildAvatarPreview(),
                      ),
                    ),     
                    const SizedBox(height: 20),
                    const AppSectionLabel(text: "DISPLAY NAME"),
                    const SizedBox(height: 10),
                    AppTextField(
                      controller: _displayNameController,
                      hintText: "What should we call you?",
                    ),
                    const SizedBox(height: 20),
                    const AppSectionLabel(text: "BIO"),
                    const SizedBox(height: 10),
                    AppTextField(
                      controller: _bioController,
                      hintText: "Tell friends a little about you",
                      height: 110,
                      maxLines: null,
                    ),
                    const SizedBox(height: 20),
                    const AppSectionLabel(text: "BIRTHDAY"),
                    const SizedBox(height: 10),
                    BirthdayRow(
                      dayController: _dayController,
                      yearController: _yearController,
                      selectedMonth: _selectedMonth,
                      onMonthChanged: (value) =>
                          setState(() => _selectedMonth = value),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.dangerShadow,
                          borderRadius: BorderRadius.circular(AppRadii.elements),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.dangerShadow,
                              blurRadius: 0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: 46,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.elements),
                              ),
                              elevation: 0,
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onPressed: () {},
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.delete, size: 18),
                                SizedBox(width: 8),
                                Text('Delete account'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: AppPrimaryButton(
                        label: 'All saved',
                        icon: Icons.check,
                        isLoading: _saving,
                        onPressed: _saveProfile,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
