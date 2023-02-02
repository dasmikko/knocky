import 'package:date_time_format/date_time_format.dart';
import 'package:duration/duration.dart';

class Format {
  static String humanReadableTimeSince(DateTime dateTime) {
    return DateTimeFormat.relative(dateTime);
  }

  static String duration(DateTime from, DateTime to) {
    var difference = to.difference(from);
    return prettyDuration(difference);
  }
}
