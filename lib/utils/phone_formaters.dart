import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

TextInputFormatter ugFormatter = LibPhonenumberTextFormatter(
  onFormatFinished: (val) {
    debugPrint('Formatted number Uganda: $val');
  },
  inputContainsCountryCode: true,
  phoneNumberType: PhoneNumberType.mobile, // Specify mobile type
  phoneNumberFormat:
      PhoneNumberFormat.international, // Use international format
  country: CountryWithPhoneCode(
    phoneCode: "256", // Uganda's dialing code
    countryCode: "UG", // Uganda's ISO country code
    exampleNumberMobileNational:
        "0772123456", // Example of a national mobile number
    exampleNumberFixedLineNational:
        "0417123456", // Example of a national fixed-line number
    phoneMaskMobileNational:
        "000 0000000", // Format for national mobile numbers
    phoneMaskFixedLineNational:
        "000 0000000", // Format for national fixed-line numbers
    exampleNumberMobileInternational:
        "+256772123456", // Example of an international mobile number
    exampleNumberFixedLineInternational:
        "+256417123456", // Example of an international fixed-line number
    phoneMaskMobileInternational:
        "+000 000 0000000", // Format for international mobile numbers
    phoneMaskFixedLineInternational:
        "+000 000 0000000", // Format for international fixed-line numbers
    countryName: "Uganda", // Name of the country
  ),
);
