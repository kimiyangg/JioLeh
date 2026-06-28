String? profileIdFromDeepLink(Uri uri) {
  final fromCustomScheme =
      uri.scheme == 'com.gijios.jioleh' &&
      uri.host == 'profile' &&
      uri.pathSegments.length == 1;
  if (fromCustomScheme) return uri.pathSegments.first;

  final fromUniversalLink =
      uri.scheme == 'https' &&
      uri.host == 'jio-leh-website.vercel.app' &&
      uri.pathSegments.length == 2 &&
      uri.pathSegments.first == 'profile';
  if (fromUniversalLink) return uri.pathSegments[1];

  return null;
}
