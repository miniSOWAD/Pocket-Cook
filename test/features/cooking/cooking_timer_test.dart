import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_cook/features/cooking/logic/cooking_timer.dart';
void main() {
  late DateTime now;
  late CookingTimer timer;
  setUp(() { now = DateTime(2026, 9, 9, 12); timer = CookingTimer(now: () => now); });
  test('counts down from a deadline', () {
    timer.start(const Duration(seconds: 60)); now = now.add(const Duration(seconds: 15));
    expect(timer.remaining, const Duration(seconds: 45)); expect(timer.running, isTrue);
  });
  test('pause prevents time from elapsing', () {
    timer.start(const Duration(seconds: 60)); now = now.add(const Duration(seconds: 10)); timer.pause();
    now = now.add(const Duration(minutes: 5)); expect(timer.remaining, const Duration(seconds: 50)); expect(timer.paused, isTrue);
  });
  test('resume uses the paused remaining time', () {
    timer.start(const Duration(seconds: 60)); now = now.add(const Duration(seconds: 10)); timer.pause();
    now = now.add(const Duration(minutes: 5)); timer.resume(); now = now.add(const Duration(seconds: 20));
    expect(timer.remaining, const Duration(seconds: 30));
  });
  test('restoration detects a timer that expired while the app was closed', () {
    timer.start(const Duration(seconds: 60)); final saved = timer.toJson();
    now = now.add(const Duration(minutes: 2));
    final restored = CookingTimer(now: () => now)..restore(saved);
    expect(restored.finished, isTrue); expect(restored.remaining, Duration.zero);
  });
  test('reset clears completion and running state', () {
    timer.start(const Duration(seconds: 60)); timer.reset();
    expect(timer.hasStarted, isFalse); expect(timer.finished, isFalse); expect(timer.running, isFalse);
  });
  test('rejects zero and excessive durations', () {
    expect(() => timer.start(Duration.zero), throwsArgumentError);
    expect(() => timer.start(const Duration(days: 2)), throwsArgumentError);
  });
}
