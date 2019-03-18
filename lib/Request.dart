import 'dart:async';

import 'package:http/http.dart' as http;

class Request {

  Future<http.Response> getInfo() async {
    final response = await http.get('placeholder adress');

    if(response.statusCode == 200){
      //success : we have a json
      return response;
    }
    else{
      throw Exception('failed to get from the server');
    }
  }

  //We can create a method here to convert Json to a class
}