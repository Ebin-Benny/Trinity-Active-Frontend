class History {
  DateTime day;
  int steps;
  bool isComplete = false;
  int goal;
  History(DateTime day, int steps, int goal) {
    this.day = day;
    this.steps = steps;
    this.goal = goal;
    if(steps >= goal) {
      isComplete = true;
    }
  }
}