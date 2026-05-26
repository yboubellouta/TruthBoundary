import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/app_user.dart';

class HomeScreen extends StatelessWidget {
  final AppUser? currentUser;
  const HomeScreen({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TruthBoundary'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                'Check out TruthBoundary — spreading the truth of Islam. Join us on Telegram!',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            // App logo placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.brightness_5, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'بسم الله الرحمن الرحيم',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 22,
                    color: Colors.green[300],
                  ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 16),
            Text(
              'TruthBoundary',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Spreading the truth of Islam — one heart at a time.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[400],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            // Daily reminder card
            _DailyReminderCard(),
            const SizedBox(height: 20),
            // Quick action buttons
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.menu_book,
                    label: 'Content',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.send,
                    label: 'Telegram',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyReminderCard extends StatelessWidget {
  // TODO: replace with dynamic content later
  final String ayah =
      '"And who is better in speech than one who invites to Allah and does righteousness?"';
  final String reference = '— Quran 41:33';

  const _DailyReminderCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.format_quote, color: Colors.green[400]),
                const SizedBox(width: 8),
                Text(
                  'Daily Reminder',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.green[400]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ayah,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              reference,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.green[400]),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}
