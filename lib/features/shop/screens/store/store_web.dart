import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/layouts/web_hover_card.dart';
import 'package:iam_ecomm/common/widgets/loaders/skeleton.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_horizontal.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/features/shop/controllers/store_controller.dart';
import 'package:iam_ecomm/features/shop/screens/all_products/all_products.dart';
import 'package:iam_ecomm/utils/constants/breakpoints.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/product_categories.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

/// Dedicated desktop-web storefront (sidebar categories + editorial hero).
/// Android/iOS continue using the mobile [StoreScreen] NestedScrollView.
class StoreWebScreen extends StatefulWidget {
  const StoreWebScreen({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<StoreWebScreen> createState() => _StoreWebScreenState();
}

class _StoreWebScreenState extends State<StoreWebScreen> {
  late int _selectedCategoryIndex;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex =
        widget.initialTabIndex.clamp(0, ProductCategories.ids.length - 1);

    if (!Get.isRegistered<StoreController>()) {
      Get.put(StoreController());
    }
    final controller = Get.find<StoreController>();
    if (controller.featuredProducts.isEmpty &&
        !controller.featuredLoading.value) {
      controller.fetchFeaturedProducts();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategory(ProductCategories.ids[_selectedCategoryIndex]);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadCategory(int categoryId) {
    final controller = Get.find<StoreController>();
    if (!controller.loadingByCategory.containsKey(categoryId) &&
        !controller.productsByCategory.containsKey(categoryId)) {
      controller.fetchProductsByCategory(categoryId);
    }
  }

  void _selectCategory(int index) {
    setState(() => _selectedCategoryIndex = index);
    _loadCategory(ProductCategories.ids[index]);
  }

  void _submitSearch() {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    Get.to(() => AllProducts(initialSearchQuery: q));
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final categoryId = ProductCategories.ids[_selectedCategoryIndex];
    final categoryName = ProductCategories.names[_selectedCategoryIndex];
    final controller = Get.find<StoreController>();

    return ColoredBox(
      color: dark ? IAMColors.dark : const Color(0xFFF7F5F0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: IAMBreakpoints.contentMaxWidth + 64,
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _StoreHero(dark: dark)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: _SearchField(
                    controller: _searchController,
                    onSubmit: _submitSearch,
                    dark: dark,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _WebSectionReveal(
                  delay: const Duration(milliseconds: 100),
                  offsetY: 24,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF16110A) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: IAMColors.primary.withValues(alpha: 0.2),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: dark ? 0.12 : 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: IAMColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Featured',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
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
              ),
              SliverToBoxAdapter(
                child: _WebSectionReveal(
                  delay: const Duration(milliseconds: 180),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF15120D) : const Color(0xFFFFFCF7),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: IAMColors.primary.withValues(alpha: 0.16),
                          width: 1.2,
                        ),
                      ),
                      child: SizedBox(
                        height: 140,
                        child: _FeaturedRow(),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 48),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 240,
                        child: _CategorySidebar(
                          selectedIndex: _selectedCategoryIndex,
                          onSelect: _selectCategory,
                          dark: dark,
                        ),
                      ),
                      const SizedBox(width: 28),
                      Expanded(
                        child: Obx(() {
                          if (controller.loadingByCategory[categoryId] ==
                              true) {
                            return const IAMProductGridSkeleton(itemCount: 8);
                          }
                          final err = controller.errorByCategory[categoryId];
                          if (err != null && err.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(err),
                            );
                          }
                          final list = controller.productsFor(categoryId);
                          return Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: dark ? const Color(0xFF17120B) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: IAMColors.primary.withValues(alpha: 0.18),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: dark ? 0.12 : 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      categoryName,
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
                                Text(
                                  '${list.length} curated picks',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: dark
                                            ? IAMColors.lightGrey
                                            : IAMColors.textSecondary,
                                      ),
                                ),
                                const SizedBox(height: 18),
                                if (list.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 48,
                                    ),
                                    child: Text(
                                      'No products in this collection yet.',
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  )
                                else
                                  IAMGridLayout(
                                    itemCount: list.length,
                                    mainAxisExtent: 300,
                                    itemBuilder: (_, index) => WebHoverCard(
                                      child: IAMProductCardVertical(
                                        product: list[index],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                           );
                         }),
                       ),
                     ],
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

class _StoreHero extends StatelessWidget {
  const _StoreHero({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF100F0B), Color(0xFF1D180F), Color(0xFF0B0B0B)]
              : const [Color(0xFF161616), Color(0xFF2A240F), Color(0xFF111111)],
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
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: IAMColors.primary.withValues(alpha: 0.08),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: IAMColors.primary.withValues(alpha: 0.12),
                    width: 1.6,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(36, 40, 36, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'IAM WORLDWIDE',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: IAMColors.primary,
                              letterSpacing: 4,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: IAMColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ESTABLISHED WELLNESS',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: IAMColors.primary.withValues(alpha: 0.6),
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Wellness finds its place in the store.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: IAMColors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      'Browse hand-picked essentials, discover new favorites, and keep your wellness routine flowing with a calmer desktop experience.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: IAMColors.white.withValues(alpha: 0.78),
                            height: 1.6,
                          ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      
                      
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: IAMColors.primary.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: IAMColors.white.withValues(alpha: 0.9),
              letterSpacing: 1.15,
              fontWeight: FontWeight.w700,
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

class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.controller,
    required this.onSubmit,
    required this.dark,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool dark;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final interactive = _hovered || _focusNode.hasFocus;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: widget.dark ? IAMColors.black : IAMColors.white,
          border: Border.all(
            color: interactive
                ? IAMColors.primary.withValues(alpha: 0.55)
                : IAMColors.primary.withValues(alpha: 0.22),
            width: interactive ? 1.6 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.dark ? 0.18 : 0.04),
              blurRadius: interactive ? 22 : 16,
              offset: Offset(0, interactive ? 10 : 8),
            ),
            if (interactive)
              BoxShadow(
                color: IAMColors.primary.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onSubmitted: (_) => widget.onSubmit(),
          decoration: InputDecoration(
            hintText: 'Search the store for wellness essentials',
            prefixIcon: const Icon(Iconsax.search_normal, size: 20),
            suffixIcon: Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: widget.onSubmit,
                icon: const Icon(Iconsax.arrow_right_3),
                color: IAMColors.primary,
                splashRadius: 20,
              ),
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturedRow extends StatelessWidget {
  const _FeaturedRow();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<StoreController>();
      if (controller.featuredLoading.value) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, __) => const IAMSkeleton(
            height: 130,
            width: 280,
            radius: IAMSizes.cardRadiusLg,
          ),
        );
      }
      if (controller.featuredProducts.isEmpty) {
        return const Center(child: Text('No featured products yet'));
      }
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: controller.featuredProducts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, index) {
          final product = controller.featuredProducts[index];
          return WebHoverCard(
            lift: 4,
            child: SizedBox(
              width: 320,
              child: IAMProductCardHorizontal(product: product),
            ),
          );
        },
      );
    });
  }
}

class _CategorySidebar extends StatelessWidget {
  const _CategorySidebar({
    required this.selectedIndex,
    required this.onSelect,
    required this.dark,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CATEGORIES',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w800,
                    color: IAMColors.primary,
                  ),
            ),
            const SizedBox(height: 18),
            ...List.generate(ProductCategories.ids.length, (index) {
              final selected = index == selectedIndex;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    bool hovered = false;
                    return MouseRegion(
                      onEnter: (_) => setState(() => hovered = true),
                      onExit: (_) => setState(() => hovered = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        transform: Matrix4.identity()
                          ..translate(0.0, hovered && !selected ? -2 : 0.0),
                        decoration: BoxDecoration(
                          color: selected
                              ? IAMColors.primary.withValues(alpha: dark ? 0.15 : 0.08)
                              : (hovered
                                  ? IAMColors.primary.withValues(alpha: dark ? 0.08 : 0.04)
                                  : Colors.transparent),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: () => onSelect(index),
                            borderRadius: BorderRadius.circular(14),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: selected ? 4 : 0,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: selected ? IAMColors.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  SizedBox(width: selected ? 10 : 0),
                                  Expanded(
                                    child: Text(
                                      ProductCategories.names[index],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: selected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: selected
                                                ? IAMColors.primary
                                                : (dark
                                                    ? IAMColors.lightGrey
                                                    : IAMColors.darkerGrey),
                                          ),
                                    ),
                                  ),
                                  if (selected)
                                    const Icon(
                                      Icons.keyboard_arrow_right_rounded,
                                      size: 16,
                                      color: IAMColors.primary,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
