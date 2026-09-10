import 'dart:async';
import '../../../../core/state/async_notifier.dart';
import '../../../recipes/models/recipe.dart';
import '../../../recipes/models/recipe_step.dart';
import '../../data/cooking_repository.dart';
import '../../logic/cooking_timer.dart';
class CookingProvider extends AsyncNotifier {
  CookingProvider(this.repository, this.recipe, this.userScope, int initialServings)
      : servings = initialServings {
    try {
      final saved = repository.read(userScope, recipe.id);
      if (saved != null && recipe.steps.isNotEmpty &&
          saved['completed'] != true && saved['servings'] == initialServings) {
        index = (saved['index'] as num? ?? 0).toInt().clamp(0, recipe.steps.length - 1).toInt();
        servings = (saved['servings'] as num? ?? initialServings).toInt().clamp(1, 12).toInt();
        completed = saved['completed'] as bool? ?? false;
        timer.restore(Map<String, dynamic>.from(saved['timer'] as Map? ?? {}));
      }
    } catch (error) { reportError(error); }
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => notify());
  }
  final CookingRepository repository;
  final Recipe recipe;
  final String userScope;
  final CookingTimer timer = CookingTimer();
  late final Timer _ticker;
  int servings, index = 0;
  bool completed = false;
  RecipeStep get step => recipe.steps[index];
  double get progress => completed ? 1 : (index + 1) / recipe.steps.length;
  String get clock {
    final seconds = (timer.remaining.inMilliseconds / 1000).ceil();
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }
  Future<void> _save() => repository.save(userScope, recipe.id,
    {'index': index, 'servings': servings, 'completed': completed, 'timer': timer.toJson()});
  Future<bool> startTimer() => run(() async {
    timer.start(Duration(seconds: step.timerSeconds));
    await _save();
  });
  Future<bool> pauseTimer() => run(() async { timer.pause(); await _save(); });
  Future<bool> resumeTimer() => run(() async { timer.resume(); await _save(); });
  Future<bool> resetTimer() => run(() async { timer.reset(); await _save(); });
  Future<bool> next() => run(() async {
    timer.reset();
    if (index + 1 < recipe.steps.length) { index++; } else { completed = true; }
    await _save();
  });
  Future<bool> previous() => run(() async {
    if (index == 0) return;
    timer.reset(); index--; completed = false; await _save();
  });
  Future<bool> restart() => run(() async { index = 0; completed = false; timer.reset(); await _save(); });
  @override
  void dispose() { _ticker.cancel(); super.dispose(); }
}
