import 'dart:async';

import 'package:circular_indicator_test/MultiplierBucket.dart';
import 'package:http/http.dart' as http;
import 'User.dart';
import 'dart:convert';
import 'History.dart';
import 'League.dart';
import 'LeagueMember.dart';
import 'StepBucket.dart';

class Request {

  static Future<User> getUserHomepage(User user) async {
    //Takes an user and return update it with the last 5 days
    var uri = new Uri.http('68.183.45.201:3001','getUserHomepage/'+user.getUserID());
    //var uri = new Uri.http('68.183.45.201:3001','getUserHomepage/'+'2224960227567988');
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

  static Future<MultiplierBucket> updateScore(LeagueMember member) async{
    MultiplierBucket bucket;
    await http.patch(Uri.encodeFull("http://68.183.45.201:3001/updateUserScore/"+member.userId+"?leagueId="+member.leagueID)).then((result) {
      //handle response code
      if(result.statusCode != 200){
        throw Exception("fail to update score to the server");
      }
      print(json.decode(result.body));
      bucket = new MultiplierBucket(json.decode(result.body)['data']['multiplier'], json.decode(result.body)['data']['score']);
    });
    print(bucket.score.toString() + "   " + bucket.multiplier.toString());
    return bucket;

  }

  //We need a request to updateLeagueMember(LeagueMember member, League league) {



  //}

  static Future<League> addUserToLeague(String leagueID,User user) async{
    League l;
    //Takes an existing leagueID and add the user to the league corresponding
    await http.patch(Uri.encodeFull("http://68.183.45.201:3001/addLeagueMember?leagueId="+leagueID+"&memberId="+user.getUserID()+"&userName="+user.getName())).then((result) {
      //handle response code
      if(result.statusCode != 200){
        throw Exception("fail to add league user to the server");
      }
      print(json.decode(result.body));
      l = _createLeague(json.decode(result.body));
      print("||||||||||||||||||||||||||||||||||||||" + l.toString() + "||||||||||||||||||||||||||||||||||||||");

    });
    return l;
  }

  static Future<String> postNewLeague(League league,LeagueMember member) async{
    //Create a new league with the user in it and returns the leagueId
    String res = "";
    await http.post(Uri.encodeFull("http://68.183.45.201:3001/createNewLeague?name="+league.name+"&memberId="+member.userId+"&userName="+member.name+"&goal="+league.goal.toString())).then((result) {
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
      return _createLeague(json.decode(response.body));
    }
    else{
      throw Exception('failed to get league from the server');
    }
  }

  static updateUserSteps(User user, StepBucket bucket) async{
    //update the steps of the user in the database
    var uri = new Uri.http('68.183.45.201:3001','/updateUser/'+user.getUserID(),{"steps" : bucket.getSteps().toString()});
    var result = await http.get(uri);
    if(result.statusCode != 200){
      throw Exception("fail to post info to the server");
    }
  }

  static updateGoal(User user) async{
    var uri = new Uri.http('68.183.45.201:3001','/updateUserGoal/'+user.getUserID(),{"goal" : user.getPersonalGoal().toString()});
    var result = await http.get(uri);
    if(result.statusCode != 200){
      throw Exception("fail to post new goal to the server");
    }
  }

  static Future<void> updateTodays(LeagueMember member,bool todays) async{
    //Takes an existing leagueID and add the user to the league corresponding
    await http.patch(Uri.encodeFull("http://68.183.45.201:3001/updateBool/"+member.userId+"&leagueId="+member.leagueID+"&bool="+todays.toString())).then((result) {
      //handle response code
      if(result.statusCode != 200){
        throw Exception("fail to update todays to the server");
      }
    });
  }

  static League _createLeague(Map<String, dynamic> value){
    var res = value['data'];
    var league;
    String leagueId;
    if(res['goal'] != null) {
      leagueId = res['leagueId'];
      league = new League.withID(res['goal'],res['leagueName'],res['leagueId']);
    } else {
      leagueId = res['leagueId'];
      league = new League.withID(10000,res['leagueName'],res['leagueId']);
    }
    var list = new List<dynamic>();
    list = res['members'];
    for(var i=0;i<list.length;i++){
      LeagueMember newMember = new LeagueMember(list[i]['memberId'], list[i]['name'], leagueId, list[i]['score']);
      newMember.multiplierBucket.multiplier = list[i]['multiplier'];
      if(list[i]['updatedToday'] != null){
        newMember.setHasUpdatedToday(list[i]['updatedToday']);
      }
      league.addMember(newMember);
    }
    print(league.leagueID);
    return league;
  }

  static _updateUserFromJSon(Map<String, dynamic> json,User user){
    var historyList = new List<History>();
    if(json['data']==("No history available")){
      user.setStepHistory(historyList);
      return user;
    }
    var list = new List<dynamic>();
    list = json['data']['hist'];
    for(var i=0;i<list.length;i++){
          var md = list[i]['day'].split('-');
          var date = new DateTime(list[i]['year'],int.parse(md[1]),int.parse(md[0]));
          historyList.add(new History(date,list[i]['steps'], list[i]['goal']));
          print(date.toString() + "  " + list[i]['steps'].toString());
    }
    list = json['data']['league'];
    for(var i=0;i<list.length;i++){
          String id = list[i].toString();
          League league;
          Request.getLeague(id).then((League result){
            league = result;
            user.addLeague(league);
          });

    }
    //print(json['data']['goal'] + "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||");
    user.setPersonalGoal(json['data']['goal']);
    user.setLifetimeSteps(json['data']['lifetimeSteps']);
    user.setStepHistory(historyList);
    //user.calculateLifetimeSteps();
    return user;
  }
}