import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/images/iam_circular_image.dart';
import 'package:iam_ecomm/features/personalization/screens/profile/widgets/profile_information.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const IAMAppBar(showBackArrow: true, title: Text('Profile')),
      //Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              //Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const IAMCircularImage(
                      image: IAMImages.pandauser,
                      width: 80,
                      height: 80,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Change Profile Picture'),
                    ),
                  ],
                ),
              ),

              //Details
              const SizedBox(height: IAMSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              IAMSectionHeading(
                title: 'Profile Information',
                showActionButton: false,
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),

              ProfileInformation(
                title: 'Name',
                value: 'IAM User',
                onPressed: () {},
              ),
              ProfileInformation(
                title: 'Username',
                value: '@iamusername',
                onPressed: () {},
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: IAMSizes.spaceBtwItems),

              //Heading Personal Info
              const IAMSectionHeading(
                title: 'Personal Information',
                showActionButton: false,
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),

              ProfileInformation(
                title: 'User ID',
                value: 'IU0092131',
                icon: Iconsax.copy,
                onPressed: () {},
              ),
              ProfileInformation(
                title: 'Email',
                value: 'iamuser@email.com',
                onPressed: () {},
              ),
              ProfileInformation(
                title: 'Phone Number',
                value: '+639191234561',
                onPressed: () {},
              ),
              ProfileInformation(
                title: 'Gender',
                value: 'Male',
                onPressed: () {},
              ),
              ProfileInformation(
                title: 'Date of Birth',
                value: '10 Oct, 2000',
                onPressed: () {},
              ),
              const Divider(),
              const SizedBox(height: IAMSizes.spaceBtwItems),

              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
