
import 'LeagueMember.dart';
import 'User.dart';

class League {
  String leagueID;
  String name;
  int goal;
  List<LeagueMember> members = new List();

  League(int goal, String name) {
    this.name = name;
    this.goal = goal;
  }

  LeagueMember getMember(String userID) {
    for(int i = 0; i < this.members.length; i++) {
      if(this.members[i].userId == userID) {
        return this.members[i];
      }
    }
    return null;
  }

  void addMember(String userID) {

  }
}