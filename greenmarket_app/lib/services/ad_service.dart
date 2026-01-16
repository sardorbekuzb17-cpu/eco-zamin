import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static bool _initialized = false;

  // Test reklama ID'lari (haqiqiy ilovada o'zingiznikini qo'ying)
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test banner
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test interstitial
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test rewarded
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    return '';
  }

  // AdMob ni sozlash
  static Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  // Banner reklama yaratish
  static BannerAd createBannerAd({
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  // Interstitial reklama yaratish
  static Future<InterstitialAd?> createInterstitialAd() async {
    InterstitialAd? interstitialAd;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('Interstitial reklama yuklanmadi: $error');
          }
        },
      ),
    );

    return interstitialAd;
  }

  // Rewarded reklama yaratish (mavsumiy eslatgichlar uchun)
  static Future<RewardedAd?> createRewardedAd() async {
    RewardedAd? rewardedAd;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('Rewarded reklama yuklanmadi: $error');
          }
        },
      ),
    );

    return rewardedAd;
  }
}
