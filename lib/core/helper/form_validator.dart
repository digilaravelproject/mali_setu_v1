import 'package:edu_cluezer/core/helper/country_list_picker.dart';

class FormValidator {
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your name";
    }
    if (value.trim().length < 3) {
      return "Name must be at least 3 characters";
    }
    // if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
    //   return "Name can only contain alphabets";
    // }
    return null;
  }

  static String? jobTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your job title";
    }
    if (value.trim().length < 5) {
      return "Job title must be at least 5 characters";
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return "Job title can only contain alphabets";
    }
    return null;
  }

  static String? jobDescription(String? value,String title) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter $title";
    }
    // if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
    //   return "$title can only contain alphabets";
    // }
    return null;
  }


  static String? emptycheck(String? value,String title) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter $title";
    }
    // if (value.trim().length < 10) {
    //   return "$title must be at least 10 characters";
    // }
    // if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
    //   return "$title can only contain alphabets";
    // }
    return null;
  }

  // Pincode validation (assuming Indian 6-digit pincode)
  static String? pincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter pincode";
    }

    String pin = value.trim();

    // Must be exactly 6 digits
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      return "Enter a valid 6-digit pincode";
    }

    return null;
  }

// Road/Street number validation
  static String? roadNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter road/street number";
    }

    String road = value.trim();

    // Only letters, digits, and common symbols allowed (e.g., '-', '/', ' ')
    if (!RegExp(r'^[a-zA-Z0-9\s\-\/]+$').hasMatch(road)) {
      return "Enter a valid road/street number";
    }

    // Optional: minimum length check
    if (road.length < 1) {
      return "Road/Street number is too short";
    }

    return null;
  }



  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter age";
    }

    final age = int.tryParse(value.trim());
    if (age == null) {
      return "Age must be a valid number";
    }

    if (age < 18) {
      return "Age must be greater than 18";
    }

    if (age > 120) {
      return "Please enter a valid age";
    }

    return null;
  }


  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter email id";
    }
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value.trim())) {
      return "Enter a valid email";
    }
    return null;
  }

  static String? walletName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter wallet name";
    }
    // Allow letters, numbers, spaces, and underscores, min length 3
    if (!RegExp(r'^[a-zA-Z0-9 _]{3,30}$').hasMatch(value.trim())) {
      return "Enter a valid wallet name (3–30 characters)";
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter password";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return "Please confirm your password";
    }
    if (value != password) {
      return "Passwords do not match";
    }
    return null;
  }

  static String? dob(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter date of birth";
    }
    
    final val = value.trim();
    int day, month, year;
    
    final ddMMyyyy = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
    Match? match = ddMMyyyy.firstMatch(val);
    
    if (match != null) {
      day = int.parse(match.group(1)!);
      month = int.parse(match.group(2)!);
      year = int.parse(match.group(3)!);
    } else {
      final yyyyMMdd = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
      match = yyyyMMdd.firstMatch(val);
      if (match != null) {
        year = int.parse(match.group(1)!);
        month = int.parse(match.group(2)!);
        day = int.parse(match.group(3)!);
      } else {
        return "Enter a valid date (DD/MM/YYYY)";
      }
    }
    
    // Validate bounds
    if (year < 1900 || year > DateTime.now().year) return "Enter a valid year";
    if (month < 1 || month > 12) return "Enter a valid month (01-12)";
    if (day < 1 || day > 31) return "Enter a valid day";
    
    final daysInMonth = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) {
      daysInMonth[2] = 29;
    }
    
    if (day > daysInMonth[month]) return "Enter a valid date";
    
    final parsedDate = DateTime(year, month, day);
    final today = DateTime.now();
    final minDate = DateTime(today.year - 18, today.month, today.day);
    
    if (parsedDate.isAfter(minDate)) {
      return "You must be at least 18 years old";
    }
    
    return null;
  }

  static String? validateAadhaar(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter Aadhaar number";
    } else if (value.length != 12) {
      return "Aadhaar number must be 12 digits";
    } else if (!RegExp(r'^[0-9]{12}$').hasMatch(value)) {
      return "Invalid Aadhaar number";
    }
    return null; // valid
  }


  static String? mobile(String? value) {
    const int minLength = 10;
    const int maxLength = 10;

    if (value == null || value.trim().isEmpty) {
      return "Please enter mobile number";
    }

    String mobile = value.trim();

    // Check minimum length
    if (mobile.length < minLength) {
      return "Mobile number must be at least $minLength digits";
    }

    // Check maximum length
    if (mobile.length > maxLength) {
      return "Mobile number must not exceed $maxLength digits";
    }

    // Only digits allowed
    if (!RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      return "Mobile number can contain digits only";
    }

    // Optional India-specific rule
    if (!RegExp(r'^[6-9]').hasMatch(mobile)) {
      return "Enter a valid Indian mobile number";
    }

    return null;
  }

/*
  static String? mobile(String? value, {required Country country}) {
    int minLength = country.minLength;
    int maxLength = country.maxLength;

    if (value == null || value.trim().isEmpty) {
      return "Mobile number is required";
    }

    String mobile = value.trim();

    // Check minimum length
    if (mobile.length < minLength) {
      return "Mobile number must be at least $minLength digits";
    }

    // Check maximum length
    if (mobile.length > maxLength) {
      return "Mobile number must not exceed $maxLength digits";
    }

    // Only digits allowed
    if (!RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      return "Mobile number can contain digits only";
    }

    // Optional India-specific rule when min & max = 10
    if (minLength == 10 && maxLength == 10) {
      if (!RegExp(r'^[6-9]').hasMatch(mobile)) {
        return "Enter a valid Indian mobile number";
      }
    }

    return null;
  }*/
}
