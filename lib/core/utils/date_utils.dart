import 'package:intl/intl.dart';

class AppDateUtils {
  static String timeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      
      if (diff.inSeconds < 60) return "Just now";
      if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
      if (diff.inHours < 24) return "${diff.inHours}h ago";
      if (diff.inDays < 30) return "${diff.inDays}d ago";
      if (diff.inDays < 365) {
        final months = (diff.inDays / 30).floor();
        return "$months month${months > 1 ? 's' : ''} ago";
      }
      return DateFormat.yMMMd().format(date);
    } catch (e) {
      return "";
    }
  }
}
