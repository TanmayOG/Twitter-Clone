class ChatModel {
  var chatRoomId;
  var tokenId;
  Map<String, dynamic>? participants;
  String? lastMessage;
  var lastMessageTime;

  ChatModel({
    this.chatRoomId,
    this.participants,
    this.tokenId,
    this.lastMessage,
    this.lastMessageTime,
  });

  ChatModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map['chatRoomId'];
    tokenId = map['tokenId'];
    lastMessage = map['lastMessage'];
    lastMessageTime = map['lastMessageTime'];

    participants = Map<String, dynamic>.from(map['participants']);
  }

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'tokenId': tokenId,
      'participants': participants,
      'lastMessageTime': lastMessageTime,
      'lastMessage': lastMessage,
    };
  }
}
