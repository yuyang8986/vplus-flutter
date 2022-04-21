enum Environment { test, dev, prod }

class AppConfigHelper {
  static String _apiUrl = "apiUrl";
  static String _androidPayMode = "initPayMode";
  static String _stripePublishableKey = "initStripeKey";

  static Map<String, dynamic> _config;

  static void setEnvironment(Environment env) {
    switch (env) {
      case Environment.test:
        _config = testConstants;
        break;
      case Environment.dev:
        _config = devConstants;
        break;
      case Environment.prod:
        _config = prodConstants;
        break;
    }
  }

  static String get getApiUrl {
    return _config[_apiUrl];
  }

  static String get getAndroidPayMode {
    return _config[_androidPayMode];
  }

  static String get getStripePublishableKey {
    return _config[_stripePublishableKey];
  }

  static Map<String, dynamic> testConstants = {
    _apiUrl: "http://vplusprod.ap-southeast-2.elasticbeanstalk.com/",
    _androidPayMode: "test",
    _stripePublishableKey:
        "pk_test_51Hl7YICGGqfSAXx936fATJrjlOGQXu9k3NTWObhdrUyNsgGJ1HphL5iziMLyLfbpSzG2vwfJxLqFnuCCyZpYel7U00z42VMlvZ",
  };

  static Map<String, dynamic> devConstants = {
    _apiUrl: "https://10.0.2.2:44382/",
    _androidPayMode: "test",
    _stripePublishableKey:
        "pk_test_51Hl7YICGGqfSAXx936fATJrjlOGQXu9k3NTWObhdrUyNsgGJ1HphL5iziMLyLfbpSzG2vwfJxLqFnuCCyZpYel7U00z42VMlvZ",
  };

  static Map<String, dynamic> prodConstants = {
    _apiUrl: "https://api.vplus.com.au/",
    _androidPayMode: "production",
    _stripePublishableKey:
        "secret",
  };
}
