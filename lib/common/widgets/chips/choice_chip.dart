import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/circular_container.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';

class IAMChoiceChip extends StatelessWidget {
  const IAMChoiceChip({
    super.key,
    required this.text,    
    required this.selected,
    this.onSelected,
  });

  final String text;
  final bool selected;
  final void Function(bool)? onSelected;

  @override
  Widget build(BuildContext context) {
    final isColor = IAMHelperFunctions.getColor(text) != null;

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: ChoiceChip(
        label: isColor ? const SizedBox() : Text(text),
        selected: selected,
        onSelected: onSelected,
        labelStyle: TextStyle(color: selected ? IAMColors.white : null),
        avatar: isColor ? IAMCircularContainer(width: 50, height: 50, backgroundColor: IAMHelperFunctions.getColor(text)!) : null,
        shape: isColor ? const CircleBorder() : null,
        labelPadding: isColor ? const EdgeInsets.all(0) : null,
        padding: isColor ? const EdgeInsets.all(0) : null,
        backgroundColor: isColor ? IAMHelperFunctions.getColor(text)! : null,
      ),
    );
  }
}