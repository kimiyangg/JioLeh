import 'package:flutter/material.dart';

import 'package:jio_leh/services/services.dart';
import 'package:jio_leh/services/account_service.dart';
import 'package:jio_leh/theme.dart';

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
  final _auth = Services.auth;
  late final _account = Services.account;

  late final TextEditingController _displayNameController;
  final _usernameController = TextEditingController();
  final _dayController = TextEditingController();
  final _yearController = TextEditingController();
  String? _selectedMonth;
  bool _submitting = false;

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

  // Builds a DateTime from the day / month / year inputs. Returns null if any
  // part is missing or invalid, since birthday is optional.
  DateTime? _buildBirthday() {
    final day = int.tryParse(_dayController.text.trim());
    final year = int.tryParse(_yearController.text.trim());
    final monthIndex = _selectedMonth == null
        ? -1
        : _months.indexOf(_selectedMonth!);
    if (day == null || year == null || monthIndex < 0) {
      return null;
    }
    return DateTime(year, monthIndex + 1, day);
  }

  Future<void> _submit() async {
    // Authoritative client-side rule: 3–10 lowercase letters or digits.
    final username = _usernameController.text.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9]{3,10}$').hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username must be 3–10 letters or digits.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await _account.createProfile(
        username: username,
        displayName: _displayNameController.text.trim(),
        birthday: _buildBirthday(),
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
                        SizedBox(
                          width: double.infinity,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: AppColors.darkWidgetBackground,
                          ),
                        ),
                        ProfileForm(
                          usernameController: _usernameController,
                          displayNameController: _displayNameController,
                          dayController: _dayController,
                          yearController: _yearController,
                          selectedMonth: _selectedMonth,
                          months: _months,
                          onMonthChanged: (value) =>
                              setState(() => _selectedMonth = value),
                        ),

                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
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
                                  backgroundColor:
                                      AppColors.lightWidgetBackground,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: const Color(
                                    0xFF4B443B,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                onPressed: _submitting ? null : _submit,
                                child: _submitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check, size: 20),
                                        SizedBox(width: 8),
                                        Text('Start exploring'),
                                      ],
                                    ),
                              ),
                            ),
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
