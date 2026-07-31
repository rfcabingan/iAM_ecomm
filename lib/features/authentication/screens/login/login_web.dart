import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:iam_ecomm/features/authentication/screens/login/widgets/login_form.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

/// Dedicated desktop-web login — full-bleed split composition.
/// Not used on Android/iOS (those keep the mobile [LoginScreen] stack).
class LoginWebScreen extends StatelessWidget {
  const LoginWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? IAMColors.black : const Color(0xFFF7F5F0),
      body: SizedBox.expand(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 11,
              child: Container(
                decoration: BoxDecoration(
                  color: dark ? IAMColors.black : const Color(0xFF121212),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: dark
                        ? const [
                            Color(0xFF0D0D0D),
                            Color(0xFF161410),
                            Color(0xFF0A0A0A),
                          ]
                        : const [
                            Color(0xFF141414),
                            Color(0xFF1F1C16),
                            Color(0xFF0F0F0F),
                          ],
                  ),
                ),
                child: Stack(
                  children: [
                    const _LuxuryGridBackground(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(54, 48, 54, 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              if (Get.isRegistered<NavigationController>()) {
                                Get.find<NavigationController>()
                                    .navigateToHome();
                              } else {
                                Get.offAll(() => const NavigationMenu());
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: IAMColors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(
                                  color: IAMColors.primary.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              backgroundColor: Colors.white.withValues(alpha: 0.02),
                            ),
                            icon: const Icon(Icons.arrow_back_rounded, size: 16),
                            label: const Text(
                              'BACK TO STORE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'IAM',
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge
                                ?.copyWith(
                                  color: IAMColors.primary,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 16,
                                  height: 0.95,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'ESTABLISHED WELLNESS',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: IAMColors.primary.withValues(alpha: 0.65),
                                  letterSpacing: 4.0,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: 80,
                            height: 2,
                            color: IAMColors.primary,
                          ),
                          const SizedBox(height: 28),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Text(
                              'Member access to curated wellness — the same IAM shop, composed for the desktop.',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: IAMColors.white
                                        .withValues(alpha: 0.75),
                                    height: 1.6,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.3,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _MetaChip(label: 'Secure sign-in'),
                              _MetaChip(label: 'Points & wallet'),
                              _MetaChip(label: 'Order tracking'),
                            ],
                          ),
                          const SizedBox(height: 26),
                          const _AnnouncementsPanel(),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: dark ? IAMColors.dark : const Color(0xFFF7F5F0),
                  border: Border(
                    left: BorderSide(
                      color: IAMColors.primary.withValues(alpha: 0.12),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 40,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: dark ? IAMColors.black : IAMColors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: IAMColors.primary.withValues(alpha: 0.35),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: dark ? 0.3 : 0.04,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Image.asset(
                                dark
                                    ? IAMImages.lightAppLogo
                                    : IAMImages.darkAppLogo,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            IAMTexts.loginTitle,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            IAMTexts.loginSubTitle,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: dark
                                      ? IAMColors.lightGrey
                                      : IAMColors.textSecondary,
                                  height: 1.55,
                                ),
                          ),
                          const SizedBox(height: IAMSizes.spaceBtwSections),
                          const IAMLoginForm(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LuxuryGridBackground extends StatelessWidget {
  const _LuxuryGridBackground();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Subtle horizontal grid line
          Positioned(
            left: 0,
            right: 0,
            top: 240,
            child: Container(
              height: 1,
              color: IAMColors.primary.withValues(alpha: 0.08),
            ),
          ),
          // Subtle vertical grid line
          Positioned(
            left: 120,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              color: IAMColors.primary.withValues(alpha: 0.08),
            ),
          ),
          // Large concentric celestial circle 1
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: IAMColors.primary.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
            ),
          ),
          // Concentric circle 2
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 310,
              height: 310,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: IAMColors.primary.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
            ),
          ),
          // Concentric circle 3
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: IAMColors.primary.withValues(alpha: 0.12),
                  width: 1.5,
                ),
              ),
            ),
          ),
          // Floating gold ambient glows (radial gradients)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    IAMColors.primary.withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    IAMColors.primary.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementsPanel extends StatefulWidget {
  const _AnnouncementsPanel();

  @override
  State<_AnnouncementsPanel> createState() => _AnnouncementsPanelState();
}

class _AnnouncementsPanelState extends State<_AnnouncementsPanel> {
  late final Future<List<_AnnouncementItem>> _future;
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _future = _loadAnnouncements();
  }

  Future<List<_AnnouncementItem>> _loadAnnouncements() async {
    final uri = Uri.parse(
      'https://apiutil.iam-worldwidecorp.com/v1/Announcements/GetActiveAnnouncements',
    );
    final response = await http.get(
      uri,
      headers: {
        'ApiKey': 'f24b51dfd6fda3a6fb20882c1554790e',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      return const [];
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      return const [];
    }

    return decoded.whereType<Map>().map((entry) {
      final map = Map<String, dynamic>.from(entry);
      final mediaFilesRaw = map['mediaFiles'];
      final mediaFiles = <String>[];
      if (mediaFilesRaw is String) {
        try {
          final parsed = jsonDecode(mediaFilesRaw);
          if (parsed is List) {
            for (final item in parsed) {
              if (item is String && item.trim().isNotEmpty) {
                mediaFiles.add(item.trim());
              }
            }
          }
        } catch (_) {}
      } else if (mediaFilesRaw is List) {
        for (final item in mediaFilesRaw) {
          if (item is String && item.trim().isNotEmpty) {
            mediaFiles.add(item.trim());
          }
        }
      }
      return _AnnouncementItem(
        title: map['title']?.toString() ?? 'Announcements',
        content: map['announcementContent']?.toString() ?? '',
        imageUrls: mediaFiles,
      );
    }).where((item) => item.title.isNotEmpty || item.imageUrls.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return FutureBuilder<List<_AnnouncementItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildCard(
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            dark: dark,
          );
        }
        if (snapshot.hasError || (snapshot.data ?? const []).isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!;
        return _buildCard(
          dark: dark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: IAMColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ANNOUNCEMENTS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: IAMColors.primary,
                          letterSpacing: 1.8,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 214,
                child: CarouselSlider.builder(
                  carouselController: _carouselController,
                  itemCount: items.length,
                  options: CarouselOptions(
                    viewportFraction: 1,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 6),
                    enlargeCenterPage: false,
                    onPageChanged: (index, reason) {
                      setState(() => _currentIndex = index);
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final item = items[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (item.imageUrls.isNotEmpty)
                            CachedNetworkImage(
                              imageUrl: item.imageUrls.first,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: dark ? const Color(0xFF181818) : const Color(0xFFF0E8DB),
                                child: const Center(
                                  child: Icon(Icons.image_not_supported_rounded),
                                ),
                              ),
                            )
                          else
                            Container(
                              color: dark ? const Color(0xFF181818) : const Color(0xFFF0E8DB),
                              child: Center(
                                child: Icon(
                                  Icons.campaign_rounded,
                                  size: 44,
                                  color: IAMColors.primary.withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.75),
                                    Colors.black.withValues(alpha: 0.1),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.title.toUpperCase(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: IAMColors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.0,
                                        ),
                                  ),
                                  if (item.content.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      item.content,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: IAMColors.white.withValues(alpha: 0.85),
                                            height: 1.45,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(items.length, (index) {
                  final selected = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: selected ? 22 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: selected ? IAMColors.primary : IAMColors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard({required Widget child, required bool dark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF131313) : const Color(0xFFF7F2E8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: IAMColors.primary.withValues(alpha: 0.22),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.16 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AnnouncementItem {
  const _AnnouncementItem({
    required this.title,
    required this.content,
    required this.imageUrls,
  });

  final String title;
  final String content;
  final List<String> imageUrls;
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: IAMColors.primary.withValues(alpha: 0.05),
        border: Border.all(
          color: IAMColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: IAMColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: IAMColors.primary,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}
