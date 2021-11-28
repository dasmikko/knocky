
class ReadThreads {
  DateTime lastSeen;
  int threadId;

  ReadThreads({this.lastSeen, this.threadId});

  factory ReadThreads.fromJson(Map<String, dynamic> json) => 
    ReadThreads(
      lastSeen: json['last_seen'],
      threadId: json['thread_id']
    );
  Map<String, dynamic> toJson() => {
    'last_seen': lastSeen,
    'thread_id': threadId
  };
}