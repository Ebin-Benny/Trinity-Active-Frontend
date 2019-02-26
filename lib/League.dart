import 'User.dart';

class League {
  String name;
  int goal;
  List<User> members;

  League(List<User> members, int goal, String name) {
    this.members = members;
    this.name = name;
    this.goal = goal;
  }
}