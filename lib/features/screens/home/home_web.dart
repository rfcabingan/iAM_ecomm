import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/layouts/web_hover_card.dart';
import 'package:iam_ecomm/common/widgets/loaders/skeleton.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/features/screens/home/widgets/promo_slider.dart';
import 'package:iam_ecomm/features/shop/controllers/home_controller.dart';
import 'package:iam_ecomm/features/shop/screens/all_products/all_products.dart';
import 'package:iam_ecomm/navigation_menu.dart';
import 'package:iam_ecomm/utils/constants/breakpoints.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/product_categories.dart';
import 'package:iam_ecomm/utils/constants/text_strings.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

/// Dedicated desktop-web home — editorial masthead + wide catalog grid.
class HomeWebScreen extends StatelessWidget {
  const HomeWebScreen({
    super.key,
    required this.bannerUrls,
    required this.bannersLoading,
  });

  final List<String> bannerUrls;
  final bool bannersLoading;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final controller = Get.find<HomeController>();

    void openSearchResults(String query) {
      final trimmed = query.trim();
      if (trimmed.isEmpty) return;
      Get.to(() => AllProducts(initialSearchQuery: trimmed));
    }

    return ColoredBox(
      color: dark ? IAMColors.dark : const Color(0xFFF7F5F0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: IAMBreakpoints.contentMaxWidth + 64,
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HomeMasthead(
                  dark: dark,
                  onShop: () {
                    if (Get.isRegistered<NavigationController>()) {
                      Get.find<NavigationController>().navigateToStore(0);
                    }
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: _HomeSearch(
                    dark: dark,
                    suggestions: controller.products
                        .map((p) => p.productName)
                        .where((n) => n.trim().isNotEmpty)
                        .toList(),
                    onSubmit: openSearchResults,
                  ),
                ),
              ),
              if (bannersLoading || bannerUrls.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: bannersLoading
                          ? const AspectRatio(
                              aspectRatio: 21 / 7,
                              child: ColoredBox(
                                color: Color(0x221A1A1A),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            )
                          : IAMPromoSliderWeb(banners: bannerUrls),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: _WebSectionReveal(
                  delay: const Duration(milliseconds: 100),
                  offsetY: 18,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
                    child: Row(
                      children: [
                        Text(
                          'Shop by category',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AnimatedUnderline(dark: dark),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _WebSectionReveal(
                  delay: const Duration(milliseconds: 180),
                  child: const WebHomeCategoriesPanel(),
                ),
              ),
              SliverToBoxAdapter(
                child: _WebSectionReveal(
                  delay: const Duration(milliseconds: 260),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                    child: Row(
                      children: [
                        Text(
                          'Popular products',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                              ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AnimatedUnderline(dark: dark),
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: () => Get.to(() => const AllProducts()),
                          icon: const Icon(Icons.arrow_right_alt_rounded, size: 18),
                          label: const Text('View all'),
                          style: TextButton.styleFrom(
                            foregroundColor: IAMColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                sliver: SliverToBoxAdapter(
                  child: _WebSectionReveal(
                    delay: const Duration(milliseconds: 340),
                    child: Obx(() {
                    final productsVersion = controller.productsVersion.value;
                    if (controller.productsLoading.value) {
                      return const IAMProductGridSkeleton(itemCount: 8);
                    }
                    if (controller.productsError.value.isNotEmpty) {
                      return Text(controller.productsError.value);
                    }
                    final list = controller.popularProducts;
                    if (list.isEmpty) {
                      return const Text('No popular products available');
                    }
                    return IAMGridLayout(
                      key: ValueKey('web-popular-$productsVersion'),
                      itemCount: list.length,
                      mainAxisExtent: 320,
                      itemBuilder: (_, index) {
                        final product = list[index];
                        return WebHoverCard(
                          child: IAMProductCardVertical(
                            key: ValueKey(
                              '${product.productCode}-$productsVersion',
                            ),
                            product: product,
                          ),
                        );
                      },
                    );
                  }),
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Categories strip for the desktop home composition (larger than mobile).
class WebHomeCategoriesPanel extends StatelessWidget {
  const WebHomeCategoriesPanel({super.key});

  static const List<String> _categoryImages = [
    IAMImages.amazingBarley1,
    IAMImages.deliciousJuiceDrinks1,
    IAMImages.foodSupplements1,
    IAMImages.healthyCoffee1,
  ];

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final labelColor = dark ? IAMColors.white : IAMColors.black;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? IAMColors.black : IAMColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: IAMColors.primary.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.2 : 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
          child: SizedBox(
            height: 180,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 28,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: List.generate(ProductCategories.ids.length, (index) {
                  final name = ProductCategories.names[index];
                  final image = index < _categoryImages.length
                      ? _categoryImages[index]
                      : IAMImages.sjkProducts;
                  return _CategoryHoverItem(
                    name: name,
                    image: image,
                    dark: dark,
                    labelColor: labelColor,
                    onTap: () {
                      Get.find<NavigationController>().navigateToStore(index);
                    },
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedUnderline extends StatelessWidget {
  const _AnimatedUnderline({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Container(
          height: 1.2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                IAMColors.primary.withValues(alpha: 0.0),
                IAMColors.primary.withValues(alpha: 0.55 * value),
                IAMColors.primary.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
          transform: Matrix4.identity()..scale(value, 1.0),
          alignment: Alignment.centerLeft,
        );
      },
    );
  }
}

class _WebSectionReveal extends StatelessWidget {
  const _WebSectionReveal({
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 18,
  });

  final Widget child;
  final Duration delay;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, offsetY * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

class _CategoryHoverItem extends StatefulWidget {
  const _CategoryHoverItem({
    required this.name,
    required this.image,
    required this.dark,
    required this.labelColor,
    required this.onTap,
  });

  final String name;
  final String image;
  final bool dark;
  final Color labelColor;
  final VoidCallback onTap;

  @override
  State<_CategoryHoverItem> createState() => _CategoryHoverItemState();
}

class _CategoryHoverItemState extends State<_CategoryHoverItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: SizedBox(
            width: 148,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _hovered ? 110 : 102,
                  height: _hovered ? 110 : 102,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.dark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFFFF9EE),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _hovered
                          ? IAMColors.primary.withValues(alpha: 0.7)
                          : IAMColors.primary.withValues(alpha: 0.35),
                      width: _hovered ? 2.2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _hovered
                            ? IAMColors.primary.withValues(alpha: 0.22)
                            : IAMColors.primary.withValues(
                                alpha: widget.dark ? 0.08 : 0.04,
                              ),
                        blurRadius: _hovered ? 22 : 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Image.asset(widget.image, fit: BoxFit.contain),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                        color: widget.labelColor,
                        fontWeight: FontWeight.w700,
                        height: 1.18,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeMasthead extends StatelessWidget {
  const _HomeMasthead({required this.dark, required this.onShop});

  final bool dark;
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF12100E), Color(0xFF1F1B12), Color(0xFF0D0D0D)]
              : const [Color(0xFF161616), Color(0xFF282315), Color(0xFF111111)],
        ),
        border: Border.all(
          color: IAMColors.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.25 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Elegant background shapes for editorial landing header
            Positioned(
              right: -60,
              top: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: IAMColors.primary.withValues(alpha: 0.04),
                    width: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: IAMColors.primary.withValues(alpha: 0.06),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 44, 40, 40),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final narrowLayout = constraints.maxWidth < 720;
                  final copy = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'IAM WORLDWIDE',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: IAMColors.primary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 10,
                              height: 1,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ESTABLISHED WELLNESS',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: IAMColors.primary.withValues(alpha: 0.65),
                              letterSpacing: 3.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        IAMTexts.homeAppbarTitle,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: IAMColors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: IAMColors.white.withValues(alpha: 0.72),
                              height: 1.5,
                            ),
                      ),
                    ],
                  );
                  final cta = FilledButton.icon(
                    onPressed: onShop,
                    style: FilledButton.styleFrom(
                      backgroundColor: IAMColors.primary,
                      foregroundColor: IAMColors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Text(
                      'SHOP THE STORE',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    label: const Icon(Icons.arrow_forward_rounded, size: 16),
                  );

                  if (narrowLayout) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        copy,
                        const SizedBox(height: 24),
                        cta,
                      ],
                    );
                  }

                  final compactLayout = constraints.maxWidth < 940;
                  if (compactLayout) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        copy,
                        const SizedBox(height: 24),
                        Align(alignment: Alignment.centerLeft, child: cta),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: copy),
                      const SizedBox(width: 32),
                      cta,
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSearch extends StatefulWidget {
  const _HomeSearch({
    required this.dark,
    required this.suggestions,
    required this.onSubmit,
  });

  final bool dark;
  final List<String> suggestions;
  final ValueChanged<String> onSubmit;

  @override
  State<_HomeSearch> createState() => _HomeSearchState();
}

class _HomeSearchState extends State<_HomeSearch> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final primary = IAMColors.primary;
    final focused = _focusNode.hasFocus;
    final interactive = _hovered || focused;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: dark ? IAMColors.black : IAMColors.white,
          border: Border.all(
            color: interactive
                ? primary.withValues(alpha: 0.55)
                : primary.withValues(alpha: 0.22),
            width: interactive ? 1.6 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.18 : 0.04),
              blurRadius: interactive ? 22 : 16,
              offset: Offset(0, interactive ? 10 : 8),
            ),
            if (interactive)
              BoxShadow(
                color: primary.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onSubmitted: widget.onSubmit,
            decoration: InputDecoration(
              hintText: 'Search wellness essentials, brands or products',
              prefixIcon: Icon(Iconsax.search_normal, size: 20),
              suffixIcon: Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () => widget.onSubmit(_controller.text),
                  icon: Icon(Iconsax.arrow_right_3),
                  color: IAMColors.primary,
                  splashRadius: 20,
                ),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}
