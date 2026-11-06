
import 'package:flutter/material.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() =>
      _BusinessProfileScreenState();
}

class _BusinessProfileScreenState
    extends State<BusinessProfileScreen> {
  static const Color background = Color(0xFF080B12);
  static const Color cardColor = Color(0xFF121D2D);
  static const Color blue = Color(0xFF5798FF);
  static const Color muted = Color(0xFF91A4BE);
  static const Color green = Color(0xFF45C99A);

  final _formKey = GlobalKey<FormState>();

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

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 12),
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(
              color: Colors.redAccent,
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
      child: Row(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: const Color(0xFF263B5B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.business,
              color: blue,
              size: 32,
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
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Add your business identity',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Logo upload will be connected later.',
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: blue,
              side: const BorderSide(color: blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Business profile validated. Permanent saving will be connected later.',
        ),
        backgroundColor: Color(0xFF263B5B),
      ),
    );
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

              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: const Color(0xFF26364D),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.public,
                      color: blue,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Country',
                            style: TextStyle(
                              color: muted,
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Nepal',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.lock_outline,
                      color: muted,
                      size: 17,
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    'Save Business Profile',
                    style: TextStyle(
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
                  'Business information can be edited later.',
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
