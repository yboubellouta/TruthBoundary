import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: replace with your real Telegram links
const List<Map<String, String>> channels = [
  {
    'name': 'TruthBoundary — Main Channel',
    'description': 'Daily reminders, Quran, Hadith and more',
    'url': 'https://t.me/truthboundary', // replace with real link
    'icon': 'channel',
  },
  {
    'name': 'TruthBoundary — Discussion',
    'description': 'Ask questions, discuss Islam, share knowledge',
    'url': 'https://t.me/truthboundarychat', // replace with real link
    'icon': 'group',
  },
];

class LinksScreen extends StatelessWidget {
  const LinksScreen({super.key});

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Join Our Community',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Connect with us on Telegram for daily dawah content.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            ...channels.map(
              (channel) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ChannelCard(
                  channel: channel,
                  onTap: () => _openLink(context, channel['url']!),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final Map<String, String> channel;
  final VoidCallback onTap;

  const _ChannelCard({required this.channel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isGroup = channel['icon'] == 'group';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF0088CC), // Telegram blue
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isGroup ? Icons.group : Icons.send,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel['name'] ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      channel['description'] ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
