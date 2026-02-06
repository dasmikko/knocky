import 'package:json_annotation/json_annotation.dart';
import 'alert.dart';

part 'alerts_response.g.dart';

@JsonSerializable()
class AlertsResponse {
  final List<Alert> alerts;
  final int totalAlerts;
  final List<int> ids;

  AlertsResponse({
    required this.alerts,
    required this.totalAlerts,
    required this.ids,
  });

  factory AlertsResponse.fromJson(Map<String, dynamic> json) =>
      _$AlertsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AlertsResponseToJson(this);

  int get totalPages => (totalAlerts / 20).ceil();
}
