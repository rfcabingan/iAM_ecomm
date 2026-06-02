class ImageItem {
  final int autoId;
  final String imageType;
  final String imageName;
  final String description;
  final String filePath;
  final bool isVisible;
  final int sortOrder;

  ImageItem({
    required this.autoId,
    required this.imageType,
    required this.imageName,
    required this.description,
    required this.filePath,
    required this.isVisible,
    required this.sortOrder,
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      autoId: json['autoId'] as int,
      imageType: json['imageType'] as String,
      imageName: json['imageName'] as String,
      description: json['description'] as String,
      filePath: json['filePath'] as String,
      isVisible: json['isVisible'] as bool,
      sortOrder: json['sortOrder'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'autoId': autoId,
    'imageType': imageType,
    'imageName': imageName,
    'description': description,
    'filePath': filePath,
    'isVisible': isVisible,
    'sortOrder': sortOrder,
  };
}
