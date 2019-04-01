import 'History.dart';
import 'package:flutter/material.dart';
import 'League.dart';
import 'package:random_string/random_string.dart';

class User {
  String name = "";
  String userID = "";
  int steps = 0;
  int lifetimeSteps = 0;
  List<History> stepHistory;
  int personalGoal = 10000;
  int level = 1;
  List<League> leagues = new List();
  List<Widget> historyAsCardWidgets = new List();

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
    return this.stepHistory;
  }

  void addHistoryEntry(History history) {
    this.stepHistory.add(history);
  }

  void historyToCardWidgets() {
    for(int i = 0; i < this.stepHistory.length; i++) {
      this.historyAsCardWidgets.add(this.stepHistory[i].toWidget());
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
    print(this.level);
    while(this.lifetimeSteps > getLevelsStepRequirements(i+1)) {
      print("checking " + this.lifetimeSteps.toString() + ",  needs : " + getLevelsStepRequirements(i).toString());
      i++;
    }
    this.level = i;
    print(i.toString() + " new level");
  }

  int getLevelsStepRequirements(int level) {
    return level == 1 ? 0 : (15000 + (1000 * (level-1)));
  }

  double percentToNextLevel() {
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
      if((this.stepHistory.length-1-i) >= 0 && this.stepHistory[this.stepHistory.length-1-i] != null) {
        returnList[returnList.length-1-i] = this.stepHistory[this.stepHistory.length-1-i];
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

  void addLeague(League league) {
    this.leagues.add(league);
  }

  void hardCodeHistory() {
    List<History> hardcodedHistory = new List();
    for(int i = 0; i < 24; i++) {
      hardcodedHistory.add(new History(new DateTime(2019,3,1+i), int.parse(randomNumeric(4)), 8000));
    }
    this.stepHistory = hardcodedHistory;
  }
}