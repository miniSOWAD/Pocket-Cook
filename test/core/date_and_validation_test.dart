import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/core/utils/date_formatter.dart';
import 'package:recipe_app/core/utils/input_validators.dart';
void main() {
  test('weeks start on Monday', () => expect(weekStart(DateTime(2026, 9, 13)), DateTime(2026, 9, 7)));
  test('calendar addition crosses the year boundary', () => expect(dateKey(addCalendarDays(DateTime(2026, 12, 31), 1)), '2027-01-01'));
  test('dates roundtrip without UTC conversion', () => expect(parseDateKey('2026-09-09'), DateTime(2026, 9, 9)));
  test('invalid calendar dates are rejected', () => expect(() => parseDateKey('2026-02-30'), throwsFormatException));
  test('email validation rejects incomplete addresses', () {
    expect(InputValidators.email('person@example.com'), isNull);
    expect(InputValidators.email('person'), isNotNull); expect(InputValidators.email('a b@example.com'), isNotNull);
  });
  test('quantities must be positive and finite', () {
    expect(InputValidators.quantity('1.5'), isNull); expect(InputValidators.quantity('0'), isNotNull);
    expect(InputValidators.quantity('NaN'), isNotNull); expect(InputValidators.quantity('Infinity'), isNotNull);
  });
}
