import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:vplus/helper/appConfigHelper.dart';
import 'package:vplus/providers/currentuser_provider.dart';

class HttpResponse {
  HttpResponse(this.isSuccess, this.data);
  bool isSuccess;
  dynamic data;
}

enum RequestType { GET, POST, DELETE }

class Helper {
  static String API = AppConfigHelper.getApiUrl;
  String lastError = "";
  var box;

  static Map<String, String> _orderListPaginationHeaders;

  Helper() {
    // Hive.openBox('testBox').then((value) {
    //   this.box = value;
    // });
  }

  void showToastError(String text) {
    Fluttertoast.showToast(
        msg: "        " + text + "        ",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red.shade900,
        textColor: Colors.white,
        webShowClose: true,
        fontSize: 16.0);
  }

  void showToastSuccess(String text) {
    Fluttertoast.showToast(
        msg: "        " + text + "        ",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green.shade900,
        textColor: Colors.white,
        webShowClose: true,
        fontSize: 16.0);
  }

  Future<HttpResponse> getData(String url,
      {bool hasAuth = false, @required BuildContext context}) async {
    String endpoint = API + url;
    Map<String, String> headers;
    if (hasAuth) {
      var token = Provider.of<CurrentUserProvider>(context, listen: false)
          .getloggedInUser
          .api_token;
      headers = {
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.connectionHeader: "Keep-Alive"
      };
    }
    print("init get request");

    try {
      final response = await http.get(Uri.parse(endpoint), headers: headers)
          // .timeout(Duration(milliseconds: 5000)
          ;

      if (response.statusCode == 200) {
        if (response.headers != null) {
          if (response.headers['x-pagination'] != null) {
            _orderListPaginationHeaders = response.headers;
          }
        }
        var data = json.decode(response.body);
        return HttpResponse(true, data);
      }

       if (response.statusCode == 204) {
        return HttpResponse(true, null);
      }

      if (response.statusCode == 401) {
        //  logout(context);
        //Phoenix.rebirth(context);
        return HttpResponse(false, null);
      } else {
        return HttpResponse(false, null);
      }
    } on TimeoutException catch (t) {
      showToastError(
          "Network Timeout, please check your network and try again");
    } catch (e) {
      showToastError("Failed to fetch data, please try again");
      return HttpResponse(false, e);
    }
  }

  Future<HttpResponse> postData(String url, dynamic data,
      {bool hasAuth = false, @required BuildContext context}) async {
    String endpoint = API + url;

    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      HttpHeaders.connectionHeader: "Keep-Alive"
    };
    if (hasAuth) {
      var token = Provider.of<CurrentUserProvider>(context, listen: false)
          .getloggedInUser
          .api_token;
      headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer $token",
        HttpHeaders.connectionHeader: "Keep-Alive"
      };
    }

    try {
      print("init post request");
      final response = await http.post(
        Uri.parse(endpoint),
        body: json.encode(data),
        headers: headers,
      );
      if (response.statusCode == 201) {
        var data = json.decode(response.body);
        return HttpResponse(true, data);
      }

      if (response.statusCode == 204) {
        return HttpResponse(true, null);
      }

      // if (response.statusCode == 200) {
      //   if (response.body == "") {
      //     return HttpResponse(true, null);
      //   } else {
      //     var data = json.decode(response.body);
      //     return HttpResponse(true, data);
      //   }
      // }

      if (response.statusCode == 200) {
        if (response.headers != null) {
          if (response.headers['x-pagination'] != null) {
            _orderListPaginationHeaders = response.headers;
          }
        }
        if (response.body == "") {
          return HttpResponse(true, null);
        }
        var data = json.decode(response.body);
        return HttpResponse(true, data);
      }

      if (response.statusCode == 401) {
        // logout(context);
        //Phoenix.rebirth(context);
        return HttpResponse(false, null);
      } else {
        var body = json.decode(response.body);
        this.lastError = body['message'];
        return HttpResponse(false, body);
      }
    } on FormatException catch (f) {
      this.lastError = f.message + " : " + f.source;
      return HttpResponse(false, this.lastError);
    } on Exception catch (e) {
      this.lastError = "Unexpected Error";
      return HttpResponse(false, this.lastError);
    }
  }

  Future<HttpResponse> putData(String url, dynamic data,
      {bool hasAuth = true, @required BuildContext context}) async {
    String endpoint = API + url;
    // return;
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8'
    };
    if (hasAuth) {
      var token = Provider.of<CurrentUserProvider>(context, listen: false)
          .getloggedInUser
          .api_token;
      headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: "Bearer $token"
      };
    }

    try {
      print("init put request");
      final response = await http.put(
        Uri.parse(endpoint),
        body: json.encode(data),
        headers: headers,
      );
      if (response.statusCode == 201) {
        var data = json.decode(response.body);
        return HttpResponse(true, data);
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (response.body == "") {
          return HttpResponse(true, null);
        } else {
          var data = json.decode(response.body);
          return HttpResponse(true, data);
        }
      } else {
        var body = json.decode(response.body);
        this.lastError = body['message'];
        return HttpResponse(false, this.lastError);
      }
    } on FormatException catch (f) {
      this.lastError = f.message + " : " + f.source;
      return HttpResponse(false, this.lastError);
    } on Exception catch (e) {
      this.lastError = "Unexpected Error";
      return HttpResponse(false, this.lastError);
    }
  }

  Future<HttpResponse> deleteData(String url,
      {bool hasAuth = false, @required BuildContext context}) async {
    String endpoint = API + url;
    Map<String, String> headers;
    // if (hasAuth) {
    //   var token = Provider.of<CurrentUserProvider>(context, listen: false)
    //       .getloggedInUser
    //       .token;
    //   headers = {HttpHeaders.authorizationHeader: "Bearer $token"};
    // }
    print("init delete request");

    final response = await http.delete(Uri.parse(endpoint), headers: headers);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return HttpResponse(true, null);
    }

    if (response.statusCode == 401) {
      // logout(context);
      //Phoenix.rebirth(context);
      return HttpResponse(false, null);
    } else {
      return HttpResponse(false, null);
    }
  }

  Map<String, dynamic> getResponseHeaderXPag() {
    if (_orderListPaginationHeaders == null) return null;
    return json.decode(_orderListPaginationHeaders['x-pagination']);
  }

  // static void logout(BuildContext context) async {
  //   var hiveBox = await Hive.openBox('testBox');
  //   hiveBox.delete('user');
  //   SignalrHelper.hubConnection?.stop();
  //   //Phoenix.rebirth(context);
  //   //pushNewScreen(context, withNavBar: false, screen: SignInPage());
  // }

  getLastError() {
    return this.lastError;
  }
}

class DebugHttpOverrides extends HttpOverrides {
  /// This Http Overrides bypass HTTPS Certificate check.
  /// Used for debugging in DEV environment only.
  /// This class defined in main.dart
  /// Please remove this class define in TEST or PROD env.
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
