import 'package:flutter/material.dart';

import 'package:jio_leh/theme.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}

// TODO: Containing way too much params and overcomplicated
// shld change method of feeding params or seperate to smaller widgets
// Kimi 2026/06/09
class ProfileForm extends StatelessWidget {
  const ProfileForm({
    super.key,
    required this.displayNameController,
    required this.dayController,
    required this.yearController,
    required this.selectedMonth,
    required this.months,
    required this.onMonthChanged,
  });

  final TextEditingController displayNameController;
  final TextEditingController dayController;
  final TextEditingController yearController;
  final String? selectedMonth;
  final List<String> months;
  final ValueChanged<String?> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                controller: displayNameController,
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
                    controller: dayController,
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
                      value: selectedMonth,
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
                      items: months.map((String month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                      onChanged: onMonthChanged,
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
                    controller: yearController,
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
      ),
    );
  }
}
