import 'dart:async';

import 'package:http/http.dart' as http;
import 'User.dart';
import 'dart:convert';
import 'History.dart';

class Request {

  static Future<User> getUserHomepage(String id) async {
    var uri = new Uri.http('68.183.45.201:3001','getUserHomepage/'+id);
    //var uri = '68.183.45.201:3001/getUserHomepage/5c922af211d76f46182883f2';
    var response = await http.get(uri);

    if(response.statusCode == 200){
      //success : we have a json

      return createUserFromJSon(json.decode(response.body)['data']);
    }
    else{
      throw Exception('failed to get from the server');
    }
  }
  //We can create a method here to convert Json to a class

  static putInfo(){
    String json = "";
    //Create/convert class to json
    http.put(Uri.encodeFull("placeholder"), body: json).then((result) {
      //handle response code
      if(result.statusCode != 200){
        throw Exception("fail to put info to the server");
      }
    });
  }

  static User createUserFromJSon(Map<String, dynamic> json){
    String userID = json['_id'];
    String name = json['name'];
    int steps = 666; //didn't find , maybe take from history ?
    int personalGoal = 666; //didn't find , maybe take from history ?
    int multiplier = 1; //didn't find it in json
    int lifetimeSteps = json['totalSteps'];
    int level = 1; //didn't find it in json
    var user = new User(userID, name, steps, personalGoal, multiplier, lifetimeSteps, level);
    var historyList = new List<History>();
    //get history ?
    user.setStepHistory(historyList);
    return user;
  }
}