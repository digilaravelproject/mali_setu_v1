import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'basic_text_field.dart';

/// Country data model
class CountryCode {
  final String code;
  final String name;
  final String flag;

  const CountryCode({
    required this.code,
    required this.name,
    required this.flag,
  });
}

/// Reusable widget component for phone input with Country Code and Phone Number
class PhoneFieldComponent extends StatefulWidget {
  final String? initialPhone;
  final bool isRequired;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const PhoneFieldComponent({
    super.key,
    this.initialPhone,
    this.isRequired = false,
    this.onChanged,
    this.errorText,
  });

  @override
  State<PhoneFieldComponent> createState() => PhoneFieldComponentState();
}

class PhoneFieldComponentState extends State<PhoneFieldComponent> {
  late TextEditingController countryCodeCtrl;
  late TextEditingController phoneCtrl;

  // All countries with codes
  static const List<CountryCode> allCountries = [
    CountryCode(code: '+93', name: 'Afghanistan', flag: '🇦🇫'),
    CountryCode(code: '+355', name: 'Albania', flag: '🇦🇱'),
    CountryCode(code: '+213', name: 'Algeria', flag: '🇩🇿'),
    CountryCode(code: '+376', name: 'Andorra', flag: '🇦🇩'),
    CountryCode(code: '+244', name: 'Angola', flag: '🇦🇴'),
    CountryCode(code: '+54', name: 'Argentina', flag: '🇦🇷'),
    CountryCode(code: '+374', name: 'Armenia', flag: '🇦🇲'),
    CountryCode(code: '+61', name: 'Australia', flag: '🇦🇺'),
    CountryCode(code: '+43', name: 'Austria', flag: '🇦🇹'),
    CountryCode(code: '+994', name: 'Azerbaijan', flag: '🇦🇿'),
    CountryCode(code: '+973', name: 'Bahrain', flag: '🇧🇭'),
    CountryCode(code: '+880', name: 'Bangladesh', flag: '🇧🇩'),
    CountryCode(code: '+375', name: 'Belarus', flag: '🇧🇾'),
    CountryCode(code: '+32', name: 'Belgium', flag: '🇧🇪'),
    CountryCode(code: '+501', name: 'Belize', flag: '🇧🇿'),
    CountryCode(code: '+229', name: 'Benin', flag: '🇧🇯'),
    CountryCode(code: '+975', name: 'Bhutan', flag: '🇧🇹'),
    CountryCode(code: '+591', name: 'Bolivia', flag: '🇧🇴'),
    CountryCode(code: '+387', name: 'Bosnia', flag: '🇧🇦'),
    CountryCode(code: '+267', name: 'Botswana', flag: '🇧🇼'),
    CountryCode(code: '+55', name: 'Brazil', flag: '🇧🇷'),
    CountryCode(code: '+673', name: 'Brunei', flag: '🇧🇳'),
    CountryCode(code: '+359', name: 'Bulgaria', flag: '🇧🇬'),
    CountryCode(code: '+226', name: 'Burkina Faso', flag: '🇧🇫'),
    CountryCode(code: '+257', name: 'Burundi', flag: '🇧🇮'),
    CountryCode(code: '+855', name: 'Cambodia', flag: '🇰🇭'),
    CountryCode(code: '+237', name: 'Cameroon', flag: '🇨🇲'),
    CountryCode(code: '+1', name: 'Canada', flag: '🇨🇦'),
    CountryCode(code: '+238', name: 'Cape Verde', flag: '🇨🇻'),
    CountryCode(code: '+236', name: 'Central African Republic', flag: '🇨🇫'),
    CountryCode(code: '+235', name: 'Chad', flag: '🇹🇩'),
    CountryCode(code: '+56', name: 'Chile', flag: '🇨🇱'),
    CountryCode(code: '+86', name: 'China', flag: '🇨🇳'),
    CountryCode(code: '+57', name: 'Colombia', flag: '🇨🇴'),
    CountryCode(code: '+269', name: 'Comoros', flag: '🇰🇲'),
    CountryCode(code: '+242', name: 'Congo', flag: '🇨🇬'),
    CountryCode(code: '+506', name: 'Costa Rica', flag: '🇨🇷'),
    CountryCode(code: '+385', name: 'Croatia', flag: '🇭🇷'),
    CountryCode(code: '+53', name: 'Cuba', flag: '🇨🇺'),
    CountryCode(code: '+357', name: 'Cyprus', flag: '🇨🇾'),
    CountryCode(code: '+420', name: 'Czech Republic', flag: '🇨🇿'),
    CountryCode(code: '+45', name: 'Denmark', flag: '🇩🇰'),
    CountryCode(code: '+253', name: 'Djibouti', flag: '🇩🇯'),
    CountryCode(code: '+593', name: 'Ecuador', flag: '🇪🇨'),
    CountryCode(code: '+20', name: 'Egypt', flag: '🇪🇬'),
    CountryCode(code: '+503', name: 'El Salvador', flag: '🇸🇻'),
    CountryCode(code: '+240', name: 'Equatorial Guinea', flag: '🇬🇶'),
    CountryCode(code: '+291', name: 'Eritrea', flag: '🇪🇷'),
    CountryCode(code: '+372', name: 'Estonia', flag: '🇪🇪'),
    CountryCode(code: '+251', name: 'Ethiopia', flag: '🇪🇹'),
    CountryCode(code: '+679', name: 'Fiji', flag: '🇫🇯'),
    CountryCode(code: '+358', name: 'Finland', flag: '🇫🇮'),
    CountryCode(code: '+33', name: 'France', flag: '🇫🇷'),
    CountryCode(code: '+241', name: 'Gabon', flag: '🇬🇦'),
    CountryCode(code: '+220', name: 'Gambia', flag: '🇬🇲'),
    CountryCode(code: '+995', name: 'Georgia', flag: '🇬🇪'),
    CountryCode(code: '+49', name: 'Germany', flag: '🇩🇪'),
    CountryCode(code: '+233', name: 'Ghana', flag: '🇬🇭'),
    CountryCode(code: '+30', name: 'Greece', flag: '🇬🇷'),
    CountryCode(code: '+502', name: 'Guatemala', flag: '🇬🇹'),
    CountryCode(code: '+224', name: 'Guinea', flag: '🇬🇳'),
    CountryCode(code: '+245', name: 'Guinea-Bissau', flag: '🇬🇼'),
    CountryCode(code: '+592', name: 'Guyana', flag: '🇬🇾'),
    CountryCode(code: '+509', name: 'Haiti', flag: '🇭🇹'),
    CountryCode(code: '+504', name: 'Honduras', flag: '🇭🇳'),
    CountryCode(code: '+852', name: 'Hong Kong', flag: '🇭🇰'),
    CountryCode(code: '+36', name: 'Hungary', flag: '🇭🇺'),
    CountryCode(code: '+354', name: 'Iceland', flag: '🇮🇸'),
    CountryCode(code: '+91', name: 'India', flag: '🇮🇳'),
    CountryCode(code: '+62', name: 'Indonesia', flag: '🇮🇩'),
    CountryCode(code: '+98', name: 'Iran', flag: '🇮🇷'),
    CountryCode(code: '+964', name: 'Iraq', flag: '🇮🇶'),
    CountryCode(code: '+353', name: 'Ireland', flag: '🇮🇪'),
    CountryCode(code: '+972', name: 'Israel', flag: '🇮🇱'),
    CountryCode(code: '+39', name: 'Italy', flag: '🇮🇹'),
    CountryCode(code: '+225', name: 'Ivory Coast', flag: '🇨🇮'),
    CountryCode(code: '+1876', name: 'Jamaica', flag: '🇯🇲'),
    CountryCode(code: '+81', name: 'Japan', flag: '🇯🇵'),
    CountryCode(code: '+962', name: 'Jordan', flag: '🇯🇴'),
    CountryCode(code: '+7', name: 'Kazakhstan', flag: '🇰🇿'),
    CountryCode(code: '+254', name: 'Kenya', flag: '🇰🇪'),
    CountryCode(code: '+965', name: 'Kuwait', flag: '🇰🇼'),
    CountryCode(code: '+996', name: 'Kyrgyzstan', flag: '🇰🇬'),
    CountryCode(code: '+856', name: 'Laos', flag: '🇱🇦'),
    CountryCode(code: '+371', name: 'Latvia', flag: '🇱🇻'),
    CountryCode(code: '+961', name: 'Lebanon', flag: '🇱🇧'),
    CountryCode(code: '+266', name: 'Lesotho', flag: '🇱🇸'),
    CountryCode(code: '+231', name: 'Liberia', flag: '🇱🇷'),
    CountryCode(code: '+218', name: 'Libya', flag: '🇱🇾'),
    CountryCode(code: '+423', name: 'Liechtenstein', flag: '🇱🇮'),
    CountryCode(code: '+370', name: 'Lithuania', flag: '🇱🇹'),
    CountryCode(code: '+352', name: 'Luxembourg', flag: '🇱🇺'),
    CountryCode(code: '+853', name: 'Macau', flag: '🇲🇴'),
    CountryCode(code: '+389', name: 'Macedonia', flag: '🇲🇰'),
    CountryCode(code: '+261', name: 'Madagascar', flag: '🇲🇬'),
    CountryCode(code: '+265', name: 'Malawi', flag: '🇲🇼'),
    CountryCode(code: '+60', name: 'Malaysia', flag: '🇲🇾'),
    CountryCode(code: '+960', name: 'Maldives', flag: '🇲🇻'),
    CountryCode(code: '+223', name: 'Mali', flag: '🇲🇱'),
    CountryCode(code: '+356', name: 'Malta', flag: '🇲🇹'),
    CountryCode(code: '+692', name: 'Marshall Islands', flag: '🇲🇭'),
    CountryCode(code: '+222', name: 'Mauritania', flag: '🇲🇷'),
    CountryCode(code: '+230', name: 'Mauritius', flag: '🇲🇺'),
    CountryCode(code: '+52', name: 'Mexico', flag: '🇲🇽'),
    CountryCode(code: '+691', name: 'Micronesia', flag: '🇫🇲'),
    CountryCode(code: '+373', name: 'Moldova', flag: '🇲🇩'),
    CountryCode(code: '+377', name: 'Monaco', flag: '🇲🇨'),
    CountryCode(code: '+976', name: 'Mongolia', flag: '🇲🇳'),
    CountryCode(code: '+382', name: 'Montenegro', flag: '🇲🇪'),
    CountryCode(code: '+212', name: 'Morocco', flag: '🇲🇦'),
    CountryCode(code: '+258', name: 'Mozambique', flag: '🇲🇿'),
    CountryCode(code: '+95', name: 'Myanmar', flag: '🇲🇲'),
    CountryCode(code: '+264', name: 'Namibia', flag: '🇳🇦'),
    CountryCode(code: '+674', name: 'Nauru', flag: '🇳🇷'),
    CountryCode(code: '+977', name: 'Nepal', flag: '🇳🇵'),
    CountryCode(code: '+31', name: 'Netherlands', flag: '🇳🇱'),
    CountryCode(code: '+64', name: 'New Zealand', flag: '🇳🇿'),
    CountryCode(code: '+505', name: 'Nicaragua', flag: '🇳🇮'),
    CountryCode(code: '+227', name: 'Niger', flag: '🇳🇪'),
    CountryCode(code: '+234', name: 'Nigeria', flag: '🇳🇬'),
    CountryCode(code: '+850', name: 'North Korea', flag: '🇰🇵'),
    CountryCode(code: '+47', name: 'Norway', flag: '🇳🇴'),
    CountryCode(code: '+968', name: 'Oman', flag: '🇴🇲'),
    CountryCode(code: '+92', name: 'Pakistan', flag: '🇵🇰'),
    CountryCode(code: '+680', name: 'Palau', flag: '🇵🇼'),
    CountryCode(code: '+970', name: 'Palestine', flag: '🇵🇸'),
    CountryCode(code: '+507', name: 'Panama', flag: '🇵🇦'),
    CountryCode(code: '+675', name: 'Papua New Guinea', flag: '🇵🇬'),
    CountryCode(code: '+595', name: 'Paraguay', flag: '🇵🇾'),
    CountryCode(code: '+51', name: 'Peru', flag: '🇵🇪'),
    CountryCode(code: '+63', name: 'Philippines', flag: '🇵🇭'),
    CountryCode(code: '+48', name: 'Poland', flag: '🇵🇱'),
    CountryCode(code: '+351', name: 'Portugal', flag: '🇵🇹'),
    CountryCode(code: '+974', name: 'Qatar', flag: '🇶🇦'),
    CountryCode(code: '+40', name: 'Romania', flag: '🇷🇴'),
    CountryCode(code: '+7', name: 'Russia', flag: '🇷🇺'),
    CountryCode(code: '+250', name: 'Rwanda', flag: '🇷🇼'),
    CountryCode(code: '+966', name: 'Saudi Arabia', flag: '🇸🇦'),
    CountryCode(code: '+221', name: 'Senegal', flag: '🇸🇳'),
    CountryCode(code: '+381', name: 'Serbia', flag: '🇷🇸'),
    CountryCode(code: '+248', name: 'Seychelles', flag: '🇸🇨'),
    CountryCode(code: '+232', name: 'Sierra Leone', flag: '🇸🇱'),
    CountryCode(code: '+65', name: 'Singapore', flag: '🇸🇬'),
    CountryCode(code: '+421', name: 'Slovakia', flag: '🇸🇰'),
    CountryCode(code: '+386', name: 'Slovenia', flag: '🇸🇮'),
    CountryCode(code: '+677', name: 'Solomon Islands', flag: '🇸🇧'),
    CountryCode(code: '+252', name: 'Somalia', flag: '🇸🇴'),
    CountryCode(code: '+27', name: 'South Africa', flag: '🇿🇦'),
    CountryCode(code: '+82', name: 'South Korea', flag: '🇰🇷'),
    CountryCode(code: '+211', name: 'South Sudan', flag: '🇸🇸'),
    CountryCode(code: '+34', name: 'Spain', flag: '🇪🇸'),
    CountryCode(code: '+94', name: 'Sri Lanka', flag: '🇱🇰'),
    CountryCode(code: '+249', name: 'Sudan', flag: '🇸🇩'),
    CountryCode(code: '+597', name: 'Suriname', flag: '🇸🇷'),
    CountryCode(code: '+268', name: 'Swaziland', flag: '🇸🇿'),
    CountryCode(code: '+46', name: 'Sweden', flag: '🇸🇪'),
    CountryCode(code: '+41', name: 'Switzerland', flag: '🇨🇭'),
    CountryCode(code: '+963', name: 'Syria', flag: '🇸🇾'),
    CountryCode(code: '+886', name: 'Taiwan', flag: '🇹🇼'),
    CountryCode(code: '+992', name: 'Tajikistan', flag: '🇹🇯'),
    CountryCode(code: '+255', name: 'Tanzania', flag: '🇹🇿'),
    CountryCode(code: '+66', name: 'Thailand', flag: '🇹🇭'),
    CountryCode(code: '+670', name: 'Timor-Leste', flag: '🇹🇱'),
    CountryCode(code: '+228', name: 'Togo', flag: '🇹🇬'),
    CountryCode(code: '+676', name: 'Tonga', flag: '🇹🇴'),
    CountryCode(code: '+216', name: 'Tunisia', flag: '🇹🇳'),
    CountryCode(code: '+90', name: 'Turkey', flag: '🇹🇷'),
    CountryCode(code: '+993', name: 'Turkmenistan', flag: '🇹🇲'),
    CountryCode(code: '+688', name: 'Tuvalu', flag: '🇹🇻'),
    CountryCode(code: '+256', name: 'Uganda', flag: '🇺🇬'),
    CountryCode(code: '+380', name: 'Ukraine', flag: '🇺🇦'),
    CountryCode(code: '+971', name: 'UAE', flag: '🇦🇪'),
    CountryCode(code: '+44', name: 'United Kingdom', flag: '🇬🇧'),
    CountryCode(code: '+1', name: 'United States', flag: '🇺🇸'),
    CountryCode(code: '+598', name: 'Uruguay', flag: '🇺🇾'),
    CountryCode(code: '+998', name: 'Uzbekistan', flag: '🇺🇿'),
    CountryCode(code: '+678', name: 'Vanuatu', flag: '🇻🇺'),
    CountryCode(code: '+379', name: 'Vatican City', flag: '🇻🇦'),
    CountryCode(code: '+58', name: 'Venezuela', flag: '🇻🇪'),
    CountryCode(code: '+84', name: 'Vietnam', flag: '🇻🇳'),
    CountryCode(code: '+967', name: 'Yemen', flag: '🇾🇪'),
    CountryCode(code: '+260', name: 'Zambia', flag: '🇿🇲'),
    CountryCode(code: '+263', name: 'Zimbabwe', flag: '🇿🇼'),
  ];

  @override
  void initState() {
    super.initState();
    
    // Parse initial phone if provided
    if (widget.initialPhone != null && widget.initialPhone!.isNotEmpty) {
      final parsed = _parsePhone(widget.initialPhone!);
      countryCodeCtrl = TextEditingController(text: parsed['code']);
      phoneCtrl = TextEditingController(text: parsed['number']);
    } else {
      countryCodeCtrl = TextEditingController(text: '+91');
      phoneCtrl = TextEditingController();
    }

    // Add listeners to notify parent of changes
    countryCodeCtrl.addListener(_notifyChange);
    phoneCtrl.addListener(_notifyChange);
  }

  Map<String, String> _parsePhone(String phone) {
    // Remove spaces and trim
    phone = phone.trim().replaceAll(' ', '');
    
    // Check if starts with +
    if (phone.startsWith('+')) {
      // Try to match with known country codes (longest first)
      // Sort by code length descending to match longest codes first
      final sortedCodes = allCountries.map((c) => c.code).toSet().toList()
        ..sort((a, b) => b.length.compareTo(a.length));
      
      for (final code in sortedCodes) {
        if (phone.startsWith(code)) {
          return {
            'code': code,
            'number': phone.substring(code.length),
          };
        }
      }
      
      // Fallback: Extract country code (1-4 digits after +)
      final match = RegExp(r'^\+(\d{1,4})(.*)').firstMatch(phone);
      if (match != null) {
        return {
          'code': '+${match.group(1)}',
          'number': match.group(2) ?? '',
        };
      }
    }
    
    // Default to +91 if no country code found
    return {
      'code': '+91',
      'number': phone,
    };
  }

  void _notifyChange() {
    if (widget.onChanged != null) {
      widget.onChanged!(getCombinedPhone());
    }
  }

  @override
  void dispose() {
    countryCodeCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  /// Returns the combined phone string in format "+91 9876543210"
  String getCombinedPhone() {
    final code = countryCodeCtrl.text.trim();
    final number = phoneCtrl.text.trim();
    
    if (number.isEmpty) return '';
    
    return '$code$number';
  }

  /// Validates that phone number is not empty (if required)
  String? validate() {
    if (widget.isRequired && phoneCtrl.text.trim().isEmpty) {
      return 'Please enter phone number';
    }
    if (phoneCtrl.text.trim().isNotEmpty && phoneCtrl.text.trim().length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppInputTextField(
      label: 'mobile_number'.tr,
      controller: phoneCtrl,
      isRequired: widget.isRequired,
      textInputType: TextInputType.phone,
      topPadding: 0,
      errorText: widget.errorText,
      prefixIcon: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
        child: IntrinsicWidth(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _showCountryPicker(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      countryCodeCtrl.text,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 24,
                width: 1,
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
      validator: (value) {
        if (widget.isRequired && (value == null || value.trim().isEmpty)) {
          return 'Please enter phone number';
        }
        if (value != null && value.trim().isNotEmpty && value.trim().length < 10) {
          return 'Phone number must be at least 10 digits';
        }
        return null;
      },
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CountryPickerSheet(
        selectedCode: countryCodeCtrl.text,
        onSelect: (country) {
          setState(() {
            countryCodeCtrl.text = country.code;
          });
          _notifyChange();
        },
      ),
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final String selectedCode;
  final ValueChanged<CountryCode> onSelect;

  const _CountryPickerSheet({
    required this.selectedCode,
    required this.onSelect,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  late TextEditingController searchCtrl;
  List<CountryCode> filteredCountries = [];

  @override
  void initState() {
    super.initState();
    searchCtrl = TextEditingController();
    filteredCountries = PhoneFieldComponentState.allCountries;
    searchCtrl.addListener(_filterCountries);
  }

  void _filterCountries() {
    final query = searchCtrl.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCountries = PhoneFieldComponentState.allCountries;
      } else {
        filteredCountries = PhoneFieldComponentState.allCountries
            .where((country) =>
                country.name.toLowerCase().contains(query) ||
                country.code.contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          Text(
            'Select Country Code',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search country...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchCtrl.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          searchCtrl.clear();
                        },
                        child: const Icon(Icons.clear, size: 20),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Country list
          Expanded(
            child: filteredCountries.isEmpty
                ? Center(
                    child: Text(
                      'No countries found',
                      style: Get.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = filteredCountries[index];
                      final isSelected = country.code == widget.selectedCode;
                      
                      return ListTile(
                        leading: Text(
                          country.flag,
                          style: const TextStyle(fontSize: 28),
                        ),
                        title: Text(
                          country.name,
                          style: Get.textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        ),
                        trailing: Text(
                          country.code,
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: isSelected ? Get.theme.primaryColor : Colors.grey,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: Get.theme.primaryColor.withOpacity(0.1),
                        onTap: () {
                          widget.onSelect(country);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

