import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/features/shop/controllers/products/checkout_controller.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMBillingPaymentSection extends StatelessWidget {
  const IAMBillingPaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CheckoutController());
    
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Column(
      children: [
        IAMSectionHeading(title: 'Payment Method', buttonTitle: 'Change', onPressed: () => controller.selectPaymentMethod(context),),
        const SizedBox(height: IAMSizes.spaceBtwItems / 2,),
        Obx(
          () => Row(
            children: [
              IAMRoundedContainer(
                width: 60,
                height: 35,
                backgroundColor: dark ? IAMColors.light : IAMColors.white,
                padding: const EdgeInsets.all(IAMSizes.sm),
                child: Image(image: AssetImage(controller.selectedPaymentMethod.value.image), fit: BoxFit.contain),
              ),
              const SizedBox(width: IAMSizes.spaceBtwItems / 2),
              Text(controller.selectedPaymentMethod.value.name, style: Theme.of(context).textTheme.bodyLarge,), 
            ],
          ),
        )
      ],
    );
  }
}