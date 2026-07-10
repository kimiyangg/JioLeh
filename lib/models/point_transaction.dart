// Reasons a user can earn points, and how many points each is worth.
// matching `point_transactions.reason` check constraint value in the
// database. The enum name and dbValue differ in case, so keep dbValue in
// sync with the migration if either changes.
enum PointReason {
  pinCreated(2, 'pin_created'),
  photoUploaded(1, 'photo_uploaded'),
  jioCreated(5, 'jio_created');

  const PointReason(this.points, this.dbValue);

  final int points;
  final String dbValue;
}
