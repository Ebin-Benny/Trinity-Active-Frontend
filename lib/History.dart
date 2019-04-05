import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class History {
  DateTime day;
  int steps;
  bool isComplete = false;
  int goal;
  Widget historyAsCard;
  String prettyDate = "";

  History(DateTime day, int steps, int goal) {
    this.day = day;
    this.steps = steps;
    this.goal = goal;
    if(steps >= goal) {
      isComplete = true;
    }
    switch(day.month) {
      case 1:
        prettyDate = prettyDate + "Jan";
        break;
      case 2:
        prettyDate = prettyDate + "Feb";
        break;
      case 3:
        prettyDate = prettyDate + "Mar";
        break;
      case 4:
        prettyDate = prettyDate + "Apr";
        break;
      case 5:
        prettyDate = prettyDate + "May";
        break;
      case 6:
        prettyDate = prettyDate + "June";
        break;
      case 7:
        prettyDate = prettyDate + "July";
        break;
      case 8:
        prettyDate = prettyDate + "Aug";
        break;
      case 9:
        prettyDate = prettyDate + "Sept";
        break;
      case 10:
        prettyDate = prettyDate + "Oct";
        break;
      case 11:
        prettyDate = prettyDate + "Nov";
        break;
      case 12:
        prettyDate = prettyDate + "Dec";
        break;
    }
    prettyDate = prettyDate + " " + day.day.toString() + ", " + day.year.toString();
  }

  Widget toWidget() {
    return(
        Card(
          child: Column(
            children: <Widget>[
              Container(
                constraints: BoxConstraints.expand(height: 30),
                decoration: new BoxDecoration(
                  color: Colors.lightBlue[200],
                  border: new Border.all(
                    color: Colors.lightBlue[200],
                    width: 5,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: new BorderRadius.vertical(
                    top: new Radius.circular(5),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    new Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                    new Text(
                      this.prettyDate,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),

                  ],
                ),
              ),
              new Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Image.asset(
                    "images/steps_image.png",
                    height: 40,
                    width: 35,
                  ),
                  new Text(
                    this.steps.toString(),
                    style: TextStyle(
                        color: this.isComplete ? Colors.lightGreenAccent[700] : Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 50
                    ),

                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  LinearPercentIndicator(
                    animation: false,
                    width: 300,
                    lineHeight: 10,
                    progressColor: this.isComplete ? Colors.lightGreenAccent : Colors.blue,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    percent: this.steps >= this.goal ? 1.0 : this.steps/this.goal,
                  ),
                  Column(
                    children: <Widget>[
                      Image.asset(
                        "images/goal_image.png",
                        width: 20,
                        height: 20,
                      ),
                      new Text(
                        this.goal.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey
                        ),
                      )
                    ],
                  )
//                  new Text(
//                    this.goal.toString(),
//                    style: TextStyle(
//                      fontWeight: FontWeight.bold,
//                      color: Colors.grey
//                    ),
//                  )
                ],
              ),
              new Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            ],
          ),
        )
    );
  }

  int getSteps() {
    return this.steps;
  }
}