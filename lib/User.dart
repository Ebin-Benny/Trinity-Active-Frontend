import 'package:circular_indicator_test/LeagueMember.dart';

import 'History.dart';
import 'package:flutter/material.dart';
import 'League.dart';
import 'package:random_string/random_string.dart';

class User {
  String name = "";
  String userID = "";
  int steps = 0;
  int lifetimeSteps = 0;
  List<History> stepHistory = new List();
  int personalGoal = 10000;
  int level = 1;
  List<League> leagues = new List();
  List<Widget> historyAsCardWidgets = new List();
  List<LeagueMember> usersLeagueMembers = new List();

  User(String userID, String name, int steps, int personalGoal, int multiplier, int lifetimeSteps, int level) {
    this.name = name;
    this.steps = steps;
    this.personalGoal = personalGoal;
    this.lifetimeSteps = lifetimeSteps;
    this.level = level;
    this.userID = userID;
    //leagues.add(new League(20000, "test"));
  }

  User.newUser(String userID, String name) {
    this.userID = userID;
    this.name = name;
  }

  void setName(String name) {
    this.name = name;
  }

  void setSteps(int steps) {
    this.steps = steps;
  }

  void setLifetimeSteps(int steps) {
    this.lifetimeSteps = steps;
  }

  void setPersonalGoal(int personalGoal) {
    this.personalGoal = personalGoal;
  }

  void setStepHistory(List<History> stepHistory) {
    this.stepHistory = stepHistory;
  }

  String getName() {
    return this.name;
  }

  int getSteps() {
    return this.steps;
  }

  int getLifetimeSteps() {
    return this.lifetimeSteps;
  }

  int getPersonalGoal() {
    return this.personalGoal;
  }

  String getUserID() {
    return this.userID;
  }

  int getLevel() {
    return this.level;
  }

  List<History> getStepHistory() {
    return this.stepHistory.reversed.toList();
  }

  void addHistoryEntry(History history) {
    List<History> temp = new List();
    temp.add(history);
    for(int i = 0; i < this.stepHistory.length; i++) {
      temp.add(this.stepHistory[i]);
    }
    this.stepHistory = temp;

  }

  void historyToCardWidgets() {
    for(int i = 0; i < this.stepHistory.length; i++) {
      this.historyAsCardWidgets.add(this.stepHistory[i].toWidget());
      print(this.historyAsCardWidgets[i]);
    }

  }

  List<Widget> getHistoryAsCardWidgets() {
    return this.historyAsCardWidgets;
  }


  void addHistoryAsCardWidget(History history) {
    this.historyAsCardWidgets.add(history.toWidget());
  }

  void updateLevel() {
    int i = this.level;
//    print(this.level);
    while(this.lifetimeSteps > getLevelsStepRequirements(i+1)) {
//      print("checking " + this.lifetimeSteps.toString() + ",  needs : " + getLevelsStepRequirements(i).toString());
      i++;
    }
    this.level = i;
//    print(i.toString() + " new level");
  }

  int getLevelsStepRequirements(int level) {
    return level == 1 ? 0 : (8000 + ( 15000 * (level-1)));
  }

  double percentToNextLevel() {
    updateLevel();
    double percent = (this.lifetimeSteps - getLevelsStepRequirements(this.level)) / (getLevelsStepRequirements(this.level+1) - getLevelsStepRequirements(this.level));
    return percent;
//    return 0.5;
  }

  int stepsToNextLevel() {
    return (getLevelsStepRequirements(this.level+1) - this.lifetimeSteps);
  }

  List<History> historyLast30Days() {
    List<History> returnList = new List(30);
    for(int i = 0; i < 30; i++) {
      if((this.getStepHistory().length-1-i) >= 0 && this.getStepHistory()[this.getStepHistory().length-1-i] != null) {
        returnList[returnList.length-1-i] = this.getStepHistory()[this.getStepHistory().length-1-i];
      }
    }
    return returnList;
  }

  int highestStepCountFromList(List<History> history) {
    int highestStep = 1;
    for(History h in history) {
      if(h != null && h.getSteps() > highestStep) {
        highestStep = h.getSteps();
      }
    }
    return highestStep;
  }

  bool addLeague(League league) {
    updateUserAsLeagueMembersList();
    for(League l in this.leagues) {
      if(l.leagueID == league.leagueID && league.leagueID != null) {
        return false;
      }
    }
    this.leagues.add(league);
    return true;
  }

  void hardCodeHistory() {
    List<History> hardcodedHistory = new List();
    for(int i = 0; i < 24; i++) {
      hardcodedHistory.add(new History(new DateTime(2019,3,1+i), int.parse(randomNumeric(4)), 8000));
    }
    this.stepHistory = hardcodedHistory;
  }

  void updateCardHistory() {
    List<Widget> temp = new List();
    for(int i = 0; i < this.stepHistory.length; i++) {
      temp.add(this.stepHistory[i].toWidget());
    }
    this.historyAsCardWidgets = temp;
  }

  //called when new league is added
  void updateUserAsLeagueMembersList() {
    for(int i = 0; i < this.leagues.length; i++) {
      for(int j = 0; j < this.leagues[i].members.length; j++) {
        if(this.leagues[i].members[j].userId == this.userID) {
          usersLeagueMembers.add(this.leagues[i].members[j]);
        }
      }
    }
  }

//Called periodically, maybe like every 30 mins or so
  void updateUserAsLeagueMembersSteps(int steps) {
    for(int i = 0; i < this.usersLeagueMembers.length; i++) {

    }
  }

  void calculateLifetimeSteps() {
    for (int i = 0; i < this.getStepHistory().length; i++) {
      this.lifetimeSteps = this.lifetimeSteps + this.getStepHistory()[i].steps;
    }
  }
}
