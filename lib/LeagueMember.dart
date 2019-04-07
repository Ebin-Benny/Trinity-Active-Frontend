import 'User.dart';
import 'MultiplierBucket.dart';
class LeagueMember {
  //UserID that the league member is related to
  String userId;

  String name = "TEST NAME";

  User user;

  //LeagueID of the league that this is a member to
  String leagueID;

  int leagueGoal;

  //Users score in the league
  int score = 0;

  //Users multiplier in the league
  int multiplier = 1;

  int steps = 0;

  bool isComplete = false;

  MultiplierBucket multiplierBucket;

  bool getIsComplete() {
    return this.isComplete;
  }

  LeagueMember (String userID, String name, String leagueID, int score) {
    this.userId = userID;
    this.leagueID = leagueID;
    this.score = score;
    this.name = name;
    this.multiplierBucket = new MultiplierBucket(multiplier, steps);
  }

  LeagueMember.leagueless (String userID, String name, int score) {
    this.userId = userID;
    this.score = score;
    this.name = name;
  }

  void setLeagueId(String id) {
    this.leagueID = id;
  }

  void checkCompletion() {
    if(steps <= this.leagueGoal) {
      this.isComplete = true;
    }
    else {
      this.isComplete = false;
    }
  }


}