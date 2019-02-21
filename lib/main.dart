import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';
import 'dart:math';

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
TimeOfDay now = TimeOfDay.now();
int _score = 0;
int _steps = 0;
int _multiplier = 1;



class _SamplePageState extends State<SamplePage> with TickerProviderStateMixin{
  int _currentIndex = 1;

  //Animation
  //-----------------------------------------------
//  final duration = new Duration(milliseconds: 300);
//  Timer timer;
//  int _counter = 0;
//  double _sparklesAngle = 0.0;
//  Animation sparklesAnimation;
//  AnimationController sparklesAnimationController;
//  Random random;
//
//
//  initState() {
//    super.initState();
//    sparklesAnimationController = new AnimationController(vsync: this, duration: duration);
//    sparklesAnimation = new CurvedAnimation(parent: sparklesAnimationController, curve: Curves.easeIn);
//    sparklesAnimation.addListener((){
//      setState(() { });
//    });
//  }
//
//  dispose() {
//    super.dispose();
//  }
//
//
//
//  void increment(Timer t) {
//    sparklesAnimationController.forward(from: 0.0);
//    setState(() {
//      _counter++;
//      _sparklesAngle = random.nextDouble() * (2*pi);
//    });
//  }
//
//  Widget widgetAnimation() {
//    var stackChildren = <Widget>[
//    ];
//
//    var firstAngle = _sparklesAngle;
//    var sparkleRadius = (sparklesAnimationController.value * 50);
//    var sparklesOpacity = (1 - sparklesAnimation.value);
//
//
//    for (int i = 0; i < 5; ++i) {
//      var currentAngle = (firstAngle + ((2 * pi) / 5) * (i));
//      var sparklesWidget =
//      new Positioned(
//        child:
//        new Transform.rotate(
//            angle: currentAngle - pi / 2,
//            child:
//            new Opacity(
//                opacity: sparklesOpacity,
//                child:
//                new Image.asset(
//                  "images/sparkles.png",
//                  width: 14.0,
//                  height: 14.0,
//                )
//            )
//        ),
//        left: (sparkleRadius * cos(currentAngle)) + 20,
//        top: (sparkleRadius * sin(currentAngle)) + 20,
//      );
//      stackChildren.add(sparklesWidget);
//    }
//
//    var widget = new Positioned(
//        child: new Stack(
//          alignment: FractionalOffset.center,
//          overflow: Overflow.visible,
//          children: stackChildren,
//        )
//        ,
//        bottom: 5
//    );
//    return widget;
//  }

  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    _animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  //-----------------------------------------------
  //Animation



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
  int totalSteps = 0;
  int goal = 3000;
  List<Widget> _screens = new List(3);
  List<Widget> leaderboard =  new List(7);


  @override
  Widget build(BuildContext context) {
    leaderboard = [const ListTile(
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
      )
    ];
    setUpPedometer();
    Widget home = homePage(steps, goal);
    Widget history = historyPage();
    Widget leagues = leaguesPage(currentLeagueName, steps, goal, leaderboard, totalSteps);
    _screens[1] = home;
    _screens[0] = history;
    _screens[2] = leagues;
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: new AppBar(
        title: new Text("Trinity Active"),
        actions: <Widget>[
          new SizedBox(
            child:
            RaisedButton(
              color: Colors.blue,
              onPressed: newDay,
              child:
              Text("RESET STEPS"),
            ),
          ),
        ],
      ),
      body:  _screens[_currentIndex],


      bottomNavigationBar:
      BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
            //increment(null);
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

  void setStep() {
    setState(() {
      steps++;
    });
  }

  void newDay() {
    setState(() {
      totalSteps = totalSteps + steps;
      //totalSteps = 0;
    });
  }


  void setUpPedometer() {
    Pedometer pedometer = new Pedometer();
    _subscription = pedometer.stepCountStream.listen(_onData,
        onError: _onError, onDone: _onDone, cancelOnError: true);
  }

  void _onData(int stepCountValue) async {
    setState(() {
      steps = stepCountValue - totalSteps;
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

CircularPercentIndicator homeIndicator(int steps, int goal) {
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
            "STEPS",
            style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.5), fontWeight: FontWeight.bold,),
          ),
          new Text(
            steps.toString(),
            style: TextStyle(fontSize: 50, color: isCompleted ? Colors.lightGreenAccent[700] : Colors.blue, fontWeight: FontWeight.bold,),
          ),
          Image.asset(
            "images/steps_image.png",
            height: 60,
            width: 50,
            color: isCompleted ? Colors.lightGreenAccent[700] : Colors.blue,
          ),
        ],
      ),
      footer: Column(
        children: <Widget>[
          new Padding(
              padding: EdgeInsets.symmetric(vertical: 7)
          ),
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
      backgroundColor: Colors.grey.withOpacity(0.2),);

}


//Made this it's own entire widget so we can control what widgets are displayed(for changing screens)
Widget leaguesFocus(String currentLeagueName, int steps, int goal, List<Widget> leaderboard, int totalSteps) {
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
                leaderboard[0],
                leaderboard[1],
                leaderboard[2],
                leaderboard[3],
                leaderboard[4],
                leaderboard[5],
                leaderboard[6],
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

Widget homePage(int steps, int goal) {
  return Center(
    child: ListView(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.withOpacity(0.8),),
                  new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                  ),
                  new Text(
                    "Today",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.grey.withOpacity(1)),
                  ),
                ]
            ),
            homeIndicator(steps, goal),
          ],
        )
      ],
    ),
  );
}


Widget leaguesPage(String currentLeagueName, int steps, int goal, List<Widget> leaderboard, int totalSteps) {
  return leaguesFocus(currentLeagueName, steps, goal, leaderboard, totalSteps);
  
}



