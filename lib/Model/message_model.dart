class MessageModel {
  String? sender;
  String? text;
  bool? seen;
  String? messageId;
  DateTime? time;

  MessageModel({
    this.sender,
    this.messageId,
    this.text,
    this.seen,
    this.time,
  });

  MessageModel.fromMap(Map<String, dynamic> map) {
    sender = map['sender'];
    messageId = map['messageId'];
    text = map['text'];
    seen = map['seen'];
    time = map['time'].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'messageId': messageId,
      'text': text,
      'seen': seen,
      'time': time,
    };
  }
}
