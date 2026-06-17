import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/services/services.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/util/birthday.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';
import 'package:jio_leh/widgets/app_section_label.dart';
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

  Future<void> _saveProfile() async {
    final displayName = _displayNameController.text.trim();
    final bio = _bioController.text.trim();

    if (displayName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Display name cannot be empty.')),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }

    setState(() => _saving = true);
    try {
      final updatedProfile = await Services.account.updateProfile(
        displayName: displayName,
        bio: bio.isEmpty ? null : bio,
        birthday: birthday,
      );

      if (mounted) {
        Navigator.pop(context, updatedProfile);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save profile: $error')),
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
    final titleSize = context.scaledFont(AppTextSizes.heading) + 2;
    final labelSize = context.scaledFont(AppTextSizes.label);
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
                    Row(
                      children: [
                        Text(
                          "Edit Profile",
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 100),
                        FilledButton(
                          onPressed: () => Navigator.maybePop(context),
                          child: const Text("Back"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const AppSectionLabel("PROFILE PHOTO"),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadii.elements),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.camera_alt, size: 40),
                              Text(
                                "Add a photo",
                                style: TextStyle(fontSize: labelSize),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const AppSectionLabel("DISPLAY NAME"),
                    const SizedBox(height: 10),
                    AppTextField(
                      controller: _displayNameController,
                      hintText: "What should we call you?",
                    ),
                    const SizedBox(height: 20),
                    const AppSectionLabel("BIO"),
                    const SizedBox(height: 10),
                    AppTextField(
                      controller: _bioController,
                      hintText: "Tell friends a little about you",
                      height: 110,
                      maxLines: null,
                    ),
                    const SizedBox(height: 20),
                    const AppSectionLabel("BIRTHDAY"),
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
