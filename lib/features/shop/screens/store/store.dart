import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/products.cart/cart_menu_icon.dart';

class Store extends StatelessWidget {
  const Store({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IAMAppBar(
        title: Text('Store'),
        actions: [IAMCartCounterIcon(onPressed: () {})],
      ),
    );
  }
}
