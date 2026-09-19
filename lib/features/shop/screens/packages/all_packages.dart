import 'package:flutter/material.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/custom_shapes/containers/search_bar.dart';
import 'package:iam_ecomm/common/widgets/layouts/grid_layout.dart';
import 'package:iam_ecomm/common/widgets/loaders/skeleton.dart';
import 'package:iam_ecomm/common/widgets/products/product_cards/package_card.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class AllPackages extends StatefulWidget {
  const AllPackages({super.key, this.initialSearchQuery = ''});

  final String initialSearchQuery;

  @override
  State<AllPackages> createState() => _AllPackagesState();
}

class _AllPackagesState extends State<AllPackages> {
  String _selectedSort = 'Name';
  late final TextEditingController _searchController;
  late String _searchQuery;

  // Package data from API
  List<PackageItem?> _packages = [];
  bool _loadingPackages = false;
  String? _packagesError;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery.trim();
    _searchController = TextEditingController(text: _searchQuery);
    _loadPackages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    setState(() => _loadingPackages = true);
    final res = await ApiMiddleware.packages.getPackages();
    if (mounted) {
      setState(() {
        _loadingPackages = false;
        if (res.success) {
          _packages = res.data ?? [];
          // Sort by packageId for consistent ordering
          _packages.sort((a, b) => a?.packageId.compareTo(b?.packageId ?? 0) ?? 0);
        } else {
          _packagesError = 'Unable to load packages. Please check your internet connection and try again.';
        }
      });
    }
  }

  List<PackageItem?> _sortedPackages(List<PackageItem?> source) {
    final list = List<PackageItem?>.from(source);

    switch (_selectedSort) {
      case 'Higher Price':
        list.sort((a, b) => (b?.packageAmount ?? 0).compareTo(a?.packageAmount ?? 0));
        break;
      case 'Lower Price':
        list.sort((a, b) => (a?.packageAmount ?? 0).compareTo(b?.packageAmount ?? 0));
        break;
      case 'Name':
      default:
        list.sort(
          (a, b) => a?.packageName.toLowerCase().compareTo(
            b?.packageName.toLowerCase() ?? '',
          ) ?? 0,
        );
        break;
    }

    return list;
  }

  List<PackageItem?> _filteredPackages(List<PackageItem?> source) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return source;

    return source.where((package) {
      if (package == null) return false;
      return package.packageName.toLowerCase().contains(query) ||
          package.packageCode.toLowerCase().contains(query) ||
          package.packageDescription.toLowerCase().contains(query);
    }).toList();
  }

  List<String> _packageSuggestions(List<PackageItem?> packages) {
    final seen = <String>{};
    final suggestions = <String>[];
    for (final package in packages) {
      if (package == null) continue;
      final name = package.packageName.trim();
      final normalizedName = name.toLowerCase();
      if (name.isEmpty || seen.contains(normalizedName)) continue;
      seen.add(normalizedName);
      suggestions.add(name);
    }
    return suggestions;
  }

  void _setSearchQuery(String value) {
    setState(() => _searchQuery = value.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: IAMAppBar(
        title: Text(_searchQuery.isEmpty ? 'All Packages' : 'Search Packages'),
        showBackArrow: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            children: [
              IAMSearchBar(
                text: 'Search packages',
                controller: _searchController,
                suggestions: _packageSuggestions(_packages),
                onChanged: _setSearchQuery,
                onSubmitted: _setSearchQuery,
                onSuggestionSelected: _setSearchQuery,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              DropdownButtonFormField<String>(
                initialValue: _selectedSort,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.sort),
                ),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedSort = value;
                  });
                },
                items:
                    [
                          'Name',
                          'Higher Price',
                          'Lower Price',
                        ]
                        .map(
                          (option) => DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              if (_loadingPackages)
                const IAMProductGridSkeleton(itemCount: 6)
              else if (_packagesError != null)
                Padding(
                  padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                  child: Column(
                    children: [
                      Text(
                        _packagesError!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: IAMSizes.sm),
                      ElevatedButton(
                        onPressed: _loadPackages,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              else if (_packages.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                  child: Text(
                    'No packages available at the moment. Please check back later.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Builder(
                  builder: (context) {
                    final list = _sortedPackages(_filteredPackages(_packages));
                    if (list.isEmpty) {
                      final message = _searchQuery.isEmpty
                          ? 'No packages available'
                          : 'No packages found for "$_searchQuery"';
                      return Padding(
                        padding: const EdgeInsets.all(IAMSizes.defaultSpace),
                        child: Text(
                          message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return IAMGridLayout(
                      itemCount: list.length,
                      itemBuilder: (_, index) {
                        final package = list[index];
                        if (package == null) return const SizedBox.shrink();
                        return IAMPackageCard(package: package);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
