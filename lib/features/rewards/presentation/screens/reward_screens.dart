import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/preferences.dart';
import '../../../../core/widgets/bookhub_widgets.dart';
import '../../data/reward_repository.dart';
import '../../domain/reward_rules.dart';

final rewardRepositoryProvider = Provider<RewardRepository>(
  (ref) => LocalRewardRepository(ref.watch(sharedPreferencesProvider)),
);
final rewardBalanceProvider = FutureProvider<int>(
  (ref) => ref.watch(rewardRepositoryProvider).balance(),
);

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(rewardBalanceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Rewards & coins')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: Colors.deepPurple,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: balance.when(
                data: (value) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 42,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Your balance',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '$value coins',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                loading: () =>
                    const CircularProgressIndicator(color: Colors.white),
                error: (err, stack) => const Text(
                  'Balance unavailable',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Earn more'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.ondemand_video),
              title: const Text('Watch a rewarded ad'),
              subtitle: Text(
                'Up to ${RewardRules.maxAdsPerDay} per day · +${RewardRules.adCoins} coins',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RewardedAdScreen()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share BookHub'),
              subtitle: const Text(
                'First five qualifying shares earn 500 coins',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class RewardedAdScreen extends ConsumerWidget {
  const RewardedAdScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Rewarded ad')),
    body: Center(
      child: FilledButton.icon(
        onPressed: () async {
          await ref.read(rewardRepositoryProvider).completeAd();
          ref.invalidate(rewardBalanceProvider);
          if (context.mounted) Navigator.pop(context);
        },
        icon: const Icon(Icons.play_arrow),
        label: const Text('Complete demo ad'),
      ),
    ),
  );
}
