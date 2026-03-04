import 'package:iam_ecomm/features/shop/models/product_model.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';

class IAMProductsData {
  // List of all products
  static final List<IAMProductModel> products = [
    IAMProductModel(
      id: '1',
      title: 'Amazing Barley Capsules',
      brand: 'Amazing Barley',
      imageUrl: IAMImages.pibarcapwht,
      price: 1750.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '2',
      title: 'Amazing Black Coffee w/ Barley',
      brand: 'Amazing Barley',
      imageUrl: IAMImages.piblacofwht,
      price: 300.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '3',
      title: 'Amazing Organic Barley Gummies',
      brand: 'Amazing Barley',
      imageUrl: IAMImages.pibargumwht,
      price: 3000.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '4',
      title: 'Amazing Choco Barley',
      brand: 'Amazing Barley',
      imageUrl: IAMImages.pibarchowht,
      price: 1000.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '5',
      title: 'Amazing White',
      brand: 'Food Supplements',
      imageUrl: IAMImages.piiamwhtwht,
      price: 2950.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '6',
      title: 'Amazing Garcinia Cambogia',
      brand: 'Delicious Juice Drinks',
      imageUrl: IAMImages.pigarcamwht,
      price: 900.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '7',
      title: 'Amazing Acai Berry 7s',
      brand: 'Delicious Juice Drinks',
      imageUrl: IAMImages.piacaibrwht,
      price: 700.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '8',
      title: 'Amazing Immunergy Vitamin C',
      brand: 'Food Supplements',
      imageUrl: IAMImages.piiamimuwht,
      price: 500.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '9',
      title: 'Amazing Coffee w/ Tongkatali',
      brand: 'Healthy Coffee',
      imageUrl: IAMImages.picoftkawht,
      price: 750.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '10',
      title: 'Amazing Coffee w/ Glutha',
      brand: 'Healthy Coffee',
      imageUrl: IAMImages.picofgluwht,
      price: 750.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '11',
      title: 'Amazing Cafe Mocha',
      brand: 'Healthy Coffee',
      imageUrl: IAMImages.picafemowht,
      price: 750.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '12',
      title: 'Amazing Cafe Latte',
      brand: 'Healthy Coffee',
      imageUrl: IAMImages.picafelawht,
      price: 750.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '13',
      title: 'Amazing Caffe Macchiato',
      brand: 'Healthy Coffee',
      imageUrl: IAMImages.picafemawht,
      price: 375.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '14',
      title: 'Amazing Barley Pure Organic Powder',
      brand: 'Amazing Barley',
      imageUrl: IAMImages.pibarpowwht,
      price: 1000.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '15',
      title: 'Amazing Smile Toothpaste',
      brand: 'Amazing Barley',
      imageUrl: IAMImages.piiamsmiwht,
      price: 750.00,
      discountPercentage: 0.0,
    ),
    IAMProductModel(
      id: '16',
      title: 'Amazing Organic Barley Soap',
      brand: 'Awesome Beauty Products',
      imageUrl: IAMImages.pibarsopwht,
      price: 750.00,
      discountPercentage: 0.0,
    ),
  ];

  // List of all packages
  static final List<IAMProductModel> packages = [
    IAMProductModel(
      id: 'p1',
      title: 'Copper Package',
      brand: 'IAM Packages',
      imageUrl: IAMImages.copper,
      price: 5600.00,
      discountPercentage: 0.0,
      isPackage: true,
    ),
    IAMProductModel(
      id: 'p2',
      title: 'Bronze Package',
      brand: 'IAM Packages',
      imageUrl: IAMImages.bronze,
      price: 11200.00,
      discountPercentage: 0.0,
      isPackage: true,
    ),
    IAMProductModel(
      id: 'p3',
      title: 'Silver 2.0 Package',
      brand: 'IAM Packages',
      imageUrl: IAMImages.silver2,
      price: 16800.00,
      discountPercentage: 0.0,
      isPackage: true,
    ),
    IAMProductModel(
      id: 'p4',
      title: 'Gold Package',
      brand: 'IAM Packages',
      imageUrl: IAMImages.gold,
      price: 44800.00,
      discountPercentage: 0.0,
      isPackage: true,
    ),
    IAMProductModel(
      id: 'p5',
      title: 'Platinum Package',
      brand: 'IAM Packages',
      imageUrl: IAMImages.platinum,
      price: 112000.00,
      discountPercentage: 0.0,
      isPackage: true,
    ),
    IAMProductModel(
      id: 'p6',
      title: 'Jade Package',
      brand: 'IAM Packages',
      imageUrl: IAMImages.jade,
      price: 198800.00,
      discountPercentage: 0.0,
      isPackage: true,
    ),
  ];

  // Combined list of all products and packages
  static List<IAMProductModel> get allItems => [...products, ...packages];

  // Get shuffled list for variety
  static List<IAMProductModel> getShuffledItems() {
    final items = List<IAMProductModel>.from(allItems);
    items.shuffle();
    return items;
  }

  /// Shuffled products only (for variety on home/category)
  static List<IAMProductModel> getShuffledProducts() {
    final list = List<IAMProductModel>.from(products);
    list.shuffle();
    return list;
  }

  /// Shuffled packages only (for variety on home/category)
  static List<IAMProductModel> getShuffledPackages() {
    final list = List<IAMProductModel>.from(packages);
    list.shuffle();
    return list;
  }

  /// Get products filtered by brand/category name
  static List<IAMProductModel> getProductsByBrand(String brand) {
    return products.where((product) => product.brand == brand).toList();
  }

  /// Featured items for store header: Barley Gummies + Amazing Smile Toothpaste
  static List<IAMProductModel> get featuredItems => [
        products.firstWhere((p) => p.id == '3'),
        products.firstWhere((p) => p.id == '15'),
      ];

  /// Popular products for home page: Barley Capsules, Barley Gummies, Choco Barley, Barley Powder
  static List<IAMProductModel> get popularProducts => [
        products.firstWhere((p) => p.id == '4'), // IAM Choco Barley
        products.firstWhere((p) => p.id == '14'), // IAM Barley Pure Organic Powder
        products.firstWhere((p) => p.id == '1'), // IAM Barley Capsules
        products.firstWhere((p) => p.id == '3'), // IAM Amazing Organic Barley Gummies
      ];
}
