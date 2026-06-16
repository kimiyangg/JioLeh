import "package:jio_leh/pages/profile_page.dart";
import "package:flutter/material.dart";

class AppRoutes {
  static Route<void> profile(String userId) {
    return MaterialPageRoute(builder: (_) => ProfilePage(userId: userId));
  }
}
