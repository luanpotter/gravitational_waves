import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gravitational_waves/game/analytics.dart';
import 'package:gravitational_waves/game/util.dart';
import 'package:oktoast/oktoast.dart';

class Ads {
  static bool _loaded = false;
  static RewardedAd? _preloadedAd;

  static bool _adsEnabled() {
    return ENABLE_ADS && !kIsWeb;
  }

  static bool adLoaded() {
    return _adsEnabled() && _loaded;
  }

  static Future<void> init() async {
    if (_adsEnabled()) {
      await MobileAds.instance.initialize();
      _loaded = true;
      _preLoadAd(); // pre-loads an ad for the first time
    }
  }

  static Future<void> _preLoadAd() async {
    _preloadedAd = await _loadAd();
  }

  static Future<RewardedAd?> _loadAd() async {
    const adUnitId = 'ca-app-pub-1572179540677968/7034539450';

    final promise = Completer<RewardedAd?>();
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(
        keywords: [
          'game',
          'gravity',
          'runner',
          'platformer',
          'action',
          'fast',
        ],
      ),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: promise.complete,
        onAdFailedToLoad: (LoadAdError error) {
          print('RewardedAd failed to load: $error');
          promise.complete(null);
        },
      ),
    );
    return promise.future;
  }

  static Future<bool> showAd() async {
    if (!_adsEnabled()) {
      return Future.value(false);
    }

    if (!_loaded) {
      showToast('There was an error while loading ads for the app.');
      return Future.value(false);
    }

    Analytics.log(EventName.REWARD);
    final promise = Completer<bool>();

    try {
      final ad = _preloadedAd ?? await _loadAd();
      if (ad == null) {
        showToast('There was an error while loading an ad right now.');
        return Future.value(false);
      }
      ad.fullScreenContentCallback = null;
      ad.show(
        onUserEarnedReward: (_, __) {
          promise.complete(true);
        },
      );
    } on Exception catch (ex) {
      print('Unexpected error while loading ad: $ex');
      showToast('Unexpected error while loading the ad.');
      promise.complete(false);
    }

    return promise.future;
  }
}
