import 'package:get/get.dart';
import 'en_US.dart';
import 'mr_IN.dart';

class Languages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'mr_IN': mrIN,
  };
}
