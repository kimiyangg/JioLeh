// Reasons a user can earn points, and how many points each is worth.
// The `name` for each case matches the `point_transactions.reason` check
// constraint in the database — keep them in sync.
enum PointReason {
  pinCreated(2),
  photoUploaded(3),
  jioCreated(5);

  const PointReason(this.points);

  final int points;
}
