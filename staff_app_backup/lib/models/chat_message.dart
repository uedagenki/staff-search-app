class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
    this.imageUrl,
  });
}

enum MessageType {
  text,
  image,
  system,
}

class ChatRoom {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  ChatRoom({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}
