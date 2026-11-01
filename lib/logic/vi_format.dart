/// Vietnamese date labels without needing intl locale data.
library;

String _two(int n) => n.toString().padLeft(2, '0');

/// "T2" … "T7", "CN".
String viWeekdayShort(DateTime d) => d.weekday == DateTime.sunday ? 'CN' : 'T${d.weekday + 1}';

/// "Thứ Hai" … "Chủ Nhật".
String viWeekdayLong(DateTime d) => const [
  'Thứ Hai',
  'Thứ Ba',
  'Thứ Tư',
  'Thứ Năm',
  'Thứ Sáu',
  'Thứ Bảy',
  'Chủ Nhật',
][d.weekday - 1];

/// "31/10".
String viDayMonth(DateTime d) => '${_two(d.day)}/${_two(d.month)}';

/// "31/10/2026".
String viDate(DateTime d) => '${viDayMonth(d)}/${d.year}';

/// "31/10 18:45".
String formatViDateTime(DateTime d) => '${viDayMonth(d)} ${_two(d.hour)}:${_two(d.minute)}';
