import 'package:shared_preferences/shared_preferences.dart';
import '../domain/reward_rules.dart';

abstract interface class RewardRepository {
  Future<int> balance();
  Future<int> completeAd();
  Future<int> qualifyShare();
  Future<bool> unlockPage();
}

class LocalRewardRepository implements RewardRepository {
  LocalRewardRepository(this._prefs);
  final SharedPreferences _prefs;
  static const _balanceKey = 'reward_balance';
  static const _adsKey = 'reward_ads';
  static const _adsDateKey = 'reward_ads_date';
  static const _sharesKey = 'reward_shares';

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<int> _adsToday() async {
    final today = _today();
    if (_prefs.getString(_adsDateKey) != today) {
      await _prefs.setString(_adsDateKey, today);
      await _prefs.setInt(_adsKey, 0);
      return 0;
    }
    return _prefs.getInt(_adsKey) ?? 0;
  }

  @override
  Future<int> balance() async =>
      _prefs.getInt(_balanceKey) ?? RewardRules.initialCoins;

  @override
  Future<int> completeAd() async {
    final ads = await _adsToday();
    if (ads >= RewardRules.maxAdsPerDay) return balance();
    final next = (await balance()) + RewardRules.adCoins;
    await _prefs.setInt(_adsKey, ads + 1);
    await _prefs.setInt(_balanceKey, next);
    return next;
  }

  @override
  Future<int> qualifyShare() async {
    final shares = _prefs.getInt(_sharesKey) ?? 0;
    final reward = shares < RewardRules.earlyShareCount
        ? RewardRules.earlyShareCoins
        : RewardRules.laterShareCoins;
    final next = (await balance()) + reward;
    await _prefs.setInt(_sharesKey, shares + 1);
    await _prefs.setInt(_balanceKey, next);
    return next;
  }

  @override
  Future<bool> unlockPage() async {
    final current = await balance();
    if (current < RewardRules.coinsPerPage) return false;
    await _prefs.setInt(_balanceKey, current - RewardRules.coinsPerPage);
    return true;
  }
}
