import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:edu_cluezer/core/styles/app_colors.dart';
import 'package:edu_cluezer/widgets/custom_snack_bar.dart';

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

/// Reusable widget component for mobile number input and OTP verification design
/// Matches exact layout with:
/// - "Mobile Number *" Label
/// - Row with: [ Country Code Dropdown ] [ Phone Number Field ] [ Verify Button ]
/// - Enter OTP Card with 5 Clean Digit Input Boxes and "Didn't receive OTP? Resend"
class PhoneFieldComponent extends StatefulWidget {
  final String? initialPhone;
  final bool isRequired;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool showOtpSection;
  final int otpLength;

  const PhoneFieldComponent({
    super.key,
    this.initialPhone,
    this.isRequired = false,
    this.onChanged,
    this.errorText,
    this.showOtpSection = true,
    this.otpLength = 5,
  });

  @override
  State<PhoneFieldComponent> createState() => PhoneFieldComponentState();
}

class PhoneFieldComponentState extends State<PhoneFieldComponent> {
  late TextEditingController countryCodeCtrl;
  late TextEditingController phoneCtrl;

  late List<TextEditingController> otpControllers;
  late List<FocusNode> otpFocusNodes;

  bool isOtpSent = false;
  bool isVerified = false;
  String? errorMessage;
  Timer? _resendTimer;
  int _resendCountdown = 0;

  // All countries with codes
  static const List<CountryCode> allCountries = [
    CountryCode(code: '+91', name: 'India', flag: '🇮🇳'),
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
    CountryCode(code: '+509', name: 'Haiti', flag: '🇭🇹'),
    CountryCode(code: '+504', name: 'Honduras', flag: '🇭🇳'),
    CountryCode(code: '+852', name: 'Hong Kong', flag: '🇭🇰'),
    CountryCode(code: '+36', name: 'Hungary', flag: '🇭🇺'),
    CountryCode(code: '+354', name: 'Iceland', flag: '🇮🇸'),
    CountryCode(code: '+62', name: 'Indonesia', flag: '🇮🇩'),
    CountryCode(code: '+98', name: 'Iran', flag: '🇮🇷'),
    CountryCode(code: '+964', name: 'Iraq', flag: '🇮🇶'),
    CountryCode(code: '+353', name: 'Ireland', flag: '🇮🇪'),
    CountryCode(code: '+972', name: 'Israel', flag: '🇮🇱'),
    CountryCode(code: '+39', name: 'Italy', flag: '🇮🇹'),
    CountryCode(code: '+225', name: 'Ivory Coast', flag: '🇨🇮'),
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
    CountryCode(code: '+222', name: 'Mauritania', flag: '🇲🇷'),
    CountryCode(code: '+230', name: 'Mauritius', flag: '🇲🇺'),
    CountryCode(code: '+52', name: 'Mexico', flag: '🇲🇽'),
    CountryCode(code: '+373', name: 'Moldova', flag: '🇲🇩'),
    CountryCode(code: '+377', name: 'Monaco', flag: '🇲🇨'),
    CountryCode(code: '+976', name: 'Mongolia', flag: '🇲🇳'),
    CountryCode(code: '+382', name: 'Montenegro', flag: '🇲🇪'),
    CountryCode(code: '+212', name: 'Morocco', flag: '🇲🇦'),
    CountryCode(code: '+258', name: 'Mozambique', flag: '🇲🇿'),
    CountryCode(code: '+95', name: 'Myanmar', flag: '🇲🇲'),
    CountryCode(code: '+264', name: 'Namibia', flag: '🇳🇦'),
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
    CountryCode(code: '+252', name: 'Somalia', flag: '🇸🇴'),
    CountryCode(code: '+27', name: 'South Africa', flag: '🇿🇦'),
    CountryCode(code: '+82', name: 'South Korea', flag: '🇰🇷'),
    CountryCode(code: '+34', name: 'Spain', flag: '🇪🇸'),
    CountryCode(code: '+94', name: 'Sri Lanka', flag: '🇱🇰'),
    CountryCode(code: '+249', name: 'Sudan', flag: '🇸🇩'),
    CountryCode(code: '+46', name: 'Sweden', flag: '🇸🇪'),
    CountryCode(code: '+41', name: 'Switzerland', flag: '🇨🇭'),
    CountryCode(code: '+963', name: 'Syria', flag: '🇸🇾'),
    CountryCode(code: '+886', name: 'Taiwan', flag: '🇹🇼'),
    CountryCode(code: '+992', name: 'Tajikistan', flag: '🇹🇯'),
    CountryCode(code: '+255', name: 'Tanzania', flag: '🇹🇿'),
    CountryCode(code: '+66', name: 'Thailand', flag: '🇹🇭'),
    CountryCode(code: '+228', name: 'Togo', flag: '🇹🇬'),
    CountryCode(code: '+216', name: 'Tunisia', flag: '🇹🇳'),
    CountryCode(code: '+90', name: 'Turkey', flag: '🇹🇷'),
    CountryCode(code: '+993', name: 'Turkmenistan', flag: '🇹🇲'),
    CountryCode(code: '+256', name: 'Uganda', flag: '🇺🇬'),
    CountryCode(code: '+380', name: 'Ukraine', flag: '🇺🇦'),
    CountryCode(code: '+971', name: 'United Arab Emirates', flag: '🇦🇪'),
    CountryCode(code: '+44', name: 'United Kingdom', flag: '🇬🇧'),
    CountryCode(code: '+1', name: 'United States', flag: '🇺🇸'),
    CountryCode(code: '+598', name: 'Uruguay', flag: '🇺🇾'),
    CountryCode(code: '+998', name: 'Uzbekistan', flag: '🇺🇿'),
    CountryCode(code: '+58', name: 'Venezuela', flag: '🇻🇪'),
    CountryCode(code: '+84', name: 'Vietnam', flag: '🇻🇳'),
    CountryCode(code: '+967', name: 'Yemen', flag: '🇾🇪'),
    CountryCode(code: '+260', name: 'Zambia', flag: '🇿🇲'),
    CountryCode(code: '+263', name: 'Zimbabwe', flag: '🇿🇼'),
  ];

  @override
  void initState() {
    super.initState();
    final parsed = _parsePhone(widget.initialPhone);
    countryCodeCtrl = TextEditingController(text: parsed['code']);
    phoneCtrl = TextEditingController(text: parsed['number']);

    otpControllers = List.generate(widget.otpLength, (_) => TextEditingController());
    otpFocusNodes = List.generate(widget.otpLength, (_) => FocusNode());

    phoneCtrl.addListener(_notifyChange);
  }

  @override
  void didUpdateWidget(PhoneFieldComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPhone != oldWidget.initialPhone &&
        widget.initialPhone != null &&
        widget.initialPhone!.isNotEmpty) {
      final parsed = _parsePhone(widget.initialPhone);
      if (countryCodeCtrl.text != parsed['code'] ||
          phoneCtrl.text != parsed['number']) {
        countryCodeCtrl.text = parsed['code']!;
        phoneCtrl.text = parsed['number']!;
      }
    }
  }

  Map<String, String> _parsePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return {'code': '+91', 'number': ''};
    }

    final trimmed = phone.trim();
    if (trimmed.startsWith('+')) {
      for (var country in allCountries) {
        final code = country.code;
        if (trimmed.startsWith(code)) {
          return {
            'code': code,
            'number': trimmed.substring(code.length).trim(),
          };
        }
      }
      final match = RegExp(r'^\+(\d{1,4})(.*)').firstMatch(trimmed);
      if (match != null) {
        return {
          'code': '+${match.group(1)}',
          'number': (match.group(2) ?? '').trim(),
        };
      }
    }

    return {
      'code': '+91',
      'number': trimmed,
    };
  }

  void _notifyChange() {
    if (widget.onChanged != null) {
      widget.onChanged!(getCombinedPhone());
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    countryCodeCtrl.dispose();
    phoneCtrl.dispose();
    for (var ctrl in otpControllers) {
      ctrl.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Returns the combined phone string in format "+919876543210"
  String getCombinedPhone() {
    final code = countryCodeCtrl.text.trim();
    final number = phoneCtrl.text.trim();
    if (number.isEmpty) return '';
    return '$code$number';
  }

  /// Returns the entered OTP code
  String getEnteredOtp() {
    return otpControllers.map((c) => c.text.trim()).join();
  }

  /// Validates that phone number is not empty and has valid digits
  String? validate() {
    final text = phoneCtrl.text.trim();
    if (widget.isRequired && text.isEmpty) {
      if (mounted) setState(() => errorMessage = 'please_enter_phone'.tr);
      return 'please_enter_phone'.tr;
    }
    if (text.isNotEmpty && text.length < 10) {
      if (mounted) setState(() => errorMessage = 'phone_min_digits'.tr);
      return 'phone_min_digits'.tr;
    }
    if (mounted && errorMessage != null) {
      setState(() => errorMessage = null);
    }
    return null;
  }

  void _handleVerifyClick() {
    final phone = phoneCtrl.text.trim();
    if (phone.isEmpty) {
      setState(() => errorMessage = 'please_enter_phone'.tr);
      CustomSnackBar.showError(message: 'please_enter_phone'.tr);
      return;
    }
    if (phone.length < 10) {
      setState(() => errorMessage = 'phone_min_digits'.tr);
      CustomSnackBar.showError(message: 'phone_min_digits'.tr);
      return;
    }

    setState(() {
      errorMessage = null;
      isOtpSent = true;
    });

    _startResendTimer();
    HapticFeedback.lightImpact();
    CustomSnackBar.showSuccess(
      message: 'OTP sent to ${countryCodeCtrl.text} $phone',
    );

    if (otpFocusNodes.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) otpFocusNodes[0].requestFocus();
      });
    }
  }

  void _handleResendOtp() {
    for (var ctrl in otpControllers) {
      ctrl.clear();
    }
    _startResendTimer();
    HapticFeedback.lightImpact();
    CustomSnackBar.showSuccess(message: 'OTP resent successfully');
    if (otpFocusNodes.isNotEmpty) {
      otpFocusNodes[0].requestFocus();
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() => _resendCountdown = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendCountdown = 0);
      } else {
        if (mounted) setState(() => _resendCountdown--);
      }
    });
  }

  void _onOtpDigitChanged(int index, String val) {
    if (val.isNotEmpty) {
      if (index < widget.otpLength - 1) {
        otpFocusNodes[index + 1].requestFocus();
      } else {
        otpFocusNodes[index].unfocus();
        _checkAndVerifyOtp();
      }
    } else {
      if (index > 0) {
        otpFocusNodes[index - 1].requestFocus();
      }
    }
  }

  void _checkAndVerifyOtp() {
    final otp = getEnteredOtp();
    if (otp.length == widget.otpLength) {
      HapticFeedback.mediumImpact();
      setState(() {
        isVerified = true;
      });
      CustomSnackBar.showSuccess(message: 'Mobile number verified successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final hasErr = errorMessage != null || widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Label: "Mobile Number *" matching other form fields
        Row(
          children: [
            Text(
              'Mobile Number',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ) ??
                  const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    color: Color(0xFF1F2937),
                  ),
            ),
            if (widget.isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),

        // 2. Main Input Row: [ +91 v ]  [ Enter Your Mobile number ]  [ Verify ]
        Row(
          children: [
            // Country Code Box
            InkWell(
              onTap: () => _showCountryPicker(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.lightBorder,
                    width: 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      countryCodeCtrl.text,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Phone Field with Native Single Border (matching all other inputs)
            Expanded(
              child: SizedBox(
                height: 50,
                child: TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter Your Mobile number',
                    hintStyle: const TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: hasErr ? Colors.red.shade400 : AppColors.lightBorder,
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: hasErr ? Colors.red.shade400 : AppColors.lightBorder,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: hasErr ? Colors.red.shade400 : primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    if (isVerified) {
                      setState(() => isVerified = false);
                    }
                    if (errorMessage != null) {
                      setState(() => errorMessage = null);
                    }
                    _notifyChange();
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Verify Button
            InkWell(
              onTap: isVerified ? null : _handleVerifyClick,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: isVerified ? const Color(0xFF10B981) : primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (isVerified ? const Color(0xFF10B981) : primaryColor)
                          .withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: isVerified
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Verify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),

        // Error message if any
        if (hasErr) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorMessage ?? widget.errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],

        // 3. Enter OTP Card (matching exact screenshot layout)
        if (widget.showOtpSection) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F5), // Light pastel blush pink
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFFCE7EC),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Enter OTP *"
                Row(
                  children: [
                    Text(
                      'Enter OTP',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: const Color(0xFF111827),
                          ) ??
                          const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                            color: Color(0xFF111827),
                          ),
                    ),
                    const Text(
                      ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Row with 5 Single-Bordered OTP boxes + "Didn't receive OTP? Resend"
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 5 Clean OTP digit boxes (single crisp border, NO double borders)
                    ...List.generate(widget.otpLength, (index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < widget.otpLength - 1 ? 6 : 0,
                        ),
                        child: SizedBox(
                          width: 38,
                          height: 44,
                          child: TextField(
                            controller: otpControllers[index],
                            focusNode: otpFocusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD9D9D9),
                                  width: 1.2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD9D9D9),
                                  width: 1.2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: primaryColor,
                                  width: 1.8,
                                ),
                              ),
                            ),
                            onChanged: (val) => _onOtpDigitChanged(index, val),
                          ),
                        ),
                      );
                    }),

                    const Spacer(),

                    // "Didn't receive OTP? Resend" on right side
                    InkWell(
                      onTap: _resendCountdown > 0 ? null : _handleResendOtp,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Didn't receive OTP?",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _resendCountdown > 0
                                ? 'Resend (${_resendCountdown}s)'
                                : 'Resend',
                            style: TextStyle(
                              fontSize: 12,
                              color: _resendCountdown > 0
                                  ? const Color(0xFF9CA3AF)
                                  : primaryColor,
                              fontWeight: FontWeight.w700,
                              decoration: _resendCountdown > 0
                                  ? TextDecoration.none
                                  : TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
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
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select Country Code',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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
                            color: isSelected
                                ? Get.theme.primaryColor
                                : Colors.grey,
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor:
                            Get.theme.primaryColor.withOpacity(0.1),
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
