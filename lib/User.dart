import 'History.dart';

class User {
  String name = "";
  String userID = "";
  int steps = 0;
  int lifetimeSteps = 0;
  int multiplier = 1;
  List<History> stepHistory;
  int personalGoal = 0;
  int level = 0;

  User(String userID, String name, int steps, int personalGoal, int multiplier, int lifetimeSteps, int level) {
    this.name = name;
    this.steps = steps;
    this.personalGoal = personalGoal;
    this.multiplier = multiplier;
    this.lifetimeSteps = lifetimeSteps;
    this.level = level;
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

  void setMultiplier(int multiplier) {
    this.multiplier = multiplier;
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

  int getMultiplier() {
    return this.multiplier;
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
}