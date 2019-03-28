import 'dart:async';

import 'package:http/http.dart' as http;
import 'User.dart';
import 'dart:convert';
import 'History.dart';

class Request {

  static Future<User> getUserHomepage(User user) async {

    var uri = new Uri.http('68.183.45.201:3001','getUserHomepage/'+user.getUserID());
    //var uri = '68.183.45.201:3001/getUserHomepage/5c922af211d76f46182883f2';
    var response = await http.get(uri);

    if(response.statusCode == 200){
      //success : we have a json

      updateUserFromJSon(json.decode(response.body),user);
      return user;
    }
    else{
      throw Exception('failed to get from the server');
    }
  }
  //We can create a method here to convert Json to a class

  static postNewUser(User user) async{
    http.post(Uri.encodeFull("68.183.45.201:3001/createNewUser"), body: {"name": user.getUserID(), "steps": user.getSteps().toString()}).then((result) {
      //handle response code
      if(result.statusCode != 200){
        throw Exception("fail to post info to the server");
      }
    });
  }

  static updateUserSteps(User user) async{

    var uri = new Uri.http('68.183.45.201:3001','/updateUser/'+user.getUserID(),{"steps" : user.getSteps().toString()});
    var result = await http.get(uri);
    if(result.statusCode != 200){
      throw Exception("fail to post info to the server");
    }
  }

  static updateUserFromJSon(Map<String, dynamic> json,User user){
    var historyList = new List<History>();
    var list = new List<dynamic>();
    list = json['data'];
    for(var i=0;i<list.length;i++){
          var md = list[i]['day'].split('-');
          var date = new DateTime(list[i]['year'],int.parse(md[1]),int.parse(md[0]));
          historyList.add(new History(date,list[i]['steps'], list[i]['goal']));
        }
    user.setStepHistory(historyList);
    return user;
  }
}