import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMCouponCode extends StatelessWidget {
  const IAMCouponCode({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return IAMRoundedContainer(
      showBorder: true,
      backgroundColor: dark ? IAMColors.dark : IAMColors.white,
      padding: const EdgeInsets.only(top: IAMSizes.sm, bottom: IAMSizes.sm, right: IAMSizes.sm, left: IAMSizes.md),
      child: Row(
        children: [
          Flexible(
            //TEXTFIELD
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Have a Referral ID? Enter here.',
                hintStyle: TextStyle(
                  color: dark ? IAMColors.darkGrey : Colors.grey,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                foregroundColor: dark ? IAMColors.white.withOpacity(0.5) : IAMColors.dark.withOpacity(0.5),
                backgroundColor: Colors.grey.withOpacity(0.5),
                side: BorderSide(color: Colors.grey.withOpacity(0.1)),
              ), 
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}