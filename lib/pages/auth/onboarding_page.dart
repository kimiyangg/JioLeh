import 'package:flutter/material.dart';

import 'package:jio_leh/services/services.dart';

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

  final _usernameController = TextEditingController();
  late final TextEditingController _displayNameController;
  DateTime? _birthday;
  bool _submitting = false;

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
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthday = picked);
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await _account.createProfile(
        username: _usernameController.text.trim(),
        displayName: _displayNameController.text.trim(),
        birthday: _birthday,
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
    final birthdayLabel = _birthday == null
        ? 'Pick your birthday'
        : '${_birthday!.year}-${_birthday!.month}-${_birthday!.day}';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Set up your profile',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _submitting ? null : _pickBirthday,
                child: Text(birthdayLabel),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
