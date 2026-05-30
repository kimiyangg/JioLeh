import 'package:flutter/material.dart';

import 'package:jio_leh/services/auth_services.dart';
import 'package:jio_leh/services/account_services.dart';
import 'package:jio_leh/models/user_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = AuthServices();
  late final _account = AccountServices(auth: _auth);

  // The loaded profile. Null until it finishes loading.
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await _account.getUserProfile();
    setState(() => _profile = profile);
  }

  @override
  Widget build(BuildContext context) {
    final birthday = _profile?.birthday;
    final birthdayLabel = birthday == null
      ? '-'
      : '${birthday.year}-${birthday.month.toString().padLeft(2, '0')}-${birthday.day.toString().padLeft(2, '0')}';
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _profile == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Profile page',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(_auth.getCurrentUser()?.email ?? 'No email'),
                        Text('Username: ${_profile!.username}'),
                        Text('Display name: ${_profile!.displayName}'),
                        Text('Birthday: $birthdayLabel'),
                      ],
                    ),
            ),
            Positioned(
              left: 16,
              top: 16,
              child: FloatingActionButton(
                onPressed: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
