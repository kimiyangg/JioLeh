import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/models/point_transaction.dart';

void main() {
  test('point values match the product spec', () {
    expect(PointReason.pinCreated.points, 2);
    expect(PointReason.photoUploaded.points, 1);
    expect(PointReason.jioCreated.points, 5);
  });

  test('dbValue matches the point_transactions reason check constraint', () {
    expect(PointReason.pinCreated.dbValue, 'pin_created');
    expect(PointReason.photoUploaded.dbValue, 'photo_uploaded');
    expect(PointReason.jioCreated.dbValue, 'jio_created');
  });
}