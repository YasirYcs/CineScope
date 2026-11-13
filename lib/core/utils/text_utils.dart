/// Removes HTML tags and decodes the few entities used by TVMaze summaries.
String stripHtml(String? html) {
  if (html == null || html.trim().isEmpty) return '';

  final withoutTags = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
  final decoded = withoutTags
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&');

  return decoded
      .replaceAllMapped(RegExp(r'\s+([.,!?;:])'), (match) => match.group(1)!)
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats an ISO date (yyyy-MM-dd) as "21 Sep 2015".
String formatDate(String? isoDate) {
  final date = DateTime.tryParse(isoDate ?? '');
  if (date == null) return 'TBA';
  return '${date.day} ${_monthNames[date.month - 1]} ${date.year}';
}

String yearFromDate(String? isoDate) {
  if (isoDate == null || isoDate.length < 4) return 'TBA';
  return isoDate.substring(0, 4);
}
