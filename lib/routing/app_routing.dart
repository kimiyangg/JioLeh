import "package:jio_leh/models/user_profile.dart";
import "package:jio_leh/pages/profile/profile_edit_page.dart";
import "package:jio_leh/pages/profile/profile_page.dart";
import "package:flutter/material.dart";
import "package:jio_leh/pages/profile/share_code_page.dart";

class AppRoutes {
  static Route<void> profile(String userId) {
    // in dart, _ means unused parameter, it should write context but since its not used so _
    // cuz building a root doesn't need context, only Navigator.push need context
    return MaterialPageRoute(builder: (_) => ProfilePage(userId: userId));
  }
  
  // Returns Route<UserProfile?>
  // Need to return back UserProfile after successful update while returning null if users returns
  static Route<UserProfile?> profileEdit(UserProfile profile) {
    return MaterialPageRoute(builder: (_) => ProfileEditPage(profile: profile));
  }

  static Route<void> shareCode(UserProfile profile) {
    return MaterialPageRoute(builder: (_) => ShareCodePage(profile: profile));
  }

}
