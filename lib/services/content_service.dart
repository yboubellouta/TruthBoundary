import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/content_model.dart';

class ContentService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // Live stream of all cards, newest first
  Stream<List<ContentCard>> get cardsStream {
    return _db
        .collection('content')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ContentCard.fromFirestore).toList());
  }

  // Upload a media file and return its download URL
  Future<String> uploadMedia(File file, String authorId) async {
    final ext = file.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final ref = _storage.ref('content/$authorId/$fileName');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }

  // Create a new content card (admin only — enforced by Firestore rules)
  Future<void> createCard({
    required String title,
    required String body,
    required ContentType type,
    required String authorId,
    String? arabic,
    File? mediaFile,
  }) async {
    String? mediaUrl;
    if (mediaFile != null) {
      mediaUrl = await uploadMedia(mediaFile, authorId);
    }

    final card = ContentCard(
      id: '',
      title: title,
      body: body,
      type: type,
      mediaUrl: mediaUrl,
      arabic: arabic,
      authorId: authorId,
      createdAt: DateTime.now(),
    );

    await _db.collection('content').add(card.toFirestore());
  }

  // Delete a card and its media file
  Future<void> deleteCard(ContentCard card) async {
    if (card.mediaUrl != null) {
      try {
        final ref = _storage.refFromURL(card.mediaUrl!);
        await ref.delete();
      } catch (_) {
        // media may already be deleted, continue
      }
    }
    await _db.collection('content').doc(card.id).delete();
  }
}
