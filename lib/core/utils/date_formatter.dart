const shortWeekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
DateTime weekStart(DateTime date) => DateTime(date.year, date.month, date.day - date.weekday + 1);
DateTime addCalendarDays(DateTime date, int days) => DateTime(date.year, date.month, date.day + days);
String dateKey(DateTime date) => '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
DateTime parseDateKey(String key) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key)) {
    throw const FormatException('Use a YYYY-MM-DD calendar date');
  }
  final parts = key.split('-').map(int.parse).toList();
  final date = DateTime(parts[0], parts[1], parts[2]);
  if (dateKey(date) != key) throw const FormatException('Invalid calendar date');
  return date;
}
String friendlyDate(DateTime date) => '${shortWeekdays[date.weekday - 1]}, ${date.day} ${monthNames[date.month - 1]}';
String weekLabel(DateTime start) {
  final end = addCalendarDays(start, 6);
  return '${start.day} ${monthNames[start.month - 1]} - ${end.day} ${monthNames[end.month - 1]}, ${end.year}';
}
