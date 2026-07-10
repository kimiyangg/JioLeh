import 'package:flutter_test/flutter_test.dart';

import 'package:jio_leh/models/point_transaction.dart';

void main() {
  test('point values match the product spec', () {
    expect(PointReason.pinCreated.points, 2);
    expect(PointReason.photoUploaded.points, 3);
    expect(PointReason.jioCreated.points, 5);
  });
}