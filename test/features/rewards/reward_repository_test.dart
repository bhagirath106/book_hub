import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_hub/features/rewards/data/reward_repository.dart';
import 'package:book_hub/features/rewards/domain/reward_rules.dart';

void main() {
  late LocalRewardRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = LocalRewardRepository(
      await SharedPreferences.getInstance(),
    );
  });

  test('starts with the configured initial balance', () async {
    expect(await repository.balance(), RewardRules.initialCoins);
  });

  test('caps rewarded ads at three per day', () async {
    for (var index = 0; index < RewardRules.maxAdsPerDay + 1; index++) {
      await repository.completeAd();
    }

    expect(
      await repository.balance(),
      RewardRules.initialCoins + RewardRules.maxAdsPerDay * RewardRules.adCoins,
    );
  });

  test('resets the daily ad allowance on a new date', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('reward_ads_date', '2000-01-01');
    await preferences.setInt('reward_ads', RewardRules.maxAdsPerDay);

    await repository.completeAd();

    expect(
      await repository.balance(),
      RewardRules.initialCoins + RewardRules.adCoins,
    );
  });

  test('uses the early share reward for the first five shares', () async {
    for (var index = 0; index < RewardRules.earlyShareCount; index++) {
      await repository.qualifyShare();
    }

    expect(
      await repository.balance(),
      RewardRules.initialCoins +
          RewardRules.earlyShareCount * RewardRules.earlyShareCoins,
    );
  });

  test('uses the later share reward after the first five shares', () async {
    for (var index = 0; index < RewardRules.earlyShareCount + 1; index++) {
      await repository.qualifyShare();
    }

    expect(
      await repository.balance(),
      RewardRules.initialCoins +
          RewardRules.earlyShareCount * RewardRules.earlyShareCoins +
          RewardRules.laterShareCoins,
    );
  });

  test('unlocks one page for one coin and rejects empty balances', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt('reward_balance', RewardRules.coinsPerPage);

    expect(await repository.unlockPage(), isTrue);
    expect(await repository.balance(), 0);
    expect(await repository.unlockPage(), isFalse);
  });
}
