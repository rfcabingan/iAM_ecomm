import 'package:iam_ecomm/utils/api/responses/response_prep.dart';

enum OrderKind { product, package, unknown }

OrderKind orderKindFromType(String orderType) {
  switch (orderType.trim().toUpperCase()) {
    case 'PACKAGE':
      return OrderKind.package;
    case 'PRODUCT':
      return OrderKind.product;
    default:
      return OrderKind.unknown;
  }
}

extension OrderItemKindX on OrderItem {
  OrderKind get kind {
    final fromType = orderKindFromType(orderType);
    if (fromType != OrderKind.unknown) return fromType;
    if (packageName.isNotEmpty || packageCode.isNotEmpty) {
      return OrderKind.package;
    }
    return OrderKind.product;
  }

  bool get isPackageOrder => kind == OrderKind.package;
}

class OrderPackageDisplay {
  const OrderPackageDisplay({
    required this.packageName,
    required this.optionName,
    required this.imageUrl,
  });

  final String packageName;
  final String optionName;
  final String imageUrl;
}

extension OrderDetailItemKindX on OrderDetailItem {
  OrderKind get kind {
    final fromType = orderKindFromType(orderType);
    if (fromType != OrderKind.unknown) return fromType;
    if (packageName.isNotEmpty || packageCode.isNotEmpty) {
      return OrderKind.package;
    }
    return OrderKind.product;
  }

  bool get isPackageOrder => kind == OrderKind.package;

  OrderPackageDisplay get packageDisplay {
    OrderProductItem? firstItem;
    for (final item in items) {
      if (item != null) {
        firstItem = item;
        break;
      }
    }

    return OrderPackageDisplay(
      packageName: packageName.isNotEmpty
          ? packageName
          : (firstItem?.productName ?? ''),
      optionName: optionName.isNotEmpty ? optionName : '',
      imageUrl: _firstNonEmptyImage(imageUrl, firstItem?.imageUrl ?? ''),
    );
  }
}

String _firstNonEmptyImage(String a, String b) {
  if (a.trim().isNotEmpty) return a.trim();
  if (b.trim().isNotEmpty) return b.trim();
  return '';
}
