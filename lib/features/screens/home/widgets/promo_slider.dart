import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/circular_container.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/features/shop/controllers/home_controller.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

bool _isNetworkUrl(String url) =>
    url.startsWith('http://') || url.startsWith('https://');

class IAMPromoSlider extends StatelessWidget {
  const IAMPromoSlider({super.key, required this.banners});

  final List<String> banners;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            aspectRatio: 725 / 450,
            viewportFraction: 1,
            onPageChanged: (index, _) => controller.updatePageIndicator(index),
          ),
          items: banners
              .map(
                (url) => IAMRoundedImage(
                  imageUrl: url,
                  isNetworkImage: _isNetworkUrl(url),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems),
        Center(
          child: Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < banners.length; i++)
                  IAMCircularContainer(
                    width: 20,
                    height: 4,
                    margin: const EdgeInsets.only(right: 10),
                    backgroundColor:
                        controller.carouselContextIndex.value == i
                            ? IAMColors.primary
                            : IAMColors.grey,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class IAMPromoSliderWeb extends StatefulWidget {
  const IAMPromoSliderWeb({super.key, required this.banners, this.autoPlayDuration = 4500});

  final List<String> banners;
  final int autoPlayDuration;

  @override
  State<IAMPromoSliderWeb> createState() => _IAMPromoSliderWebState();
}

class _IAMPromoSliderWebState extends State<IAMPromoSliderWeb> with SingleTickerProviderStateMixin {
  late final CarouselSliderController _carouselController;
  late final HomeController _homeController;
  late final AnimationController _progressController;
  int _currentIndex = 0;
  bool _arrowHoveredLeft = false;
  bool _arrowHoveredRight = false;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();
    _homeController = Get.put(HomeController());
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.autoPlayDuration),
    )..addListener(() {
        if (_progressController.isCompleted) {
          _goNext();
        }
      });
    _startProgress();
  }

  @override
  void didUpdateWidget(covariant IAMPromoSliderWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.autoPlayDuration != widget.autoPlayDuration) {
      _progressController.duration = Duration(milliseconds: widget.autoPlayDuration);
      _restartProgress();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _startProgress() {
    if (!_progressController.isAnimating) {
      _progressController.forward(from: 0.0);
    }
  }

  void _restartProgress() {
    _progressController
      ..stop()
      ..reset();
    _startProgress();
  }

  void _goNext() {
    if (widget.banners.length <= 1) return;
    final next = (_currentIndex + 1) % widget.banners.length;
    _carouselController.animateToPage(
      next,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    _homeController.updatePageIndicator(next);
    setState(() => _currentIndex = next);
    _restartProgress();
  }

  void _goPrev() {
    if (widget.banners.length <= 1) return;
    final prev = (_currentIndex - 1 + widget.banners.length) % widget.banners.length;
    _carouselController.animateToPage(
      prev,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
    _homeController.updatePageIndicator(prev);
    setState(() => _currentIndex = prev);
    _restartProgress();
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return MouseRegion(
      onEnter: (_) {
        _progressController.stop();
      },
      onExit: (_) {
        _restartProgress();
      },
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.92,
          child: AspectRatio(
            aspectRatio: 21 / 7,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark
                      ? const [Color(0xFF14110B), Color(0xFF1C1810), Color(0xFF0E0D0A)]
                      : const [Color(0xFFFFFDF5), Color(0xFFFFF8E5)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.06),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.4),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -60,
                      left: 80,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                    CarouselSlider(
                      carouselController: _carouselController,
                      options: CarouselOptions(
                        aspectRatio: 21 / 7,
                        viewportFraction: 1,
                        enableInfiniteScroll: widget.banners.length > 1,
                        enlargeCenterPage: false,
                        onPageChanged: (index, _) {
                          _homeController.updatePageIndicator(index);
                          setState(() => _currentIndex = index);
                          _restartProgress();
                        },
                      ),
                      items: widget.banners
                          .map(
                            (url) => Container(
                              padding: const EdgeInsets.all(18),
                              child: Center(
                                child: AnimatedScale(
                                  scale: 1.0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOutCubic,
                                  child: FractionallySizedBox(
                                    widthFactor: 0.80,
                                    heightFactor: 0.80,
                                    child: IAMRoundedImage(
                                      imageUrl: url,
                                      isNetworkImage: _isNetworkUrl(url),
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    if (widget.banners.length > 1) ...[
                      _buildArrow(context, dark, left: true),
                      _buildArrow(context, dark, left: false),
                    ],
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 18,
                      child: Center(
                        child: Obx(
                          () => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < widget.banners.length; i++)
                                _WebDotIndicator(
                                  index: i,
                                  active: _homeController.carouselContextIndex.value == i,
                                  onTap: () {
                                    _carouselController.animateToPage(
                                      i,
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                    );
                                    _homeController.updatePageIndicator(i);
                                    setState(() => _currentIndex = i);
                                    _restartProgress();
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 6,
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return Container(
                            height: 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: _progressController.value,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      IAMColors.primary.withValues(alpha: 0.9),
                                      IAMColors.primary.withValues(alpha: 0.5),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrow(BuildContext context, bool dark, {required bool left}) {
    final hovered = left ? _arrowHoveredLeft : _arrowHoveredRight;
    return Positioned(
      left: left ? 16 : null,
      right: left ? null : 16,
      top: 0,
      bottom: 0,
      child: Center(
        child: MouseRegion(
          onEnter: (_) => setState(() => left ? _arrowHoveredLeft = true : _arrowHoveredRight = true),
          onExit: (_) => setState(() => left ? _arrowHoveredLeft = false : _arrowHoveredRight = false),
          child: AnimatedScale(
            scale: hovered ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: GestureDetector(
              onTap: () => left ? _goPrev() : _goNext(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dark
                      ? Colors.black.withValues(alpha: hovered ? 0.45 : 0.3)
                      : Colors.white.withValues(alpha: hovered ? 0.95 : 0.7),
                  border: Border.all(
                    color: IAMColors.primary.withValues(alpha: hovered ? 0.5 : 0.3),
                    width: 1,
                  ),
                  boxShadow: hovered
                      ? [
                          BoxShadow(
                            color: IAMColors.primary.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  left ? Icons.keyboard_arrow_left_rounded : Icons.keyboard_arrow_right_rounded,
                  color: IAMColors.primary,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WebDotIndicator extends StatelessWidget {
  const _WebDotIndicator({
    required this.index,
    required this.active,
    required this.onTap,
  });

  final int index;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        width: active ? 26 : 12,
        height: 6,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: active
              ? IAMColors.primary
              : IAMColors.grey.withValues(alpha: 0.4),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: IAMColors.primary.withValues(alpha: 0.45),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
