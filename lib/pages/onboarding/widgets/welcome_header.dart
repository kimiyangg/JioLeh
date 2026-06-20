import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final onBoardingTitleSize = context.scaledFont(AppTextSizes.onboardingHeading);
    final subtitleSize = context.scaledFont(AppTextSizes.subtitle);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.fromLTRB(30, 30, 30, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👋", style: TextStyle(fontSize: 40)),
            SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "Welcome! Let's set you up",
                maxLines: 1,
                style: TextStyle(
                  fontSize: onBoardingTitleSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "This is how friends will see in your profile.",
                maxLines: 1,
                style: TextStyle(
                  fontSize: subtitleSize,
                  color: AppColors.lightSubtitle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
