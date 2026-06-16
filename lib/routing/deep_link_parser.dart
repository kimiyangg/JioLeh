String? profileIdFromDeepLink(Uri uri) {
  final validLink =
      uri.scheme == 'com.gijios.jioleh' &&
      uri.host == 'profile' &&
      uri.pathSegments.length == 1;

  return validLink ? uri.pathSegments.first : null;
}
