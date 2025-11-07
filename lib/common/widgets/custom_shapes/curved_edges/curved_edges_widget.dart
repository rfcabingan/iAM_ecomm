import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/curved_edges/curved_edges.dart';

class IAMCurvedEdgeWidget extends StatelessWidget {
  const IAMCurvedEdgeWidget({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(clipper: IAMCustomCurvedEdges(), child: child);
  }
}
