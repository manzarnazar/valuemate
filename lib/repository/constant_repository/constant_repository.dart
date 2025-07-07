

import 'dart:ui';


import 'package:valuemate/data/network/network_api_services.dart';
import 'package:valuemate/models/constant_model/constant_model.dart';

class ConstantRepository {

  final _apiService  = NetworkApiServices() ;

  Future<Constants> fetchConstants() async{
    dynamic response = await _apiService.postApi({}, "https://valuma8.com/api/constants");
    return Constants.fromJson(response) ;
  }


}