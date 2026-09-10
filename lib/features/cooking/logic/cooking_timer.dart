/// Wall-clock deadlines survive suspended Dart execution. No OS alarm is
/// scheduled; this timer updates when the app is foregrounded again.
class CookingTimer {
  CookingTimer({DateTime Function()? now}) : _now = now ?? DateTime.now;
  final DateTime Function() _now;
  DateTime? _deadline;
  int _pausedMillis = 0;
  int _totalMillis = 0;
  bool get hasStarted => _totalMillis > 0;
  Duration get remaining {
    final milliseconds = _deadline?.difference(_now()).inMilliseconds ?? _pausedMillis;
    return Duration(milliseconds: milliseconds.clamp(0, _totalMillis).toInt());
  }
  bool get running => _deadline != null && remaining > Duration.zero;
  bool get finished => hasStarted && remaining == Duration.zero;
  bool get paused => hasStarted && _deadline == null && _pausedMillis > 0;
  void start(Duration duration) {
    if (duration <= Duration.zero || duration > const Duration(hours: 24)) throw ArgumentError('Invalid timer duration');
    _totalMillis = duration.inMilliseconds;
    _pausedMillis = 0;
    _deadline = _now().add(duration);
  }
  void pause() {
    if (_deadline == null) return;
    _pausedMillis = remaining.inMilliseconds;
    _deadline = null;
  }
  void resume() {
    if (!paused) return;
    _deadline = _now().add(Duration(milliseconds: _pausedMillis));
    _pausedMillis = 0;
  }
  void reset() { _deadline = null; _pausedMillis = 0; _totalMillis = 0; }
  Map<String, dynamic> toJson() => {'deadline': _deadline?.millisecondsSinceEpoch,
    'pausedMillis': _pausedMillis, 'totalMillis': _totalMillis};
  void restore(Map<String, dynamic> json) {
    _totalMillis = (json['totalMillis'] as num? ?? 0).toInt().clamp(0, 86400000).toInt();
    _pausedMillis = (json['pausedMillis'] as num? ?? 0).toInt().clamp(0, _totalMillis).toInt();
    final deadline = (json['deadline'] as num?)?.toInt();
    _deadline = deadline == null ? null : DateTime.fromMillisecondsSinceEpoch(deadline);
  }
}
