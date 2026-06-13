import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:jio_leh/models/user_profile.dart';
import 'package:jio_leh/services/services.dart';
import 'package:jio_leh/theme.dart';

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

  static const _months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

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
    _selectedMonth = birthday == null ? null : _months[birthday.month - 1];
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  DateTime? _buildBirthday() {
    final dayText = _dayController.text.trim();
    final yearText = _yearController.text.trim();
    final hasBirthdayInput =
        dayText.isNotEmpty || yearText.isNotEmpty || _selectedMonth != null;

    if (!hasBirthdayInput) return null;

    final day = int.tryParse(dayText);
    final year = int.tryParse(yearText);
    final monthIndex = _selectedMonth == null
        ? -1
        : _months.indexOf(_selectedMonth!);

    if (day == null || year == null || monthIndex < 0) {
      throw const FormatException('Enter a full birthday or leave it empty.');
    }

    final birthday = DateTime(year, monthIndex + 1, day);
    if (birthday.year != year ||
        birthday.month != monthIndex + 1 ||
        birthday.day != day) {
      throw const FormatException('Enter a valid birthday.');
    }

    return birthday;
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
      birthday = _buildBirthday();
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
    final titleSize = context.scaledFont(AppTextSizes.heading);
    final labelSize = context.scaledFont(AppTextSizes.label);
    final fieldSize = context.scaledFont(AppTextSizes.body);
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
                            fontSize: titleSize + 2,
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
                    Text(
                      "PROFILE PHOTO",
                      style: TextStyle(
                        fontSize: labelSize,
                        color: AppColors.onboardingSubtitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                    Text(
                      "DISPLAY NAME",
                      style: TextStyle(
                        fontSize: labelSize,
                        color: AppColors.onboardingSubtitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F1E1B16),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _displayNameController,
                          decoration: InputDecoration(
                            hintText: "What should we call you?",
                            hintStyle: TextStyle(
                              fontSize: fieldSize,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "BIO",
                      style: TextStyle(
                        fontSize: labelSize,
                        color: AppColors.onboardingSubtitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        width: double.infinity,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0F1E1B16),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _bioController,
                          maxLines: null,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            hintText: "Tell friends a little about you",
                            hintStyle: TextStyle(
                              fontSize: fieldSize,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "BIRTHDAY",
                      style: TextStyle(
                        fontSize: labelSize,
                        color: AppColors.onboardingSubtitle,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0F1E1B16),
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _dayController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              decoration: InputDecoration(
                                hintText: "DD",
                                hintStyle: TextStyle(
                                  fontSize: fieldSize,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 4,
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0F1E1B16),
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: DropdownButton<String>(
                                value: _selectedMonth,
                                hint: Text(
                                  "Month",
                                  style: TextStyle(
                                    fontSize: fieldSize,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                isExpanded: true,
                                style: TextStyle(
                                  fontSize: fieldSize,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                dropdownColor: AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(18),
                                items: _months.map((String month) {
                                  return DropdownMenuItem<String>(
                                    value: month,
                                    child: Text(
                                      month,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) =>
                                    setState(() => _selectedMonth = value),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0F1E1B16),
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              decoration: InputDecoration(
                                hintText: "YYYY",
                                hintStyle: TextStyle(
                                  fontSize: fieldSize,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF9E2F24),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF9E2F24),
                              blurRadius: 0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          height: 46,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFD84B3A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: LogoColors.forestLogo,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: LogoColors.forestLogo,
                              blurRadius: 0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.lightWidgetBackground,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF4B443B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onPressed: _saving ? null : _saveProfile,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_saving) ...[
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ] else ...[
                                  const Icon(Icons.check, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('All saved'),
                                ],
                              ],
                            ),
                          ),
                        ),
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
