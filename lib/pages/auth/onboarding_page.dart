import 'package:flutter/material.dart';

import 'package:jio_leh/services/services.dart';
import 'package:jio_leh/theme.dart';

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
    setState(() => _submitting = true);
    try {
      await _account.createProfile(
        displayName: _displayNameController.text.trim(),
        birthday: _buildBirthday(),
      );
      // Tell AuthGate to re-check; it will route on to the MapPage.
      await widget.onComplete?.call();
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
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              SizedBox(height: 10),
              SizedBox(
                width: 375,
                child: LinearProgressIndicator(
                  value: 0.5,
                  minHeight: 6,
                  color: AppColors.lightWidgetBackground,
                  backgroundColor: AppColors.darkWidgetBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("👋", style: TextStyle(fontSize: 40)),
                      SizedBox(height: 8),
                      Text(
                        "Welcome! Let's set you up",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "This is how friends will see in your profile.",
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.onboardingSubtitle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.darkWidgetBackground,
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "USER ID · NOT AVAILABLE",
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.onboardingSubtitle,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        width: 350,
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
                          ]
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Pls don't enter anything yet",
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        "YOUR NAME",
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.onboardingSubtitle,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        width: 350,
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
                          ]
                        ),
                        child: TextField(
                          controller: _displayNameController,
                          decoration: InputDecoration(
                            hintText: "What should we call you?",
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Text(
                        "BIRTHDAY · OPTIONAL",
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.onboardingSubtitle,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 70,
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
                              ]
                            ),
                            child: TextField(
                              controller: _dayController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "DD",
                                hintStyle: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 150,
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
                              ]
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButton<String>(
                                value: _selectedMonth,
                                hint: Text(
                                  "Month",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                isExpanded: true,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold
                                ),
                                dropdownColor: AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(18),
                                items: _months.map((String month) {
                                  return DropdownMenuItem<String>(
                                    value: month,
                                    child: Text(month),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedMonth = newValue;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 100,
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
                              ]
                            ),
                            child: TextField(
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "YYYY",
                                hintStyle: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                    ],
                  ),
                )
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
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Start exploring'),
                    ),
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
