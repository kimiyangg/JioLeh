import 'package:flutter/material.dart';

import 'package:jio_leh/models/user_profile.dart';

import 'package:jio_leh/services/services.dart';

import "package:jio_leh/theme.dart";

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = Services.auth;
  late final _account = Services.account;

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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: AppTextSizes.heading,
                      fontWeight: FontWeight(1000),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: AppColors.darkWidgetBackground,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Kimi Yang",
                                            style: TextStyle(
                                              fontSize: AppTextSizes.button,
                                              fontWeight: FontWeight.w900
                                            ),
                                          ),
                                          Text("@12345678")
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Always hunting the best wanton mee in SG. Will jio you for 11pm supper, no questions asked 🍜",
                                        style: TextStyle(
                                          fontSize: AppTextSizes.label
                                        ),
                                      ),
                                      SizedBox(height: 15,),
                                      Row(
                                        children: [
                                          Icon(Icons.cake, size: 15,),
                                          SizedBox(width: 10,),
                                          Text("Born 14 Jun"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF211D18),
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: const Color(0xFF211D18),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      onPressed: null,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 5,),
                                          Text(
                                            "Edit Profile",
                                            style: TextStyle(
                                              fontSize: AppTextSizes.button,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            AppColors.lightWidgetBackground,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: AppColors.lightWidgetBackground,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      onPressed: null,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.share,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 5,),
                                          Text(
                                            "Share Code",
                                            style: TextStyle(
                                              fontSize: AppTextSizes.button,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white
                                            ),
                                          ),
                                        ],
                                      )
                                    )
                                  ],
                                )
                              ],
                            ),
                          ],
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
    );
  }
}
