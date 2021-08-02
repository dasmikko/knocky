import 'package:time_formatter/time_formatter.dart';
import 'package:duration/duration.dart';

class Format {
  static String humanReadableTimeSince(DateTime dateTime) {
    return formatTime(dateTime.millisecondsSinceEpoch);
  }

  static String duration(DateTime from, DateTime to) {
    var difference = to.difference(from);
    return prettyDuration(difference);
  }
}
