// import

// Future<Map<String, dynamic>?> getUserProfile() async {
//   // Retrieves the current user's profile information from the 'profiles' table in the database.
//   final userId = getCurrentUserId();

//   final profile = await _supabase
//       .from('profiles')
//       .select()
//       .eq('id', userId)
//       .maybeSingle();

//   if (profile == null) {
//     throw StateError('Profile not found for user ID: $userId');
//   }

//   return profile;
// }