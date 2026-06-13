/// App store URLs, deep-link scheme, and referral share helpers.
class IamAppLinks {
  IamAppLinks._();

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.IAM.IAM_Ecomm';

  static const String appStoreUrl =
      'https://apps.apple.com/ph/app/iam-ecom/id6767620078';

  static const String referralScheme = 'iamecomm';
  static const String referralHost = 'signup';

  // [temp] Vercel share bridge domain for referral links
  static const String referralWebHost = 'iam-ecomm-share.vercel.app';
  static const String referralWebPath = '/r';

  // [temp] legacy shop domain — kept for backward-compatible deep links
  static const String legacyReferralWebHost = 'ecom-shop.iam-ww.com';
  static const String legacyReferralWebSignupPath = '/signup';

  /// Canonical HTTPS share link: https://iam-ecomm-share.vercel.app/r/{CODE}
  static String referralWebSignupUrl(String referralId) {
    final ref = referralId.trim();
    return Uri.https(referralWebHost, '$referralWebPath/$ref').toString();
  }

  /// In-app deep link used by custom scheme / fallback from web bridge.
  static String referralDeepLink(String referralId) {
    final ref = referralId.trim();
    return Uri(
      scheme: referralScheme,
      host: referralHost,
      queryParameters: {'ref': ref},
    ).toString();
  }

  /// Play Store link that passes the referral ID via the install referrer
  /// (Android only; read with the Play Install Referrer API on first launch).
  static String playStoreReferralUrl(String referralId) {
    final ref = referralId.trim();
    final referrer = Uri.encodeComponent('ref=$ref');
    return '$playStoreUrl&referrer=$referrer';
  }

  /// Full message text for the system share sheet.
  static String referralShareMessage(String referralId) {
    final ref = referralId.trim();
    final shareLink = referralWebSignupUrl(ref);
    return 'Join IAM Ecomm with my referral code: $ref\n\n'
        '$shareLink\n\n'
        'New install:\n'
        'Android: ${playStoreReferralUrl(ref)}\n'
        'iOS: $appStoreUrl';
  }
}
