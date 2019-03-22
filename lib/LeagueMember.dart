import 'User.dart';
class LeagueMember {
  //UserID that the league member is related to
  String userId;

  User user;

  //LeagueID of the league that this is a member to
  String leagueID;

  int leagueGoal;

  //Users score in the league
  int score;

  //Users multiplier in the league
  int multiplier;

  int steps;

  bool isComplete = false;

  bool getIsComplete() {
    return this.isComplete;
  }

}