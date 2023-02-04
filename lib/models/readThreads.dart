
class ReadThreads {
  DateTime? lastSeen;
  int? threadId;

  ReadThreads({this.lastSeen, this.threadId});

  factory ReadThreads.fromJson(Map<String, dynamic> json) => 
    ReadThreads(
      lastSeen: json['lastSeen'],
      threadId: json['threadId']
    );
  Map<String, dynamic> toJson() => {
    'lastSeen': lastSeen!.toIso8601String(),
    'threadId': threadId
  };
} 