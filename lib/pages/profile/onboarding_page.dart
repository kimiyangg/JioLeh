import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/pages/profile/username_rule.dart';
import 'package:jio_leh/services/account_service.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/util/birthday.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';

import 'onboarding_widgets.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.onComplete});

  // Called after the profile row is successfully created, so AuthGate can
  // re-check and route the user on to the MapPage.
  final Future<void> Function()? onComplete;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final AuthService _auth;
  late final AccountService _account;
  bool _didInit = false;

  final _imagePicker = ImagePicker();
  XFile? _profilePhoto;

  Future<void> _pickProfilePhoto() async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 80,
    );

    if (photo != null && mounted) {
      setState(() => _profilePhoto = photo);
    }
  }

  late final TextEditingController _displayNameController;
  final _usernameController = TextEditingController();
  final _dayController = TextEditingController();
  final _yearController = TextEditingController();
  String? _selectedMonth;
  bool _submitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Services come from the provider, which can't be read in initState. Do the
    // one-time setup here (didChangeDependencies can fire more than once).
    if (_didInit) return;
    _didInit = true;

    final services = ServiceProvider.of(context)!;
    _auth = services.auth;
    _account = services.account;

    // Prefill the display name with the name Google gave us.
    final metadata = _auth.getCurrentUser()?.userMetadata;
    final googleName =
        metadata?['full_name'] as String? ?? metadata?['name'] as String?;
    _displayNameController = TextEditingController(text: googleName ?? '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Authoritative client-side rule lives in UsernameRule.
    final username = _usernameController.text.trim().toLowerCase();
    if (!UsernameRule.isValid(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(UsernameRule.errorMessage)),
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

    setState(() => _submitting = true);
    try {
      await _account.createProfile(
        username: username,
        displayName: _displayNameController.text.trim(),
        birthday: birthday,
        profilePhoto: _profilePhoto,
      );
      // Tell AuthGate to re-check; it will route on to the MapPage.
      await widget.onComplete?.call();
    } on UsernameTaken {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('That username is taken — try another.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save profile: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
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
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: LinearProgressIndicator(
                              value: 0.5,
                              minHeight: 6,
                              color: AppColors.lightWidgetBackground,
                              backgroundColor: AppColors.darkWidgetBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        WelcomeHeader(),
                        // Profile photo picker
                        SizedBox( 
                          width: double.infinity,
                          child: Center(
                            child: GestureDetector(
                              onTap: _submitting ? null : _pickProfilePhoto,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.darkWidgetBackground,
                                foregroundImage: _profilePhoto == null 
                                    ? null
                                    : FileImage(File(_profilePhoto!.path)),
                                child: _profilePhoto == null
                                    ? const Icon(Icons.add_a_photo, color: Colors.white)
                                    : null,
                              ),
                          ),
                          ),
                        ),
                        ProfileForm(
                          usernameController: _usernameController,
                          displayNameController: _displayNameController,
                          dayController: _dayController,
                          yearController: _yearController,
                          selectedMonth: _selectedMonth,
                          onMonthChanged: (value) =>
                              setState(() => _selectedMonth = value),
                        ),

                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
                          child: AppPrimaryButton(
                            label: 'Start exploring',
                            icon: Icons.check,
                            isLoading: _submitting,
                            onPressed: _submit,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
