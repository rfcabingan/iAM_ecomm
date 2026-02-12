import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/features/personalization/screens/address/add_new_address.dart';
import 'package:iam_ecomm/features/personalization/screens/address/widgets/single_address.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class UserAddressScreen extends StatelessWidget {
  const UserAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddNewAddressScreen()),
        child: const Icon(Iconsax.add, color: IAMColors.white),
      ),
      appBar: IAMAppBar(
        showBackArrow: true,
        title: Text(
          'Addresses',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              IAMSingleAddress(selectedAddress: true),
              IAMSingleAddress(selectedAddress: false),
              // IAMSingleAddress(selectedAddress: false),
              // IAMSingleAddress(selectedAddress: false),
              // IAMSingleAddress(selectedAddress: false),
              // IAMSingleAddress(selectedAddress: false),
            ],
          ),
        ),
      ),
    );
  }
}
