import 'package:flutter/material.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/device/device_utility.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

class IAMSearchBar extends StatefulWidget {
  const IAMSearchBar({
    super.key,
    required this.text,
    this.icon = Iconsax.search_normal,
    this.showBackground = true,
    this.showBorder = true,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onSuggestionSelected,
    this.controller,
    this.suggestions = const [],
    this.maxSuggestions = 5,
    this.padding = const EdgeInsets.symmetric(
      horizontal: IAMSizes.defaultSpace,
    ),
  });

  final String text;
  final IconData? icon;
  final bool showBackground, showBorder;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onSuggestionSelected;
  final TextEditingController? controller;
  final List<String> suggestions;
  final int maxSuggestions;
  final EdgeInsetsGeometry padding;

  @override
  State<IAMSearchBar> createState() => _IAMSearchBarState();
}

class _IAMSearchBarState extends State<IAMSearchBar> {
  late TextEditingController _controller;
  late final FocusNode _focusNode;
  late bool _ownsController;
  final _fieldKey = GlobalKey();
  final _layerLink = LayerLink();
  OverlayEntry? _suggestionsOverlay;
  String _query = '';

  bool get _isInteractive =>
      widget.controller != null ||
      widget.onChanged != null ||
      widget.onSubmitted != null ||
      widget.onSuggestionSelected != null ||
      widget.suggestions.isNotEmpty;

  List<String> get _matchingSuggestions {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return const [];

    final seen = <String>{};
    final matches = <String>[];
    for (final suggestion in widget.suggestions) {
      final trimmed = suggestion.trim();
      final normalizedSuggestion = trimmed.toLowerCase();
      if (trimmed.isEmpty ||
          seen.contains(normalizedSuggestion) ||
          !normalizedSuggestion.contains(normalizedQuery)) {
        continue;
      }

      seen.add(normalizedSuggestion);
      matches.add(trimmed);
      if (matches.length >= widget.maxSuggestions) break;
    }

    return matches;
  }

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _query = _controller.text;
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant IAMSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) _controller.dispose();
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? TextEditingController(text: _query);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncSuggestionsOverlay();
    });
  }

  @override
  void dispose() {
    _removeSuggestionsOverlay();
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!mounted) return;
    setState(() {});
    if (_focusNode.hasFocus) {
      _syncSuggestionsOverlay();
      return;
    }

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted && !_focusNode.hasFocus) _removeSuggestionsOverlay();
    });
  }

  void _handleChanged(String value) {
    setState(() => _query = value);
    widget.onChanged?.call(value);
    _syncSuggestionsOverlay();
  }

  void _submit(String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    _removeSuggestionsOverlay();
    _focusNode.unfocus();
    widget.onSubmitted?.call(query);
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    _controller.selection = TextSelection.collapsed(offset: suggestion.length);
    setState(() => _query = suggestion);
    _removeSuggestionsOverlay();
    widget.onSuggestionSelected?.call(suggestion);
    _focusNode.unfocus();
  }

  void _syncSuggestionsOverlay() {
    if (!_focusNode.hasFocus || _matchingSuggestions.isEmpty) {
      _removeSuggestionsOverlay();
      return;
    }

    if (_suggestionsOverlay == null) {
      _suggestionsOverlay = OverlayEntry(builder: _buildSuggestionsOverlay);
      Overlay.of(context).insert(_suggestionsOverlay!);
    } else {
      _suggestionsOverlay!.markNeedsBuild();
    }
  }

  void _removeSuggestionsOverlay() {
    _suggestionsOverlay?.remove();
    _suggestionsOverlay = null;
  }

  Widget _buildSuggestionsOverlay(BuildContext context) {
    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final fieldSize = renderBox?.size ?? Size.zero;
    final dark = IAMHelperFunctions.isDarkMode(context);
    final suggestions = _matchingSuggestions;

    if (fieldSize == Size.zero || suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: const Offset(0, IAMSizes.xs),
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.transparent,
              elevation: IAMSizes.cardElevation,
              borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: fieldSize.width,
                  maxHeight: 280,
                ),
                child: Container(
                  width: fieldSize.width,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: dark ? IAMColors.dark : IAMColors.white,
                    borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
                    border: Border.all(color: IAMColors.grey),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: suggestions.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: IAMSizes.dividerHeight),
                    itemBuilder: (_, index) {
                      final suggestion = suggestions[index];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Iconsax.search_normal),
                        title: Text(
                          suggestion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _selectSuggestion(suggestion),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Padding(
      padding: widget.padding,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          key: _fieldKey,
          width: IAMDeviceUtils.getScreenWidth(context),
          padding: const EdgeInsets.symmetric(horizontal: IAMSizes.md),
          decoration: BoxDecoration(
            color: widget.showBackground
                ? dark
                      ? IAMColors.dark
                      : IAMColors.light
                : Colors.transparent,
            borderRadius: BorderRadius.circular(IAMSizes.cardRadiusLg),
            border: widget.showBorder
                ? Border.all(color: IAMColors.grey)
                : null,
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: dark ? IAMColors.darkGrey : Colors.grey),
              const SizedBox(width: IAMSizes.spaceBtwItems),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: !_isInteractive,
                  onTap: widget.onTap,
                  onChanged: _handleChanged,
                  onSubmitted: _submit,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: widget.text,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: IAMSizes.md,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              if (_query.isNotEmpty && _isInteractive)
                IconButton(
                  onPressed: () {
                    _controller.clear();
                    _handleChanged('');
                    _focusNode.requestFocus();
                  },
                  icon: const Icon(Iconsax.close_circle),
                  color: dark ? IAMColors.darkGrey : Colors.grey,
                  tooltip: 'Clear search',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
