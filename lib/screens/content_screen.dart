import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/content_model.dart';
import '../models/app_user.dart';
import '../services/content_service.dart';

class ContentScreen extends StatelessWidget {
  final AppUser? currentUser;

  const ContentScreen({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    final service = ContentService();

    return Scaffold(
      appBar: AppBar(title: const Text('Content'), centerTitle: true),
      body: StreamBuilder<List<ContentCard>>(
        stream: service.cardsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final cards = snapshot.data ?? [];
          if (cards.isEmpty) {
            return const Center(
              child: Text('No content yet. Check back soon!'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _ContentCard(
                card: cards[index],
                isAdmin: currentUser?.isAdmin ?? false,
                onDelete: currentUser?.isAdmin == true
                    ? () => _confirmDelete(context, cards[index], service)
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ContentCard card,
    ContentService service,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete card?'),
        content: Text('Delete "${card.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await service.deleteCard(card);
    }
  }
}

class _ContentCard extends StatelessWidget {
  final ContentCard card;
  final bool isAdmin;
  final VoidCallback? onDelete;

  const _ContentCard({
    required this.card,
    required this.isAdmin,
    this.onDelete,
  });

  Color _typeColor() {
    switch (card.type) {
      case ContentType.image:
        return const Color(0xFF1565C0);
      case ContentType.audio:
        return const Color(0xFF6A1B9A);
      case ContentType.video:
        return const Color(0xFFBF360C);
      case ContentType.text:
        return const Color(0xFF1B5E20);
    }
  }

  IconData _typeIcon() {
    switch (card.type) {
      case ContentType.image:
        return Icons.image_outlined;
      case ContentType.audio:
        return Icons.audiotrack_outlined;
      case ContentType.video:
        return Icons.videocam_outlined;
      case ContentType.text:
        return Icons.format_quote;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media preview
          if (card.mediaUrl != null && card.type == ContentType.image)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: card.mediaUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 180,
                  color: Colors.grey[800],
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          if (card.mediaUrl != null &&
              (card.type == ContentType.audio || card.type == ContentType.video))
            Container(
              height: 60,
              color: _typeColor().withOpacity(0.15),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_typeIcon(), color: _typeColor()),
                    const SizedBox(width: 8),
                    Text(
                      '${card.type.name[0].toUpperCase()}${card.type.name.substring(1)} — tap to play',
                      style: TextStyle(color: _typeColor()),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _typeColor(),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_typeIcon(), color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            card.type.name,
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        card.title,
                        style: Theme.of(context).textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, size: 18),
                      onPressed: () => Share.share(
                        '${card.title}\n\n${card.body}\n\n— TruthBoundary',
                      ),
                    ),
                    if (isAdmin && onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: Colors.red),
                        onPressed: onDelete,
                      ),
                  ],
                ),
                if ((card.arabic ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    card.arabic!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          color: Colors.green[300],
                        ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ],
                const SizedBox(height: 8),
                Text(card.body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
