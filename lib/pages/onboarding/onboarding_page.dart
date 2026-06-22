import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jio_leh/util/username_rule.dart';
import 'package:jio_leh/services/account_service.dart';
import 'package:jio_leh/services/auth_service.dart';
import 'package:jio_leh/app/service_provider.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/util/birthday.dart';
import 'package:jio_leh/widgets/app_avatar.dart';
import 'package:jio_leh/widgets/app_primary_button.dart';
import 'package:jio_leh/widgets/app_snack_bar.dart';

import 'widgets/welcome_header.dart';
import 'widgets/profile_form.dart';

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
  XFile? _avatarFile;

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
    final googleName = _auth.getCurrentUserName();
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
      context.showAppSnackBar(UsernameRule.errorMessage, kind: SnackBarKind.error);
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

    setState(() => _submitting = true);
    try {
      await _account.createProfile(
        username: username,
        displayName: _displayNameController.text.trim(),
        birthday: birthday,
        avatarFile: _avatarFile,
      );
      // Tell AuthGate to re-check; it will route on to the MapPage.
      await widget.onComplete?.call();
    } on UsernameTaken {
      if (mounted) {
        context.showAppSnackBar(
          'That username is taken — try another.',
          kind: SnackBarKind.error,
        );
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
                            child: AppAvatar(
                              radius: 50,
                              image: _avatarFile == null
                                  ? null
                                  : FileImage(File(_avatarFile!.path)),
                              onTap: _submitting ? null : _pickAvatar,
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
