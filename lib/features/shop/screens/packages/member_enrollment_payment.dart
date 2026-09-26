import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/common/widgets/container/rounded_container.dart';
import 'package:iam_ecomm/common/widgets/images/iam_rounded_images.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/billing_address_section.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/billing_fulfillment_section.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/widget/delivery_timeline_note.dart';
import 'package:iam_ecomm/features/shop/screens/packages/member_enrollment_review.dart';
import 'package:iam_ecomm/features/shop/screens/packages/package_registration.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/constants/image_strings.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/formatters/formatter.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/utils/models/member_enrollment_info.dart';
import 'package:iconsax/iconsax.dart';

class MemberEnrollmentPaymentScreen extends StatefulWidget {
  const MemberEnrollmentPaymentScreen({
    super.key,
    required this.package,
    required this.selectedOption,
    required this.memberInfo,
    required this.enrollmentAddress,
    this.optionItems,
  });

  final PackageItem package;
  final PackageOptionItem selectedOption;
  final MemberEnrollmentInfo memberInfo;
  final AddressItem enrollmentAddress;
  final List<PackageOptionItemDetail?>? optionItems;

  @override
  State<MemberEnrollmentPaymentScreen> createState() =>
      _MemberEnrollmentPaymentScreenState();
}

class _MemberEnrollmentPaymentScreenState
    extends State<MemberEnrollmentPaymentScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  static final List<FulfillmentTypeItem> _fallbackFulfillmentTypes = [
    FulfillmentTypeItem(
      fulfillmentTypeId: 1,
      fulfillmentTypeCode: 'DELIVERY',
      fulfillmentTypeName: 'Delivery',
    ),
    FulfillmentTypeItem(
      fulfillmentTypeId: 2,
      fulfillmentTypeCode: 'PICKUP',
      fulfillmentTypeName: 'Pickup',
    ),
  ];

  static final List<BranchItem> _fallbackBranches = [
    BranchItem(areaCode: '000', areaName: 'MAIN'),
    BranchItem(areaCode: '104', areaName: 'ANTIPOLO'),
    BranchItem(areaCode: '101', areaName: 'CEBU'),
    BranchItem(areaCode: '102', areaName: 'DAVAO'),
  ];

  List<FulfillmentTypeItem> _fulfillmentTypes = const [];
  List<BranchItem> _branches = const [];
  String _selectedFulfillmentTypeCode = 'DELIVERY';
  String? _selectedBranchAreaCode;
  bool _isLoadingFulfillment = false;

  List<PaymentProviderItem> _paymentProviders = [];
  PaymentProviderItem? _selectedPaymentProvider;
  bool _loadingPaymentProviders = false;
  String? _paymentError;

  AddressItem? _selectedAddress;

  String? _idImagePath;
  File? _idImageFile;
  Uint8List? _idImageBytes;
  String? _idImageFileName;
  String? _idImageBase64;
  bool _termsAccepted = false;

  bool _isComputingFees = false;
  String? _feesError;
  PackageComputeFeesData? _feesData;
  int _feeRequestId = 0;

  bool get _isPickupSelected =>
      _isPickupFulfillmentCode(_selectedFulfillmentTypeCode);

  bool get _isHomeDeliverySelected => !_isPickupSelected;

  int? get _selectedFulfillmentTypeId {
    final selectedCode = _selectedFulfillmentTypeCode.trim().toUpperCase();
    for (final type in _fulfillmentTypes) {
      if (type.fulfillmentTypeCode.trim().toUpperCase() == selectedCode) {
        return type.fulfillmentTypeId;
      }
    }
    return null;
  }

  BranchItem? get _selectedBranch {
    final code = _selectedBranchAreaCode?.trim();
    if (code == null || code.isEmpty) return null;
    for (final branch in _branches) {
      if (branch.areaCode.trim() == code) return branch;
    }
    return null;
  }

  AddressItem get _addressForFees {
    if (_isHomeDeliverySelected && _selectedAddress != null) {
      return _selectedAddress!;
    }
    return widget.enrollmentAddress;
  }

  bool get _canComputeFees {
    if (_selectedPaymentProvider == null || _selectedFulfillmentTypeId == null) {
      return false;
    }
    if (_isPickupSelected &&
        (_selectedBranchAreaCode == null ||
            _selectedBranchAreaCode!.trim().isEmpty)) {
      return false;
    }
    if (_isHomeDeliverySelected && _addressForFees.country.trim().isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _refreshComputedFees() async {
    if (!_canComputeFees) {
      setState(() {
        _feesData = null;
        _feesError = null;
        _isComputingFees = false;
      });
      return;
    }

    final requestId = ++_feeRequestId;
    setState(() {
      _isComputingFees = true;
      _feesError = null;
    });

    try {
      final address = _addressForFees;
      final res = await ApiMiddleware.packages.computeFees(
        packageCode: widget.package.packageCode,
        optionId: widget.selectedOption.optionId,
        paymentMethodId: _selectedPaymentProvider!.autoId,
        fulfillmentTypeId: _selectedFulfillmentTypeId!,
        country: address.country,
        province: address.province,
        city: address.city,
        barangay: address.barangay,
        areaCode: _isPickupSelected ? _selectedBranchAreaCode : null,
      );
      if (!mounted || requestId != _feeRequestId) return;

      setState(() {
        _isComputingFees = false;
        if (res.success && res.data != null) {
          _feesData = res.data;
          _feesError = null;
        } else {
          _feesData = null;
          _feesError = res.message.isNotEmpty
              ? res.message
              : 'Failed to compute fees. Please try again.';
        }
      });
    } catch (e) {
      if (!mounted || requestId != _feeRequestId) return;
      setState(() {
        _isComputingFees = false;
        _feesData = null;
        _feesError = 'An error occurred: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.enrollmentAddress;
    _loadFulfillmentOptions();
    _loadPaymentProviders();
  }

  bool _isPickupFulfillmentCode(String fulfillmentCode) {
    final normalizedCode = fulfillmentCode.trim().toUpperCase();
    if (normalizedCode.isEmpty) return false;
    final matchedType = _fulfillmentTypes.where((type) {
      return type.fulfillmentTypeCode.trim().toUpperCase() == normalizedCode;
    }).toList();
    if (matchedType.isNotEmpty) {
      final item = matchedType.first;
      final code = item.fulfillmentTypeCode.trim().toUpperCase();
      final name = item.fulfillmentTypeName.trim().toUpperCase();
      return item.fulfillmentTypeId == 2 ||
          code == 'PICKUP' ||
          name.contains('PICKUP');
    }
    return normalizedCode == 'PICKUP';
  }

  Future<void> _loadFulfillmentOptions() async {
    setState(() => _isLoadingFulfillment = true);
    try {
      final fulfillmentRes = await ApiMiddleware.fulfillment.getFulfillmentTypes();
      final branchesRes = await ApiMiddleware.fulfillment.getBranches();
      if (!mounted) return;

      final fulfillmentItems = fulfillmentRes.data
              ?.whereType<FulfillmentTypeItem>()
              .where((item) => item.fulfillmentTypeCode.trim().isNotEmpty)
              .toList() ??
          const <FulfillmentTypeItem>[];
      final branchItems =
          branchesRes.data?.whereType<BranchItem>().toList() ??
          const <BranchItem>[];

      final typesToUse = fulfillmentItems.isNotEmpty
          ? fulfillmentItems
          : _fallbackFulfillmentTypes;
      final deliveryOption = typesToUse.where((item) {
        return item.fulfillmentTypeCode.trim().toUpperCase() == 'DELIVERY';
      }).toList();
      final defaultTypeCode = deliveryOption.isNotEmpty
          ? deliveryOption.first.fulfillmentTypeCode.trim()
          : typesToUse.first.fulfillmentTypeCode.trim();

      setState(() {
        _fulfillmentTypes = typesToUse;
        _branches = branchItems.isNotEmpty ? branchItems : _fallbackBranches;
        _selectedFulfillmentTypeCode = defaultTypeCode;
        if (!_isPickupSelected) {
          _selectedBranchAreaCode = null;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _fulfillmentTypes = _fallbackFulfillmentTypes;
        _branches = _fallbackBranches;
        _selectedFulfillmentTypeCode = 'DELIVERY';
        _selectedBranchAreaCode = null;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingFulfillment = false);
        _refreshComputedFees();
      }
    }
  }

  Future<void> _loadBranchesIfNeeded() async {
    if (_branches.isNotEmpty) return;
    final branchesRes = await ApiMiddleware.fulfillment.getBranches();
    if (!mounted) return;
    setState(() {
      _branches =
          branchesRes.data?.whereType<BranchItem>().toList() ?? _fallbackBranches;
    });
  }

  Future<void> _loadPaymentProviders() async {
    setState(() {
      _loadingPaymentProviders = true;
      _paymentError = null;
    });
    final res = await ApiMiddleware.payment.getPaymentProviders();
    if (!mounted) return;

    final providers = (res.data ?? [])
        .whereType<PaymentProviderItem>()
        .where((provider) => provider.isActive)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    setState(() {
      _loadingPaymentProviders = false;
      if (!res.success) {
        _paymentError = res.message.isNotEmpty
            ? res.message
            : 'Unable to load payment providers.';
        _paymentProviders = [];
      } else if (providers.isEmpty) {
        _paymentError = 'No payment providers available.';
        _paymentProviders = [];
      } else {
        _paymentProviders = providers;
      }
    });
  }

  Future<void> _showPaymentSelector() async {
    if (_paymentProviders.isEmpty) {
      await _loadPaymentProviders();
      if (_paymentProviders.isEmpty || !mounted) return;
    }

    final selected = await showModalBottomSheet<PaymentProviderItem>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.all(IAMSizes.md),
            itemCount: _paymentProviders.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: IAMSizes.spaceBtwItems),
            itemBuilder: (context, index) {
              final provider = _paymentProviders[index];
              final isSelected =
                  _selectedPaymentProvider?.providerCode == provider.providerCode;
              return ListTile(
                leading: SizedBox(
                  width: 48,
                  height: 28,
                  child: _PaymentProviderIcon(provider: provider),
                ),
                title: Text(provider.providerName),
                subtitle: Text(provider.providerCode),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: IAMColors.primary)
                    : const Icon(Icons.radio_button_unchecked),
                onTap: () => Navigator.of(context).pop(provider),
              );
            },
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _selectedPaymentProvider = selected);
      _refreshComputedFees();
    }
  }

  Future<void> _pickIDImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final fileSize = await image.length();
        const maxSize = 5 * 1024 * 1024;
        if (fileSize > maxSize) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size must be less than 5MB'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final bytes = await image.readAsBytes();
        setState(() {
          _idImagePath = kIsWeb ? null : image.path;
          _idImageFile = !kIsWeb ? File(image.path) : null;
          _idImageBytes = bytes;
          _idImageFileName = image.name;
          _idImageBase64 = IAMHelperFunctions.bytesToBase64(bytes);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Valid ID'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickIDImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickIDImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _continue() {
    if (_selectedPaymentProvider == null) {
      _snack('Please select a payment provider');
      return;
    }
    if (_selectedFulfillmentTypeCode.trim().isEmpty ||
        _selectedFulfillmentTypeId == null) {
      _snack('Please select a fulfillment type');
      return;
    }
    if (_isPickupSelected &&
        (_selectedBranchAreaCode == null ||
            _selectedBranchAreaCode!.trim().isEmpty)) {
      _snack('Please select a branch for pickup');
      return;
    }
    if (_isHomeDeliverySelected && _addressForFees.country.trim().isEmpty) {
      _snack('Please select a shipping address');
      return;
    }
    if (!_termsAccepted) {
      _snack('Please accept the terms and conditions');
      return;
    }
    if (_idImagePath == null && _idImageBytes == null) {
      _snack('Please upload your valid ID');
      return;
    }
    if (_isComputingFees) {
      _snack('Please wait while fees are computed');
      return;
    }
    if (_feesData == null) {
      _snack('Please wait for fees to be computed, or retry after selecting payment and fulfillment');
      return;
    }
    _showConfirmationScreen();
  }

  void _showConfirmationScreen() {
    if (_feesData == null || _selectedPaymentProvider == null) return;

    final fulfillmentLabel = _isPickupSelected
        ? 'Pickup${_selectedBranch == null ? '' : ' · ${_selectedBranch!.areaName}'}'
        : 'Home delivery';

    Get.to(
      () => MemberEnrollmentReviewScreen(
        package: widget.package,
        selectedOption: widget.selectedOption,
        memberInfo: widget.memberInfo,
        address: _addressForFees,
        paymentMethodName: _selectedPaymentProvider!.providerName,
        fulfillmentLabel: fulfillmentLabel,
        feesData: _feesData!,
        idImageBytes: _idImageBytes,
        idImageFile: _idImageFile == null ? null : FileImage(_idImageFile!),
        onEditDetails: () => Get.back(),
        onEditMemberDetails: () {
          Get.back();
          Get.back();
        },
        onProceed: _proceedToRegistration,
      ),
    );
  }

  void _proceedToRegistration() {
    if (_feesData == null) return;

    final memberInfo = MemberEnrollmentInfo(
      firstName: widget.memberInfo.firstName,
      middleName: widget.memberInfo.middleName,
      lastName: widget.memberInfo.lastName,
      email: widget.memberInfo.email,
      phone: widget.memberInfo.phone,
      birthdate: widget.memberInfo.birthdate,
      gender: widget.memberInfo.gender,
      idImagePath: _idImagePath,
      idImageBase64: _idImageBase64,
      idImageBytes: _idImageBytes,
      idImageFileName: _idImageFileName,
      sponsorIdno: widget.memberInfo.sponsorIdno,
      paymentMethodId: _selectedPaymentProvider?.autoId,
      fulfillmentTypeId: _selectedFulfillmentTypeId,
      areaCode: _isPickupSelected ? _selectedBranchAreaCode : null,
      termsAccepted: _termsAccepted,
    );

    Get.to(() => PackageRegistrationScreen(
      package: widget.package,
      selectedOption: widget.selectedOption,
      memberInfo: memberInfo,
      enrollmentAddress: _addressForFees,
      optionItems: widget.optionItems,
      feesData: _feesData!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: IAMAppBar(
        showBackArrow: true,
        title: const Text('Payment & Fulfillment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(IAMSizes.md),
                decoration: BoxDecoration(
                  color: dark ? IAMColors.dark : Colors.grey[100],
                  borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.package.packageName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: IAMSizes.sm),
                    Text('Selected: ${widget.selectedOption.optionName}'),
                    Text(
                      'Enrollee: ${widget.memberInfo.fullName}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              TextFormField(
                initialValue: widget.memberInfo.sponsorIdno,
                decoration: const InputDecoration(
                  labelText: 'Sponsor ID',
                  prefixIcon: Icon(Iconsax.user),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.grey,
                ),
                readOnly: true,
                style: TextStyle(
                  color: widget.memberInfo.sponsorIdno != null
                      ? Colors.black
                      : Colors.grey,
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              IAMRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(IAMSizes.md),
                backgroundColor: dark ? IAMColors.black : IAMColors.white,
                child: Column(
                  children: [
                    IAMBillingFulfillmentSection(
                      isLoading: _isLoadingFulfillment,
                      fulfillmentTypes: _fulfillmentTypes,
                      selectedFulfillmentTypeCode: _selectedFulfillmentTypeCode,
                      isPickupSelected: _isPickupSelected,
                      branches: _branches,
                      selectedBranchAreaCode: _selectedBranchAreaCode,
                      onFulfillmentChanged: (code) {
                        final normalizedCode = code.trim();
                        setState(() {
                          _selectedFulfillmentTypeCode = normalizedCode;
                          if (!_isPickupFulfillmentCode(normalizedCode)) {
                            _selectedBranchAreaCode = null;
                          }
                        });
                        if (_isPickupFulfillmentCode(normalizedCode)) {
                          _loadBranchesIfNeeded();
                        }
                        _refreshComputedFees();
                      },
                      onBranchChanged: (areaCode) {
                        setState(() => _selectedBranchAreaCode = areaCode);
                        _refreshComputedFees();
                      },
                    ),
                    if (_isHomeDeliverySelected) ...[
                      const SizedBox(height: IAMSizes.spaceBtwItems),
                      const IAMDeliveryTimelineNote(),
                      const SizedBox(height: IAMSizes.spaceBtwItems),
                      IAMBillingAddressSection(
                        fallbackAddress: widget.enrollmentAddress,
                        onAddressSelected: (addr) {
                          setState(() {
                            _selectedAddress = addr ?? widget.enrollmentAddress;
                          });
                          _refreshComputedFees();
                        },
                      ),
                    ],
                    const SizedBox(height: IAMSizes.spaceBtwItems),
                    _EnrollmentPaymentMethodSection(
                      loading: _loadingPaymentProviders,
                      error: _paymentError,
                      selected: _selectedPaymentProvider,
                      onSelect: _showPaymentSelector,
                      onRetry: _loadPaymentProviders,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              Row(
                children: [
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: (value) {
                      setState(() => _termsAccepted = value ?? false);
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _termsAccepted = !_termsAccepted);
                      },
                      child: const Text(
                        'I accept the terms and conditions',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              const IAMSectionHeading(
                title: 'Valid ID Upload',
                showActionButton: false,
              ),
              const SizedBox(height: IAMSizes.spaceBtwItems),
              GestureDetector(
                onTap: _showImagePickerDialog,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: dark ? IAMColors.dark : Colors.grey[100],
                    borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
                    border: Border.all(
                      color: _idImagePath != null || _idImageBytes != null
                          ? IAMColors.primary
                          : (dark ? Colors.grey : Colors.grey),
                      width: _idImagePath != null || _idImageBytes != null
                          ? 2
                          : 1,
                    ),
                  ),
                  child: _idImagePath != null || _idImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            IAMSizes.cardRadiusMd,
                          ),
                          child: _idImageBytes != null
                              ? Image.memory(_idImageBytes!, fit: BoxFit.cover)
                              : Image.file(_idImageFile!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.camera,
                              size: 48,
                              color: dark ? Colors.grey : Colors.grey[600],
                            ),
                            const SizedBox(height: IAMSizes.sm),
                            Text(
                              'Tap to upload Valid ID',
                              style: TextStyle(
                                color: dark ? Colors.grey : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: IAMSizes.xs),
                            Text(
                              'Camera or Gallery',
                              style: TextStyle(
                                fontSize: 12,
                                color: dark ? Colors.grey : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              IAMRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(IAMSizes.md),
                backgroundColor: dark ? IAMColors.black : IAMColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fee Breakdown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: IAMSizes.md),
                    if (_isComputingFees)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: IAMSizes.md),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: IAMSizes.sm),
                              Text('Computing fees...'),
                            ],
                          ),
                        ),
                      )
                    else if (_feesError != null)
                      Column(
                        children: [
                          Text(
                            _feesError!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: IAMSizes.sm),
                          ElevatedButton(
                            onPressed: _refreshComputedFees,
                            child: const Text('Retry'),
                          ),
                        ],
                      )
                    else if (_feesData == null)
                      Text(
                        'Select payment method and fulfillment to see fees.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: dark ? IAMColors.grey : IAMColors.textSecondary,
                        ),
                      )
                    else ...[
                      _FeeRow(label: 'Package Amount', value: _feesData!.packageAmount),
                      const SizedBox(height: IAMSizes.sm),
                      _FeeRow(label: 'Shipping Amount', value: _feesData!.shippingAmount),
                      const SizedBox(height: IAMSizes.sm),
                      _FeeRow(label: 'Processing Fee', value: _feesData!.processingFee),
                      const SizedBox(height: IAMSizes.sm),
                      _FeeRow(label: 'Discount Amount', value: _feesData!.discountAmount),
                      const Divider(height: IAMSizes.md),
                      _FeeRow(
                        label: 'Total Amount',
                        value: _feesData!.totalAmount,
                        isBold: true,
                        color: IAMColors.primary,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: IAMColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: IAMSizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnrollmentPaymentMethodSection extends StatelessWidget {
  const _EnrollmentPaymentMethodSection({
    required this.loading,
    required this.error,
    required this.selected,
    required this.onSelect,
    required this.onRetry,
  });

  final bool loading;
  final String? error;
  final PaymentProviderItem? selected;
  final VoidCallback onSelect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);
    final hasSelection = selected != null;

    if (loading) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error!),
          const SizedBox(height: IAMSizes.sm),
          TextButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Payment Provider',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19),
            ),
            GestureDetector(
              onTap: onSelect,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: IAMColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hasSelection ? 'Change' : 'Select',
                  style: const TextStyle(
                    color: IAMColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: IAMSizes.spaceBtwItems / 2),
        Row(
          children: [
            IAMRoundedContainer(
              width: 60,
              height: 35,
              backgroundColor: dark ? IAMColors.darkContainer : IAMColors.white,
              padding: const EdgeInsets.all(IAMSizes.sm),
              child: Center(
                child: hasSelection
                    ? _PaymentProviderIcon(provider: selected!)
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(width: IAMSizes.spaceBtwItems / 2),
            Expanded(
              child: Text(
                hasSelection ? selected!.providerName : 'Select Payment Provider',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: hasSelection ? null : Theme.of(context).hintColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PaymentProviderIcon extends StatelessWidget {
  const _PaymentProviderIcon({required this.provider});

  final PaymentProviderItem provider;

  @override
  Widget build(BuildContext context) {
    final image = _resolveProviderImage(provider);
    final isNetwork =
        provider.imageUrl.isNotEmpty &&
        (image.startsWith('http://') || image.startsWith('https://'));

    return IAMRoundedImage(
      imageUrl: image,
      isNetworkImage: isNetwork,
      fit: BoxFit.contain,
      applyImageRadius: false,
      borderRadius: 0,
    );
  }
}

String _resolveProviderImage(PaymentProviderItem provider) {
  if (provider.imageUrl.isNotEmpty) return provider.imageUrl;
  switch (provider.providerCode.toUpperCase()) {
    case 'IAMWALLET':
      return IAMImages.iamwallet;
    case 'PAYMAYA':
      return IAMImages.maya;
    case 'GCASH':
      return IAMImages.gcash;
    default:
      return IAMImages.iamwallet;
  }
}

class _FeeRow extends StatelessWidget {
  const _FeeRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.color,
  });

  final String label;
  final num value;
  final bool isBold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          IAMFormatter.formatCurrency(value.toDouble()),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
            color: color,
          ),
        ),
      ],
    );
  }
}
