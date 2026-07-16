/// Formats [dt] as "Wed, 21 Jun · 3:30 PM".
String formatDateTime(DateTime dt) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} · ${_formatTime(dt)}';
}

/// Formats [dt] relative to [now] (defaults to the current time): "Tonight · 8:30 PM" for today from 5 PM, "Today · 8:30 AM" for today before that, "Tomorrow · 8:30 PM" for the next calendar day, and [formatDateTime] beyond that.
String formatRelativeDateTime(DateTime dt, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateTime(reference.year, reference.month, reference.day);
  final target = DateTime(dt.year, dt.month, dt.day);
  final dayDiff = target.difference(today).inDays;

  if (dayDiff == 0) {
    final label = dt.hour >= 17 ? 'Tonight' : 'Today';
    return '$label · ${_formatTime(dt)}';
  }
  if (dayDiff == 1) {
    return 'Tomorrow · ${_formatTime(dt)}';
  }
  return formatDateTime(dt);
}

String _formatTime(DateTime dt) {
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final period = dt.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}
