import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';

class IAMSettingMenu extends StatelessWidget {
  const IAMSettingMenu({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    this.trailing,
    // required Future<dynamic>? Function() onTap,
    this.onTap,
  });

  final IconData icon;
  final String title, subTitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 28, color: IAMColors.primary),
      title: Text(title, style: Theme.of(context).textTheme.labelMedium),
      subtitle: Text(subTitle, style: Theme.of(context).textTheme.labelMedium),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
