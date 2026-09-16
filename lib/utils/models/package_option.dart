class PackageOption {
  final String name;
  final String image;
  final num price;
  final String description;
  final List<PackageSelectionOption> selectionOptions;

  PackageOption({
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    required this.selectionOptions,
  });
}

class PackageSelectionOption {
  final String id;
  final String name;
  final num price;
  final List<PackageProduct> products;

  PackageSelectionOption({
    required this.id,
    required this.name,
    required this.price,
    required this.products,
  });
}

class PackageProduct {
  final String productCode;
  final String productName;
  final int quantity;
  final String? imageUrl;

  PackageProduct({
    required this.productCode,
    required this.productName,
    required this.quantity,
    this.imageUrl,
  });
}