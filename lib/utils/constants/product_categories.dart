/// Product category IDs and names matching the API.
/// Use these when calling ApiMiddleware.products.getProductsByCategory(id).
class ProductCategories {
  ProductCategories._();

  //static const int iamPackages = 1;
  static const int amazingBarley = 2;
  //static const int awesomeBeautyProducts = 3;
  static const int deliciousJuiceDrinks = 4;
  static const int foodSupplements = 5;
  static const int healthyCoffee = 6;

  /// All category IDs in tab order (1-6).
  static const List<int> ids = [
    //iamPackages,
    amazingBarley,
    //awesomeBeautyProducts,
    deliciousJuiceDrinks,
    foodSupplements,
    healthyCoffee,
  ];

  static const List<String> names = [
    //'IAM Packages',
    'Amazing Barley',
    //'Awesome Beauty',
    'Delicious Juice Drinks',
    'Food Supplements',
    'Healthy Coffee',
  ];

  /// Products that should also appear in additional category tabs.
  ///
  /// The API still owns the product's original category. This mapping only
  /// controls store tab display.
  static const Map<int, List<CategoryProductAlias>> extraProductsByCategory = {
    foodSupplements: [
      CategoryProductAlias(
        sourceCategoryId: amazingBarley,
        productCode: 'BARGUM',
      ),
    ],
    healthyCoffee: [
      CategoryProductAlias(
        sourceCategoryId: amazingBarley,
        productCode: 'BLACOF',
      ),
    ],
  };

  static List<CategoryProductAlias> extraProductsFor(int categoryId) =>
      extraProductsByCategory[categoryId] ?? const [];
}

class CategoryProductAlias {
  const CategoryProductAlias({
    required this.sourceCategoryId,
    required this.productCode,
  });

  final int sourceCategoryId;
  final String productCode;
}
