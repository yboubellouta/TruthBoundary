import 'package:cloud_firestore/cloud_firestore.dart';

enum ContentType { text, image, audio, video }

class ContentCard {
  final String id;
  final String title;
  final String body;
  final ContentType type;
  final String? mediaUrl;   // Firebase Storage download URL
  final String? arabic;
  final String authorId;
  final DateTime createdAt;

  const ContentCard({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.mediaUrl,
    this.arabic,
    required this.authorId,
    required this.createdAt,
  });

  static ContentType _typeFromString(String value) {
    switch (value) {
      case 'image':
        return ContentType.image;
      case 'audio':
        return ContentType.audio;
      case 'video':
        return ContentType.video;
      default:
        return ContentType.text;
    }
  }

  static String _typeToString(ContentType type) {
    switch (type) {
      case ContentType.image:
        return 'image';
      case ContentType.audio:
        return 'audio';
      case ContentType.video:
        return 'video';
      case ContentType.text:
        return 'text';
    }
  }

  factory ContentCard.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContentCard(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: _typeFromString(data['type'] ?? 'text'),
      mediaUrl: data['mediaUrl'],
      arabic: data['arabic'],
      authorId: data['authorId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'type': _typeToString(type),
      'mediaUrl': mediaUrl,
      'arabic': arabic,
      'authorId': authorId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
