import 'package:flutter/cupertino.dart';

class EstimatedTimeHelper {
  static String generateEstimatedDistance(distance){
    if(distance != null) {
      if (distance < 2) {
        return "10 - 30 mins";
      }
      else if(distance > 2 && distance < 3){
        return "20 - 40 mins";
      }
      else{
        return "40 - 60 mins";
      }
    }else{
      return "";
    }
  }
}