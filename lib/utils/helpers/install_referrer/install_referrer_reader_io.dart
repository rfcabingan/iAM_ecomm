import 'package:flutter/foundation.dart';
import 'package:play_install_referrer/play_install_referrer.dart';

/// Reads the Android Play Install Referrer string when available.
Future<String?> readInstallReferrer() async {
  if (defaultTargetPlatform != TargetPlatform.android) return null;

  try {
    final ReferrerDetails details = await PlayInstallReferrer.installReferrer;
    final referrer = details.installReferrer?.trim() ?? '';
    return referrer.isEmpty ? null : referrer;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('readInstallReferrer error: $e');
    }
    return null;
  }
}
