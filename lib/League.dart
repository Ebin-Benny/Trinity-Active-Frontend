
import 'LeagueMember.dart';

class League {
  String name;
  int goal;
  List<LeagueMember> members;

  League(List<LeagueMember> members, int goal, String name) {
    this.members = members;
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