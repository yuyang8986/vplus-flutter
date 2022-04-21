enum Environment { test, dev, prod }

class AppConfigHelper {
  static String _apiUrl = "apiUrl";
  static String _signalrUrl = "signalrUrl";
  static String _qrUrl = "qrUrl";

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

  static String get getSignalrUrl {
    return _config[_signalrUrl];
  }

  static String get getQrUrl {
    return _config[_qrUrl];
  }

  static Map<String, dynamic> testConstants = {
    _apiUrl: "http://vplusprod.ap-southeast-2.elasticbeanstalk.com/",
    _signalrUrl: "http://vplusprod.ap-southeast-2.elasticbeanstalk.com/orderHub",
    _qrUrl:
        "http://vplus-web-deploy-test.s3-website-ap-southeast-2.amazonaws.com/"
  };

  static Map<String, dynamic> devConstants = {
    _apiUrl: "https://10.0.2.2:44382/",
    _signalrUrl: "https://10.0.2.2:44382/orderHub",
    _qrUrl: "http://www.vplus.com.au"
  };

  static Map<String, dynamic> prodConstants = {
    _apiUrl: "https://api.vplus.com.au/",
    _signalrUrl: "https://api.vplus.com.au/orderHub",
    _qrUrl: "https://www.vplus.com.au"
  };
}
