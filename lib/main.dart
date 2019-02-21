import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';

void main() {
  runApp(new MaterialApp(home: new Scaffold(body: new SamplePage())));
}

class SamplePage extends StatefulWidget {
  @override
  _SamplePageState createState() => _SamplePageState();
}

const double RADIUS = 250;
bool isCompleted = false;
Color blue = Colors.blue;
Color blueDark = Colors.blue[700];



class _SamplePageState extends State<SamplePage> {
  int _currentIndex = 1;

  StreamSubscription<int> _subscription;

  _openPage(Widget page) {
    Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (BuildContext context) => page,
      ),
    );
  }

  String currentLeagueName = "SWENG 37";
  int steps = 0;
  int goal = 3000;
  List<Widget> _screens = [null, null, null];


  @override
  Widget build(BuildContext context) {

    setUpPedometer();
    Widget home = sampleHome(currentLeagueName, steps, goal);
    Widget history = historyPage();
    Widget leagues = leaguesPage();
    _screens[1] = home;
    _screens[0] = history;
    _screens[2] = leagues;
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Trinity Active"),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar:
      BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              title: Text("History")),
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text("Home")),
          BottomNavigationBarItem(
              icon: Icon(Icons.group),
              title: Text("Leagues"))
        ],
      ),
    );
  }

  void addStep() {
    setState(() {
      steps++;
    });
  }

  void setUpPedometer() {
    Pedometer pedometer = new Pedometer();
    _subscription = pedometer.stepCountStream.listen(_onData,
        onError: _onError, onDone: _onDone, cancelOnError: true);
  }

  void _onData(int stepCountValue) async {
    setState(() {
      steps = stepCountValue;
      if(steps >= goal) {
        _toggleCompletion();
      }
    });
  }
  void _onDone() => print("Finished pedometer tracking");

  void _onError(error) => print("Flutter Pedometer Error: $error");

  void _onCancel() => _subscription.cancel();

  //TODO : temp implementation
  void _toggleCompletion() {
    setState(() {
      isCompleted = true;
    });
  }

}

//TODO : Figure out how we are going to store the steps and goal values
CircularPercentIndicator mainIndicator(int steps, int goal) {
  int score = steps * 2;
  return new CircularPercentIndicator(
    startAngle: 180,
    radius: RADIUS,
    lineWidth: 15,
    animation: true,
    percent: steps < goal ? steps / goal : 1,
    center: Column(
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
        ),
        new Text(
        "SCORE".toString(),
          style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.5), fontWeight: FontWeight.bold,),
        ),
        new Text(
          score.toString(),
          style: TextStyle(fontSize: 50, color: isCompleted ? Colors.lightGreenAccent[700] : Colors.blue, fontWeight: FontWeight.bold,),
        ),
        new Text(
          "STEPS",
          style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.5), fontWeight: FontWeight.bold,),
        ),
        new Text(
          steps.toString(),
          style: TextStyle(fontSize: 24, color: isCompleted ? Colors.lightGreenAccent[700] : Colors.blue, fontWeight: FontWeight.bold,),
        ),
      ],
    ),
    footer: Column(
      children: <Widget>[
        new Padding(padding: EdgeInsets.symmetric(vertical: 7)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'images/goal_image.png',
              height: 30,
              width: 25,
            ),
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 3),
            ),
            new Text(
                goal.toString(),
                style: TextStyle(fontSize: 24, color: Colors.grey.withOpacity(0.8), fontWeight: FontWeight.bold,)
            ),
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 3),
            ),
            Image.asset(
              'images/steps_image.png',
              height: 30,
              width: 25,
            ),
          ],
        ),
      ],
    ),
    circularStrokeCap: CircularStrokeCap.round,
    progressColor: isCompleted ? Colors.lightGreenAccent[400] : Colors.blue,
    backgroundColor: Colors.grey.withOpacity(0.2),

  );

}


//Made this it's own entire widget so we can control what widgets are displayed(for changing screens)
Widget sampleHome(String currentLeagueName, int steps, int goal) {
  return (Center(
    child: ListView(
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group, color: Colors.grey.withOpacity(0.8),),
                new Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2),
                ),
                new Text(
                  currentLeagueName,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.grey.withOpacity(1)),
                ),
              ]
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey.withOpacity(0.8),),
                Stack(
                  children: <Widget>[
                    mainIndicator(steps, goal),
                    Positioned(
                      top: RADIUS-22,
                      left: RADIUS/2 - 30,
                      child: Container(
                        color: isCompleted ? Colors.lightGreenAccent[700] : Colors.blue[700],
                        width: 60,
                        height: 40,
                        child: Center(
                          child: Text(
                            "x2",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold,),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.withOpacity(0.8),)
              ]

          ),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //Temporarily hardcoded just for visual example and testing ListTile
                const ListTile(
                  leading: Text("1."),
                  title: Text('Owen Johnston'),
                  trailing: Text("7500"),
                ),
                const ListTile(
                  leading: Text("2."),
                  title: Text(
                    'YOU',
                    style: TextStyle(color: Colors.blue),
                  ),
                  trailing: Text("5132"),
                ),
                const ListTile(
                  leading: Text("3."),
                  title: Text('Caolan Wall'),
                  trailing: Text("4789"),
                ),
                const ListTile(
                  leading: Text("4."),
                  title: Text('Ebin Benny'),
                  trailing: Text("3467"),
                ),
                const ListTile(
                  leading: Text("5."),
                  title: Text('David Scollard'),
                  trailing: Text("2104"),
                ),
                const ListTile(
                  leading: Text("6."),
                  title: Text('Baptiste Frere'),
                  trailing: Text("1869"),
                ),
                const ListTile(
                  leading: Text("7."),
                  title: Text('John Zhang'),
                  trailing: Text("1045"),
                ),
              ],
            ),
          ),
        ]),
  ));
}

Widget historyPage() {
  Container(
    alignment: Alignment.center,
    color: Colors.grey,
  );
}

Widget leaguesPage() {
  Container(
    alignment: Alignment.center,
    color: Colors.lightBlue,
  );
}



