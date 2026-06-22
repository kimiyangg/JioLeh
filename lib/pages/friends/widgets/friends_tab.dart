import 'package:flutter/material.dart';
import 'package:jio_leh/theme.dart';
import 'package:jio_leh/widgets/app_avatar.dart';
import 'package:jio_leh/widgets/app_field_box.dart';

class FriendsTab extends StatelessWidget {
  const FriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: AppFieldBox(
        height: 65,
        child: Row(
          children: [
            SizedBox(width: 20,),
            AppAvatar(
              radius: 20,
              placeholder: Icons.person,
            ),
            SizedBox(width: 20,),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kimi Yang",
                  style: TextStyle(
                    fontSize: AppTextSizes.body,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Text("@kimi")
              ],
            ),
          ],
        ),
      ),
    );
  }
}