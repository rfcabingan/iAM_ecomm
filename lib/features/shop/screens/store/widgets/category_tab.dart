import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/loaders/skeleton.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/package_card.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:iam_ecomm/features/shop/controllers/store_controller.dart';
import 'package:iam_ecomm/features/shop/screens/all_products/all_products.dart';
import 'package:iam_ecomm/features/shop/screens/packages/all_packages.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/product_categories.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/models/package_option.dart';

class IAMCategoryTab extends StatefulWidget {
  const IAMCategoryTab({super.key, required this.categoryId});

  final int categoryId;

  @override
  State<IAMCategoryTab> createState() => _IAMCategoryTabState();
}

class _IAMCategoryTabState extends State<IAMCategoryTab> {
  // Mock package data for display
  static final List<PackageOption> _mockPackages = [
    PackageOption(
      name: 'Copper Package',
      image: IAMImages.copper,
      price: 5000,
      description: 'Basic wellness starter kit with essential supplements for beginners starting their health journey.',
      selectionOptions: [
        PackageSelectionOption(
          id: 'copper_opt1',
          name: 'Option 1',
          price: 5000,
          products: [
            PackageProduct(productCode: 'BARGUM', productName: 'Barley Gum', quantity: 2),
            PackageProduct(productCode: 'BARCHO', productName: 'Barley Chocolate', quantity: 1),
          ],
        ),
        PackageSelectionOption(
          id: 'copper_opt2',
          name: 'Option 2',
          price: 6000,
          products: [
            PackageProduct(productCode: 'BARGUM', productName: 'Barley Gum', quantity: 3),
            PackageProduct(productCode: 'BLACOF', productName: 'Black Coffee', quantity: 1),
          ],
        ),
      ],
    ),
    PackageOption(
      name: 'Bronze Package',
      image: IAMImages.bronze,
      price: 10000,
      description: 'Enhanced wellness package with premium supplements for improved health benefits.',
      selectionOptions: [
        PackageSelectionOption(
          id: 'bronze_opt1',
          name: 'Option 1',
          price: 10000,
          products: [
            PackageProduct(productCode: 'BARGUM', productName: 'Barley Gum', quantity: 5),
            PackageProduct(productCode: 'BARCHO', productName: 'Barley Chocolate', quantity: 2),
            PackageProduct(productCode: 'BARPOW', productName: 'Barley Powder', quantity: 1),
          ],
        ),
        PackageSelectionOption(
          id: 'bronze_opt2',
          name: 'Option 2',
          price: 12000,
          products: [
            PackageProduct(productCode: 'BARGUM', productName: 'Barley Gum', quantity: 6),
            PackageProduct(productCode: 'BLACOF', productName: 'Black Coffee', quantity: 2),
            PackageProduct(productCode: 'BARPOW', productName: 'Barley Powder', quantity: 2),
          ],
        ),
      ],
    ),
    PackageOption(
      name: 'Silver Package',
      image: IAMImages.silver2,
      price: 15000,
      description: 'Complete wellness solution with advanced supplements for comprehensive health support.',
      selectionOptions: [
        PackageSelectionOption(
          id: 'silver_opt1',
          name: 'Option 1',
          price: 15000,
          products: [
            PackageProduct(productCode: 'BARGUM', productName: 'Barley Gum', quantity: 8),
            PackageProduct(productCode: 'BARCHO', productName: 'Barley Chocolate', quantity: 3),
            PackageProduct(productCode: 'BARPOW', productName: 'Barley Powder', quantity: 2),
            PackageProduct(productCode: 'COFTKA', productName: 'Coffee Taro', quantity: 1),
          ],
        ),
        PackageSelectionOption(
          id: 'silver_opt2',
          name: 'Option 2',
          price: 18000,
          products: [
            PackageProduct(productCode: 'BARGUM', productName: 'Barley Gum', quantity: 10),
            PackageProduct(productCode: 'BLACOF', productName: 'Black Coffee', quantity: 3),
            PackageProduct(productCode: 'BARPOW', productName: 'Barley Powder', quantity: 3),
            PackageProduct(productCode: 'COFGLU', productName: 'Coffee Gluta', quantity: 1),
          ],
        ),
      ],
    ),
    PackageOption(
      name: 'Gold Package',
      image: IAMImages.gold,
      price: 25000,
      description: 'Premium wellness package with exclusive benefits for VIP members.',
      selectionOptions: [
        PackageSelectionOption(
          id: 'gold_opt1',
          name: 'Option 1',
          price: 25000,
          products: [
            PackageProduct(productCode: 'BARGUM', productName: 'Barley Gum', quantity: 12),
            PackageProduct(productCode: 'BARCHO', productName: 'Barley Chocolate', quantity: 5),
            PackageProduct(productCode: 'BARPOW', productName: 'Barley Powder', quantity: 4),
            PackageProduct(productCode: 'COFTKA', productName: 'Coffee Taro', quantity: 2),
            PackageProduct(productCode: 'COFGLU', productName: 'Coffee Gluta', quantity: 1),
          ],
        ),
        PackageSelectionOption(
          id: 'gold_opt2',
          name: 'Option 2',
          price: 30000,
          products: [
            PackageProduct(productCode: 'BARGUM', productName: 'Barley Gum', quantity: 15),
            PackageProduct(productCode: 'BLACOF', productName: 'Black Coffee', quantity: 5),
            PackageProduct(productCode: 'BARPOW', productName: 'Barley Powder', quantity: 5),
            PackageProduct(productCode: 'COFTKA', productName: 'Coffee Taro', quantity: 3),
            PackageProduct(productCode: 'COFGLU', productName: 'Coffee Gluta', quantity: 2),
          ],
        ),
      ],
    ),
    PackageOption(
      name: 'Platinum Package',
      image: IAMImages.platinum,
      price: 50000,
      description: 'Ultimate wellness experience with VIP benefits and premium support.',
      selectionOptions: [
        PackageSelectionOption(
          id: 'platinum_opt1',
          name: 'Option 1',
          price: 50000,
          products: [
            PackageProduct(productCode: 'BARGUM', productName: 'Barley Gum', quantity: 20),
            PackageProduct(productCode: 'BARCHO', productName: 'Barley Chocolate', quantity: 8),
            PackageProduct(productCode: 'BARPOW', productName: 'Barley Powder', quantity: 8),
            PackageProduct(productCode: 'COFTKA', productName: 'Coffee Taro', quantity: 4),
            PackageProduct(productCode: 'COFGLU', productName: 'Coffee Gluta', quantity: 3),
            PackageProduct(productCode: 'CAFEMO', productName: 'Coffee Mocha', quantity: 2),
          ],
        ),
        PackageSelectionOption(
          id: 'platinum_opt2',
          name: 'Option 2',
          price: 60000,
          products: [
            PackageProduct(productCode: 'BARGUM', productName: 'Barley Gum', quantity: 25),
            PackageProduct(productCode: 'BLACOF', productName: 'Black Coffee', quantity: 10),
            PackageProduct(productCode: 'BARPOW', productName: 'Barley Powder', quantity: 10),
            PackageProduct(productCode: 'COFTKA', productName: 'Coffee Taro', quantity: 5),
            PackageProduct(productCode: 'COFGLU', productName: 'Coffee Gluta', quantity: 4),
            PackageProduct(productCode: 'CAFEMO', productName: 'Coffee Mocha', quantity: 3),
          ],
        ),
      ],
    ),
    PackageOption(
      name: 'Jade Package',
      image: IAMImages.jade,
      price: 100000,
      description: 'Exclusive luxury wellness package with full benefits and dedicated support.',
      selectionOptions: [
        PackageSelectionOption(
          id: 'jade_opt1',
          name: 'Option 1',
          price: 100000,
          products: [
            PackageProduct(productCode: 'BARGUM', productName: 'Barley Gum', quantity: 40),
            PackageProduct(productCode: 'BARCHO', productName: 'Barley Chocolate', quantity: 15),
            PackageProduct(productCode: 'BARPOW', productName: 'Barley Powder', quantity: 15),
            PackageProduct(productCode: 'COFTKA', productName: 'Coffee Taro', quantity: 8),
            PackageProduct(productCode: 'COFGLU', productName: 'Coffee Gluta', quantity: 6),
            PackageProduct(productCode: 'CAFEMO', productName: 'Coffee Mocha', quantity: 5),
            PackageProduct(productCode: 'CAFELA', productName: 'Coffee Latte', quantity: 3),
          ],
        ),
        PackageSelectionOption(
          id: 'jade_opt2',
          name: 'Option 2',
          price: 120000,
          products: [
            PackageProduct(productCode: 'BARGUM', productName: 'Barley Gum', quantity: 50),
            PackageProduct(productCode: 'BLACOF', productName: 'Black Coffee', quantity: 20),
            PackageProduct(productCode: 'BARPOW', productName: 'Barley Powder', quantity: 20),
            PackageProduct(productCode: 'COFTKA', productName: 'Coffee Taro', quantity: 10),
            PackageProduct(productCode: 'COFGLU', productName: 'Coffee Gluta', quantity: 8),
            PackageProduct(productCode: 'CAFEMO', productName: 'Coffee Mocha', quantity: 6),
            PackageProduct(productCode: 'CAFELA', productName: 'Coffee Latte', quantity: 5),
          ],
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<StoreController>();
      if (!controller.loadingByCategory.containsKey(widget.categoryId) &&
          !controller.productsByCategory.containsKey(widget.categoryId)) {
        controller.fetchProductsByCategory(widget.categoryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoreController>();
    final categoryId = widget.categoryId;
    final categoryName =
        ProductCategories.names[ProductCategories.ids
            .indexOf(categoryId)
            .clamp(0, ProductCategories.names.length - 1)];

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              /*IAMBrandShowCase(
                images: [
                  IAMImages.pibarcap,
                  IAMImages.pibarcho,
                  IAMImages.piacaibr,
                ],
              ),*/
              const SizedBox(height: IAMSizes.spaceBtwItems),
              IAMSectionHeading(
                title: categoryName,
                onPressed: () => categoryId == ProductCategories.iamPackages
                    ? Get.to(() => const AllPackages())
                    : Get.to(() => const AllProducts()),
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              Obx(() {
                // Special handling for packages category
                if (categoryId == ProductCategories.iamPackages) {
                  return IAMGridLayout(
                    itemCount: _mockPackages.length,
                    itemBuilder: (_, index) {
                      return IAMPackageCard(packageOption: _mockPackages[index]);
                    },
                  );
                }

                // Regular product categories
                if (controller.loadingByCategory[categoryId] == true) {
                  return const IAMProductGridSkeleton(itemCount: 4);
                }
                final err = controller.errorByCategory[categoryId];
                if (err != null && err.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                    child: Text(
                      err,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                final list = controller.productsFor(categoryId);
                return IAMGridLayout(
                  itemCount: list.length,
                  itemBuilder: (_, index) =>
                      IAMProductCardVertical(product: list[index]),
                );
              }),
              const SizedBox(height: IAMSizes.spaceBtwSections),
            ],
          ),
        ),
      ],
    );
  }
}
