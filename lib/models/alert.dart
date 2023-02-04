
class Alert {
  int? threadId;
  int? lastPostNumber;

  Alert({this.threadId, this.lastPostNumber});

  factory Alert.fromJson(Map<String, dynamic> json) => 
    Alert(
      threadId: json['threadId'],
      lastPostNumber: json['lastPostNumber']
    );
  Map<String, dynamic> toJson() => {
    'threadId': threadId,
    'lastPostNumber': lastPostNumber
  };
}