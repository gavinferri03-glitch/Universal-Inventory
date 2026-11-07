
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_picker/country_picker.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  static const Color background = Color(0xFF080B12);
  static const Color cardColor = Color(0xFF121D2D);
  static const Color blue = Color(0xFF5798FF);
  static const Color muted = Color(0xFF91A4BE);

  static const String _logoKey = 'company_logo_path';
  static const String _countryKey = 'company_country';

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();

  final companyName = TextEditingController();
  final legalName = TextEditingController();
  final registrationNumber = TextEditingController();
  final panVatNumber = TextEditingController();
  final phoneNumber = TextEditingController();
  final emailAddress = TextEditingController();
  final website = TextEditingController();
  final address = TextEditingController();
  final city = TextEditingController();
  final district = TextEditingController();

  String businessType = 'Retail';
  String country = 'Nepal';

  String? _logoPath;
  bool _loading = true;
  bool _savingLogo = false;
  bool _savingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadSavedDetails();
  }

  @override
  void dispose() {
    companyName.dispose();
    legalName.dispose();
    registrationNumber.dispose();
    panVatNumber.dispose();
    phoneNumber.dispose();
    emailAddress.dispose();
    website.dispose();
    address.dispose();
    city.dispose();
    district.dispose();
    super.dispose();
  }

  Future<void> _loadSavedDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      companyName.text = prefs.getString('company_name') ?? '';
      legalName.text = prefs.getString('company_legal_name') ?? '';
      businessType =
          prefs.getString('company_business_type') ?? 'Retail';
      registrationNumber.text =
          prefs.getString('company_registration_number') ?? '';
      panVatNumber.text = prefs.getString('company_pan_vat') ?? '';
      phoneNumber.text = prefs.getString('company_phone') ?? '';
      emailAddress.text = prefs.getString('company_email') ?? '';
      website.text = prefs.getString('company_website') ?? '';
      address.text = prefs.getString('company_address') ?? '';
      city.text = prefs.getString('company_city') ?? '';
      district.text = prefs.getString('company_district') ?? '';

      country = prefs.getString(_countryKey) ?? 'Nepal';

      final savedLogo = prefs.getString(_logoKey);

      if (savedLogo != null && await File(savedLogo).exists()) {
        _logoPath = savedLogo;
      }
    } catch (e) {
      debugPrint('Could not load company details: $e');
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickLogo() async {
    if (_savingLogo) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (image == null || !mounted) return;

      setState(() => _savingLogo = true);

      final directory = await getApplicationDocumentsDirectory();

      final dot = image.path.lastIndexOf('.');
      final extension =
          dot == -1 ? '.jpg' : image.path.substring(dot);

      final newPath =
          '${directory.path}/company_logo_${DateTime.now().millisecondsSinceEpoch}$extension';

      final savedFile = await File(image.path).copy(newPath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_logoKey, savedFile.path);

      if (!mounted) return;

      setState(() {
        _logoPath = savedFile.path;
        _savingLogo = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company logo saved successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _savingLogo = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not select logo: $e')),
      );
    }
  }

  Future<void> _removeLogo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final oldPath = _logoPath;

      await prefs.remove(_logoKey);

      if (oldPath != null) {
        final file = File(oldPath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      if (!mounted) return;

      setState(() => _logoPath = null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company logo removed.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not remove logo: $e')),
      );
    }
  }

  void _selectCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      onSelect: (Country selectedCountry) async {
        setState(() => country = selectedCountry.name);

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_countryKey, selectedCountry.name);
        } catch (e) {
          debugPrint('Could not save country: $e');
        }
      },
      countryListTheme: CountryListThemeData(
        backgroundColor: cardColor,
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        searchTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        inputDecoration: InputDecoration(
          hintText: 'Search country',
          hintStyle: const TextStyle(color: muted),
          prefixIcon: const Icon(Icons.search, color: muted),
          filled: true,
          fillColor: background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF26364D),
            ),
          ),
        ),
        bottomSheetHeight: 550,
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label is required';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: icon == null
              ? null
              : Icon(icon, color: muted, size: 19),
          labelStyle: const TextStyle(
            color: muted,
            fontSize: 12,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF60738D),
            fontSize: 12,
          ),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: Color(0xFF26364D),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: Color(0xFF26364D),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: blue,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _businessTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: businessType,
        dropdownColor: cardColor,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          labelText: 'Business Type',
          labelStyle: const TextStyle(
            color: muted,
            fontSize: 12,
          ),
          filled: true,
          fillColor: cardColor,
          prefixIcon: const Icon(
            Icons.category_outlined,
            color: muted,
            size: 19,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        items: [
          'Retail',
          'Wholesale',
          'Manufacturing',
          'Distribution',
          'Service',
          'Other',
        ].map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => businessType = value);
          }
        },
      ),
    );
  }

  Widget _logoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF26364D)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 76,
                width: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFF263B5B),
                  borderRadius: BorderRadius.circular(14),
                ),
                clipBehavior: Clip.antiAlias,
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: blue,
                          strokeWidth: 2,
                        ),
                      )
                    : _logoPath != null
                        ? Image.file(
                            File(_logoPath!),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(
                              Icons.business,
                              color: blue,
                              size: 36,
                            ),
                          )
                        : const Icon(
                            Icons.business,
                            color: blue,
                            size: 36,
                          ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company Logo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Choose your business logo from your gallery.',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading || _savingLogo
                      ? null
                      : _pickLogo,
                  icon: _savingLogo
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          _logoPath == null
                              ? Icons.add_photo_alternate_outlined
                              : Icons.edit_outlined,
                        ),
                  label: Text(
                    _savingLogo
                        ? 'Saving...'
                        : _logoPath == null
                            ? 'Choose Logo'
                            : 'Change Logo',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: blue,
                    side: const BorderSide(color: blue),
                  ),
                ),
              ),
              if (_logoPath != null)
                IconButton(
                  onPressed: _savingLogo ? null : _removeLogo,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'Remove logo',
                ),
            ],
          ),
          const Text(
            'Your selected logo is saved on this device.',
            style: TextStyle(color: muted, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _countrySelector() {
    return InkWell(
      onTap: _selectCountry,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: const Color(0xFF26364D),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.public, color: blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Country',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    country,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: muted),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_savingProfile) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _savingProfile = true);

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('company_name', companyName.text.trim());
      await prefs.setString(
        'company_legal_name',
        legalName.text.trim(),
      );
      await prefs.setString('company_business_type', businessType);
      await prefs.setString(
        'company_registration_number',
        registrationNumber.text.trim(),
      );
      await prefs.setString('company_pan_vat', panVatNumber.text.trim());
      await prefs.setString('company_phone', phoneNumber.text.trim());
      await prefs.setString('company_email', emailAddress.text.trim());
      await prefs.setString('company_website', website.text.trim());
      await prefs.setString('company_address', address.text.trim());
      await prefs.setString('company_city', city.text.trim());
      await prefs.setString('company_district', district.text.trim());
      await prefs.setString(_countryKey, country);

      if (!mounted) return;

      setState(() => _savingProfile = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business profile saved successfully.'),
          backgroundColor: Color(0xFF263B5B),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _savingProfile = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save business profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'Business Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
            children: [
              const Text(
                'Manage your company information',
                style: TextStyle(
                  color: muted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              _logoCard(),
              _sectionTitle(
                'Basic Information',
                'General details about your business',
              ),
              _field(
                label: 'Company Name',
                hint: 'Enter your company name',
                controller: companyName,
                icon: Icons.business_outlined,
                required: true,
              ),
              _field(
                label: 'Legal / Registered Name',
                hint: 'Official registered business name',
                controller: legalName,
                icon: Icons.description_outlined,
              ),
              _businessTypeDropdown(),
              _sectionTitle(
                'Registration & Tax Details',
                'Official business registration information',
              ),
              _field(
                label: 'Registration Number',
                hint: 'Enter registration number',
                controller: registrationNumber,
                icon: Icons.badge_outlined,
              ),
              _field(
                label: 'PAN / VAT Number',
                hint: 'Enter PAN or VAT number',
                controller: panVatNumber,
                icon: Icons.receipt_long_outlined,
              ),
              _sectionTitle(
                'Contact Information',
                'How customers and partners can reach you',
              ),
              _field(
                label: 'Phone Number',
                hint: 'Enter business phone number',
                controller: phoneNumber,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                required: true,
              ),
              _field(
                label: 'Email Address',
                hint: 'company@example.com',
                controller: emailAddress,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              _field(
                label: 'Website',
                hint: 'www.example.com',
                controller: website,
                icon: Icons.language_outlined,
                keyboardType: TextInputType.url,
              ),
              _sectionTitle(
                'Business Address',
                'Registered or primary business location',
              ),
              _field(
                label: 'Street Address',
                hint: 'House number, street or area',
                controller: address,
                icon: Icons.location_on_outlined,
                maxLines: 2,
              ),
              _field(
                label: 'City / Municipality',
                hint: 'Enter city or municipality',
                controller: city,
                icon: Icons.location_city_outlined,
              ),
              _field(
                label: 'District',
                hint: 'Enter district',
                controller: district,
                icon: Icons.map_outlined,
              ),
              _countrySelector(),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _loading || _savingProfile
                      ? null
                      : _saveProfile,
                  icon: _savingProfile
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _savingProfile
                        ? 'Saving...'
                        : 'Save Business Profile',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'Business information is saved on this device.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
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
