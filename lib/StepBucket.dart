class StepBucket {
  int _step;
  int day;
  int stepOffset;

  StepBucket(int step, int day) {
    this._step = step;
    this.day = day;
    this.stepOffset = 0;
  }

  StepBucket.fromJson(Map<String, dynamic> data) {
    _step = data['step'];
    day = data['day'];
  }

  Map<String, dynamic> toJson() => {
    'step': _step,
    'day': day,
  };

  void updateSteps(int step) {
    this._step = step - stepOffset;
  }

  int getSteps() {
    return this._step;
  }

  int getDay() {
    return this.day;
  }

  String toString() {
    return "Day: " + this.day.toString() + "  Steps: " + this._step.toString();
  }



}