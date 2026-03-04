class IAMProductModel {
  final String id;
  final String title;
  final String brand;
  final String imageUrl;
  final double price;
  final double? discountPercentage;
  final bool isPackage;

  IAMProductModel({
    required this.id,
    required this.title,
    required this.brand,
    required this.imageUrl,
    required this.price,
    this.discountPercentage,
    this.isPackage = false,
  });

  static IAMProductModel empty() => IAMProductModel(
        id: '',
        title: '',
        brand: '',
        imageUrl: '',
        price: 0.0,
      );
}