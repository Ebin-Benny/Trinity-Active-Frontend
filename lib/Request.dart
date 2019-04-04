import 'dart:async';

import 'package:http/http.dart' as http;
import 'User.dart';
import 'dart:convert';
import 'History.dart';
import 'League.dart';
import 'LeagueMember.dart';

class Request {

  static Future<User> getUserHomepage(User user) async {
    //Takes an user and return update it with the last 5 days
    var uri = new Uri.http('68.183.45.201:3001','getUserHomepage/'+user.getUserID());
    //var uri = '68.183.45.201:3001/getUserHomepage/5c922af211d76f46182883f2';
    var response = await http.get(uri);
    if(response.statusCode == 200){
      //success : we have a json
      _updateUserFromJSon(json.decode(response.body),user);
      return user;
    }
    else{
      throw Exception('failed to get from the server');
    }
  }

  static Future<bool> userLookup(String userID) async {
    //Return if the user is or isn't in the database
    var uri = new Uri.http('68.183.45.201:3001','userLookup/'+userID);
    var response = await http.get(uri);
    if(response.statusCode == 200){
      bool result = json.decode(response.body)['data']==1;
      if(result) {
        print("User returned!");
      }
      //no fail
      return result;


    }
    else{
      throw Exception('failed to lookup an user from the server');
    }
  }

  static postNewUser(User user) async{
    //Adds an user to the database

    http.post(Uri.encodeFull("http://68.183.45.201:3001/createNewUser/"+user.getUserID()+"?name="+user.getName()+"&steps="+user.getSteps().toString())).then((result) {
        //handle response code
      if(result.statusCode != 200){
        throw Exception("fail to post info to the server");
      }
      else {
        print("Success");
      }
    });
  }


  static addUserToLeague(String leagueID,User user) async{
    //Takes an existing leagueID and add the user to the league corresponding
    http.patch(Uri.encodeFull("http://68.183.45.201:3001/addLeagueMember?leagueId="+leagueID+"&memberId="+user.getUserID()+"&userName="+user.getName())).then((result) {
      //handle response code
      if(result.statusCode != 200){
        throw Exception("fail to patch info to the server");
      }
    });
  }

  static Future<String> postNewLeague(League league,LeagueMember member) async{
    //Create a new league with the user in it and returns the leagueId
    String res = "";
    await http.post(Uri.encodeFull("http://68.183.45.201:3001/createNewLeague?name="+league.name+"&memberId="+member.userId+"&userName="+member.name)).then((result) {
      //handle response code
      if(result.statusCode != 200){
        throw Exception("fail to post info to the server");
      }
      else{
        res = json.decode(result.body)['data']['leagueId'];
      }
    });
    return res;
  }

  static Future<League> getLeague(String leagueID) async {
    var uri = new Uri.http('68.183.45.201:3001','getLeague/'+leagueID);
    var response = await http.get(uri);
    if(response.statusCode == 200){
      var res = json.decode(response.body)['data'];
      var league = new League.withID(10000,res['leagueName'],leagueID);
      var list = new List<dynamic>();
      list = res['members'];
      for(var i=0;i<list.length;i++){
        league.addMember(new LeagueMember(list[i]['memberId'], list[i]['name'], leagueID, list[i]['score']));
      }
      print(league.leagueID);
      return league;
    }
    else{
      throw Exception('failed to get league from the server');
    }
  }

  static updateUserSteps(User user) async{
    //update the steps of the user in the database
    var uri = new Uri.http('68.183.45.201:3001','/updateUser/'+user.getUserID(),{"steps" : user.getSteps().toString()});
    var result = await http.get(uri);
    if(result.statusCode != 200){
      throw Exception("fail to post info to the server");
    }
  }

  static _updateUserFromJSon(Map<String, dynamic> json,User user){
    var historyList = new List<History>();
    if(json['data']==("No history available")){
      user.setStepHistory(historyList);
      return user;
    }
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