import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iam_ecomm/common/texts/section_heading.dart';
import 'package:iam_ecomm/common/widgets/appbar/appbar.dart';
import 'package:iam_ecomm/features/shop/screens/checkout/checkout.dart';
import 'package:iam_ecomm/utils/api/api.dart';
import 'package:iam_ecomm/utils/api/responses/response_prep.dart';
import 'package:iam_ecomm/utils/constants/sizes.dart';
import 'package:iam_ecomm/utils/constants/colors.dart';
import 'package:iam_ecomm/utils/helpers/helper_functions.dart';
import 'package:iam_ecomm/utils/models/member_enrollment_info.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:io';

class MemberEnrollmentForm extends StatefulWidget {
  const MemberEnrollmentForm({
    super.key,
    required this.package,
    required this.selectedOption,
    this.optionItems,
  });

  final PackageItem package;
  final PackageOptionItem selectedOption;
  final List<PackageOptionItemDetail?>? optionItems;

  @override
  State<MemberEnrollmentForm> createState() => _MemberEnrollmentFormState();
}

class _MemberEnrollmentFormState extends State<MemberEnrollmentForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  // Personal Information Controllers
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLineController = TextEditingController();

  // Dropdown selections
  DateTime? _selectedBirthdate;
  String? _selectedGender;
  CountryItem? _selectedCountry;
  ProvinceItem? _selectedProvince;
  CityItem? _selectedCity;
  BarangayItem? _selectedBarangay;

  // Location data
  List<CountryItem> _countries = [];
  List<ProvinceItem> _provinces = [];
  List<CityItem> _cities = [];
  List<BarangayItem> _barangays = [];

  // Loading states
  bool _loadingCountries = false;
  bool _loadingProvinces = false;
  bool _loadingCities = false;
  bool _loadingBarangays = false;
  final bool _submitting = false;

  // ID Upload
  String? _idImagePath;
  File? _idImageFile;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    super.dispose();
  }

  Future<void> _loadCountries() async {
    setState(() => _loadingCountries = true);
    final res = await ApiMiddleware.location.getCountries();
    if (mounted) {
      setState(() {
        _loadingCountries = false;
        if (res.success) {
          _countries = res.data?.whereType<CountryItem>().toList() ?? [];
        }
      });
    }
  }

  Future<void> _loadProvinces(String country) async {
    setState(() => _loadingProvinces = true);
    final res = await ApiMiddleware.location.getProvinces(country);
    if (mounted) {
      setState(() {
        _loadingProvinces = false;
        if (res.success) {
          _provinces = res.data?.whereType<ProvinceItem>().toList() ?? [];
        }
      });
    }
  }

  Future<void> _loadCities(String country, String province) async {
    setState(() => _loadingCities = true);
    final res = await ApiMiddleware.location.getCities(country, province);
    if (mounted) {
      setState(() {
        _loadingCities = false;
        if (res.success) {
          _cities = res.data?.whereType<CityItem>().toList() ?? [];
        }
      });
    }
  }

  Future<void> _loadBarangays(String country, String province, String city) async {
    setState(() => _loadingBarangays = true);
    final res = await ApiMiddleware.location.getBarangays(country, province, city);
    if (mounted) {
      setState(() {
        _loadingBarangays = false;
        if (res.success) {
          _barangays = res.data?.whereType<BarangayItem>().toList() ?? [];
        }
      });
    }
  }

  void _onCountryChanged(CountryItem? country) {
    setState(() {
      _selectedCountry = country;
      _selectedProvince = null;
      _selectedCity = null;
      _selectedBarangay = null;
      _provinces.clear();
      _cities.clear();
      _barangays.clear();
    });
    if (country != null) {
      _loadProvinces(country.country);
    }
  }

  void _onProvinceChanged(ProvinceItem? province) {
    setState(() {
      _selectedProvince = province;
      _selectedCity = null;
      _selectedBarangay = null;
      _cities.clear();
      _barangays.clear();
    });
    if (province != null && _selectedCountry != null) {
      _loadCities(_selectedCountry!.country, province.province);
    }
  }

  void _onCityChanged(CityItem? city) {
    setState(() {
      _selectedCity = city;
      _selectedBarangay = null;
      _barangays.clear();
    });
    if (city != null && _selectedCountry != null && _selectedProvince != null) {
      _loadBarangays(_selectedCountry!.country, _selectedProvince!.province, city.city);
    }
  }

  void _onBarangayChanged(BarangayItem? barangay) {
    setState(() => _selectedBarangay = barangay);
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
        // Basic validation: check file size (5MB limit)
        final fileSize = await image.length();
        const maxSize = 5 * 1024 * 1024; // 5MB in bytes

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

        // Convert XFile to File
        final file = File(image.path);

        setState(() {
          _idImagePath = image.path;
          _idImageFile = file;
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate required selections
    if (_selectedBirthdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your birthdate'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCountry == null ||
        _selectedProvince == null ||
        _selectedCity == null ||
        _selectedBarangay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the address fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_idImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your valid ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation screen
    _showConfirmationScreen();
  }

  void _showConfirmationScreen() {
    final dark = IAMHelperFunctions.isDarkMode(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Member Enrollment'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Package: ${widget.package.packageName}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Option: ${widget.selectedOption.optionName}'),
              Text('Price: ₱${(widget.selectedOption.price ?? widget.package.packageAmount).toStringAsFixed(2)}'),
              const Divider(),
              const Text('Personal Information', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Name: ${_firstNameController.text} ${_middleNameController.text} ${_lastNameController.text}'),
              Text('Email: ${_emailController.text}'),
              Text('Phone: ${_phoneController.text}'),
              Text('Birthdate: ${_selectedBirthdate!.toString().split(' ')[0]}'),
              Text('Gender: $_selectedGender'),
              const Divider(),
              const Text('Address', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Address Line: ${_addressLineController.text}'),
              Text('Barangay: ${_selectedBarangay!.barangay}'),
              Text('City: ${_selectedCity!.city}'),
              Text('Province: ${_selectedProvince!.province}'),
              Text('Country: ${_selectedCountry!.country}'),
              const Divider(),
              const Text('Valid ID', style: TextStyle(fontWeight: FontWeight.bold)),
              if (_idImagePath != null)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: dark ? Colors.grey : Colors.grey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _idImageFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _proceedToCheckout();
            },
            child: const Text('Confirm & Checkout'),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout() {
    // Create member enrollment info from form data
    final memberInfo = MemberEnrollmentInfo(
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      birthdate: _selectedBirthdate!,
      gender: _selectedGender!,
      idImagePath: _idImagePath,
    );

    // Create address from enrollment form
    final enrollmentAddress = AddressItem(
      autoId: 0, // Temporary ID for enrollment address
      idNo: '', // Will be filled by user ID after registration
      recipientName: memberInfo.fullName,
      mobileNo: memberInfo.phone,
      country: _selectedCountry?.country ?? '',
      province: _selectedProvince?.province ?? '',
      city: _selectedCity?.city ?? '',
      barangay: _selectedBarangay?.barangay ?? '',
      streetAddress: _addressLineController.text.trim(),
      postalCode: '', // Not collected in enrollment form
      completeAddress: '${_addressLineController.text.trim()}, ${_selectedBarangay?.barangay ?? ''}, ${_selectedCity?.city ?? ''}, ${_selectedProvince?.province ?? ''}, ${_selectedCountry?.country ?? ''}',
      isDefault: true,
      isActive: true,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: null,
    );

    // Navigate to checkout with package data
    Get.to(() => CheckoutScreen(
      package: widget.package,
      selectedOption: widget.selectedOption,
      memberInfo: memberInfo,
      enrollmentAddress: enrollmentAddress,
      optionItems: widget.optionItems,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final dark = IAMHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: IAMAppBar(
        showBackArrow: true,
        title: const Text('Member Enrollment'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(IAMSizes.defaultSpace),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Package Summary
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
                      Text('Price: ₱${(widget.selectedOption.price ?? widget.package.packageAmount).toStringAsFixed(2)}'),
                    ],
                  ),
                ),
                const SizedBox(height: IAMSizes.spaceBtwSections),

                // Personal Information Section
                const IAMSectionHeading(
                  title: 'Personal Information',
                  showActionButton: false,
                ),
                const SizedBox(height: IAMSizes.spaceBtwItems),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Iconsax.user),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required Field*';
                          }
                          final normalized = v.trim();
                          final regex = RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$');
                          if (!regex.hasMatch(normalized)) {
                            return 'Only letters are allowed';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: IAMSizes.spaceBtwItems),
                    Expanded(
                      child: TextFormField(
                        controller: _middleNameController,
                        decoration: const InputDecoration(
                          labelText: 'Middle Name',
                          prefixIcon: Icon(Iconsax.user),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
                        ],
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Required Field*';
                          }
                          final normalized = v.trim();
                          final regex = RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$');
                          if (!regex.hasMatch(normalized)) {
                            return 'Only letters are allowed';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: Icon(Iconsax.user),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Required Field*';
                    }
                    final normalized = v.trim();
                    final regex = RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)*$');
                    if (!regex.hasMatch(normalized)) {
                      return 'Only letters are allowed';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Iconsax.direct),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required Field*';
                    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!regex.hasMatch(v)) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile/Contact#',
                    prefixIcon: Icon(Iconsax.call),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required Field*';
                    if (v.length < 7) return 'Phone number looks too short';
                    return null;
                  },
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                // Birthdate Picker
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 18 * 365)),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedBirthdate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: dark ? Colors.grey : Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.calendar, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _selectedBirthdate == null
                              ? 'Select Birthdate'
                              : _selectedBirthdate.toString().split(' ')[0],
                          style: TextStyle(
                            color: _selectedBirthdate == null
                                ? Colors.grey
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                // Gender Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Iconsax.user),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedGender = value);
                  },
                  validator: (v) => v == null ? 'Required Field*' : null,
                ),
                const SizedBox(height: IAMSizes.spaceBtwSections),

                // Address Section
                const IAMSectionHeading(
                  title: 'Address Information',
                  showActionButton: false,
                ),
                const SizedBox(height: IAMSizes.spaceBtwItems),

                // Country Dropdown
                DropdownButtonFormField<CountryItem>(
                  initialValue: _selectedCountry,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.global),
                    labelText: 'Country',
                  ),
                  items: _countries.map((country) {
                    return DropdownMenuItem(
                      value: country,
                      child: Text(country.country),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) return 'Country is required';
                    return null;
                  },
                  onChanged: !_loadingCountries ? _onCountryChanged : null,
                  hint: _loadingCountries
                      ? const Text('Loading countries...')
                      : const Text('Select Country'),
                  disabledHint: const Text('Loading countries...'),
                  isExpanded: true,
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                // Province Dropdown
                DropdownButtonFormField<ProvinceItem>(
                  initialValue: _selectedProvince,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.map),
                    labelText: 'Province',
                  ),
                  items: _provinces.map((province) {
                    return DropdownMenuItem(
                      value: province,
                      child: Text(province.province),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) return 'Province is required';
                    return null;
                  },
                  onChanged: _selectedCountry != null && !_loadingProvinces
                      ? _onProvinceChanged
                      : null,
                  hint: _loadingProvinces
                      ? const Text('Loading provinces...')
                      : const Text('Select Province'),
                  disabledHint: _selectedCountry == null
                      ? const Text('Select a country first')
                      : const Text('Loading provinces...'),
                  isExpanded: true,
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                // City Dropdown
                DropdownButtonFormField<CityItem>(
                  initialValue: _selectedCity,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.building),
                    labelText: 'City',
                  ),
                  items: _cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city.city),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) return 'City is required';
                    return null;
                  },
                  onChanged: _selectedProvince != null && !_loadingCities
                      ? _onCityChanged
                      : null,
                  hint: _loadingCities
                      ? const Text('Loading cities...')
                      : const Text('Select City'),
                  disabledHint: _selectedProvince == null
                      ? const Text('Select a province first')
                      : const Text('Loading cities...'),
                  isExpanded: true,
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                // Barangay Dropdown
                DropdownButtonFormField<BarangayItem>(
                  initialValue: _selectedBarangay,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.location),
                    labelText: 'Barangay',
                  ),
                  items: _barangays.map((barangay) {
                    return DropdownMenuItem(
                      value: barangay,
                      child: Text(barangay.barangay),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) return 'Barangay is required';
                    return null;
                  },
                  onChanged: _selectedCity != null && !_loadingBarangays
                      ? _onBarangayChanged
                      : null,
                  hint: _loadingBarangays
                      ? const Text('Loading barangays...')
                      : const Text('Select Barangay'),
                  disabledHint: _selectedCity == null
                      ? const Text('Select a city first')
                      : const Text('Loading barangays...'),
                  isExpanded: true,
                ),
                const SizedBox(height: IAMSizes.spaceBtwInputFields),

                // Address Line
                TextFormField(
                  controller: _addressLineController,
                  decoration: const InputDecoration(
                    labelText: 'Address Line',
                    prefixIcon: Icon(Iconsax.building_3),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Address line is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: IAMSizes.spaceBtwSections),

                // ID Upload Section
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
                        color: _idImagePath != null
                            ? IAMColors.primary
                            : (dark ? Colors.grey : Colors.grey),
                        width: _idImagePath != null ? 2 : 1,
                      ),
                    ),
                    child: _idImagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(IAMSizes.cardRadiusMd),
                            child: Image.file(
                              _idImageFile!,
                              fit: BoxFit.cover,
                            ),
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

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: IAMColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: IAMSizes.md),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Submit Enrollment',
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
      ),
    );
  }
}