import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:vplus/helper/appConfigHelper.dart';
import 'package:vplus/providers/currentuser_provider.dart';

enum RequestType { GET, POST, DELETE }

class Helper {
  //prod
  //final String API = "http://13.238.247.236/";

  //test
  //static const String API = "http://13.54.163.1/";
  String lastError = "";
  var box;
  Helper() {
    Hive.openBox('testBox').then((value) {
      this.box = value;
    });
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

  Future<dynamic> getData(String url,
      {bool hasAuth = false, @required BuildContext context}) async {
    String endpoint = AppConfigHelper.getApiUrl + url;
    Map<String, String> headers;
    var token = Provider.of<CurrentUserProvider>(context, listen: false)
        .getloggedInUser
        .api_token;
    print(token);
    if (hasAuth) {
      headers = {HttpHeaders.authorizationHeader: "Bearer $token"};
    }
    // return;

    final response = await http.get(Uri.parse(endpoint), headers: headers);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      print(data);
      return data;
    }

    if (response.statusCode == 401) {
      logout();
      Phoenix.rebirth(context);
    } else {
      return [];
    }
  }

  Future<dynamic> postData(String url, dynamic data,
      {bool hasAuth = false, @required BuildContext context}) async {
    String endpoint = AppConfigHelper.getApiUrl + url;
    print(endpoint);
    print(json.encode(data));
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
      final response = await http.post(
        Uri.parse(endpoint),
        body: json.encode(data),
        headers: headers,
      );
      if (response.statusCode == 201) {
        var data = json.decode(response.body);
        return data;
      }

      if (response.statusCode == 200) {
        if (response.body == "") {
          return "";
        } else {
          var data = json.decode(response.body);
          return data;
        }
      }

      if (response.statusCode == 401) {
        logout();
        Phoenix.rebirth(context);
      } else {
        if (response.body.isNotEmpty) {
          var body = json.decode(response.body);
          this.lastError = body['message'];
          print(body['message']);
        }

        return null;
      }
    } on FormatException catch (f) {
      print("exception");
      print(f);
      this.lastError = f.message + " : " + f.source;
      //this.showToastError("Error Occured");
    } on Exception catch (e) {
      this.lastError = "Unexpected Error";
      //this.showToastError("Error Occured");
    }
  }

  Future<Map<String, dynamic>> putData(String url, dynamic data,
      {bool hasAuth = true, @required BuildContext context}) async {
    String endpoint = AppConfigHelper.getApiUrl + url;
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
      final response = await http.put(
        Uri.parse(endpoint),
        body: json.encode(data),
        headers: headers,
      );
      if (response.statusCode == 201) {
        var data = json.decode(response.body);
        return data;
      }

      if (response.statusCode == 200) {
        if (response.body == "") {
          return null;
        } else {
          var data = json.decode(response.body);
          return data;
        }
      } else {
        var body = json.decode(response.body);
        this.lastError = body['message'];
        print(body['message']);
        return null;
      }
    } on FormatException catch (f) {
      print("exception");
      print(f);
      this.lastError = f.message + " : " + f.source;
      //this.showToastError("Error Occured");
    } on Exception catch (e) {
      this.lastError = "Unexpected Error";
      // this.showToastError("Error Occured");
    }
  }

  static void logout() async {
    var hiveBox = await Hive.openBox('testBox');
    hiveBox.delete('user');
  }

  getLastError() {
    return this.lastError;
  }
}
