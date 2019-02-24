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

  final textController = TextEditingController();

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
    textController.dispose();
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
  int goal = 10000;
  int level = 1;
  List<Widget> _screens = new List(4);
  List<Widget> leaderboard =  new List(7);
  DateTime today = new DateTime.now();
  List<History> history = new List();
  List<League> leaguesList = new List();
  //DateTime today = new DateTime(2019, 2, 21);
  bool showGoalOptions = false;


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
    League testLeague = new League(steps,goal,2,currentLeagueName);
    leaguesList.add(testLeague);
    Widget home = homePage(steps, goal, today, history);
    Widget historyScreen = historyPage();
    Widget leagues = leaguesPage(leaguesList);
    Widget specificLeague = leaguesFocus(currentLeagueName, steps, goal, leaderboard, totalSteps);
    _screens[1] = home;
    _screens[0] = historyScreen;
    _screens[2] = leagues;
    _screens[3] = specificLeague;
    final double width = MediaQuery.of(context).size.width;

    ListView drawerListView = new ListView(
      padding: const EdgeInsets.all(0.0),
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              constraints: BoxConstraints.expand(height: 350),
              color: Colors.blue,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      new Text(
                        "_username",
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      ),
                    ],
                  ),
                  levelIndicator(level, totalSteps)
                ],
              ),
            ),
            new ListTile(
              leading: Image.asset(
                "images/trophy.png",
                color: Colors.grey[600],
              ),
              title: new Text(
                "Trophy Cabinet",
                style: TextStyle(fontSize: 18, color: Colors.grey[600],),
              ),
              onTap: () {
                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new trophyPage())
                );
              },
            ),
            new ListTile(
              leading: Image.asset(
                "images/bullseye-arrow.png",
                color: Colors.grey[600],
                height: 25,
                width: 25,
              ),
              title: new Text(
                "Goals",
                style: TextStyle(fontSize: 18, color: Colors.grey[600],),
              ),
              onTap: () {
                Navigator.pop(context);
                toggleGoalOptions();
              },
            ),

          ],
        ),
      ],
    );


    Drawer drawer = new Drawer(child: drawerListView,);

    return Scaffold(
      drawer: drawer,
      appBar: new AppBar(
        title:
        new Text("Trinity Active"),
        actions: <Widget>[
          new SizedBox(
            child:
            RaisedButton(
              color: Colors.blue,
              onPressed: newDay,
              child:
              Text("NEW DAY"),
            ),
          ),
        ],
      ),

      floatingActionButton: showGoalOptions ? goalOptions() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body:  _screens[_currentIndex],


      bottomNavigationBar:
      BottomNavigationBar(
        currentIndex: _currentIndex == 3 ? 2 : _currentIndex,
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

  Widget goalOptions() {
    return new  Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              constraints: BoxConstraints.expand(),
              color: Colors.black.withOpacity(0.2),
            ),
            Container(
              constraints: BoxConstraints.expand(height: 400, width: 300),
              decoration: new BoxDecoration(
                color: Colors.white,
                border: new Border.all(
                  color: Colors.white,
                  width: 5,
                  style: BorderStyle.solid,
                ),
                borderRadius: new BorderRadius.all(
                  new Radius.circular(5),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: toggleGoalOptions,
                      )
                    ],
                  ),
                  Image.asset(
                    "images/goal_image.png",
                  ),
                  new Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  new Text(
                    "SET GOAL",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.grey.withOpacity(1)),

                  ),
                  new Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  Container(
                    width: 200,
                    child: new TextField(
                      controller: textController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        hintText: goal.toString(),
                      ),
                    ),
                  ),
                  new Padding(padding: EdgeInsets.symmetric(vertical: 35)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FloatingActionButton(
                        child: Icon(Icons.check),
                        onPressed: () {
                          toggleGoalOptions();
                          setGoal(num.parse(textController.text));
                        },
                      ),
                    ],
                  )

                ],
              ),
            ),
          ],
        )
    );
  }

  void setStep() {
    setState(() {
      steps++;
    });
  }

  void setGoal(int newGoal) {
    setState(() {
      goal = newGoal;
      checkCompletion(steps, goal);
    });
  }

  void newDay() {
    setState(() {
      history.add(new History(today, steps, goal));
      print(history.length);
      for(int i = 0; i < history.length; i++) {
        print(history[i].steps.toString() + "  index:" + i.toString());
      }
      totalSteps = totalSteps + steps;
      isCompleted = false;
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
      // TODO: better implementation of the date changing
      DateTime current = new DateTime.now();
      if(current.day != today.day) {
        today = current;
        newDay();
      }
      steps = stepCountValue - totalSteps;
      if(steps >= goal) {
        setCompletion();
      }
    });
  }
  void _onDone() => print("Finished pedometer tracking");

  void _onError(error) => print("Flutter Pedometer Error: $error");

  void _onCancel() => _subscription.cancel();

  //TODO : temp implementation
  void checkCompletion(int steps, int goal) {
    setState(() {
      if(steps < goal) {
        isCompleted = false;
      }
      else if(steps >= goal) {
        isCompleted = true;
      }
    });
  }

  void setCompletion() {
    setState(() {
      isCompleted = true;
    });
  }

  void toggleGoalOptions() {
    setState(() {
      if(showGoalOptions) {
        showGoalOptions = false;
      }
      else {
        showGoalOptions = true;
      }
    });
  }


  InkWell leagueSummary(League league) {
    return new InkWell(
      splashColor: Colors.blue.withOpacity(0.2),
      onTap: () {
        _currentIndex = 3;
      },
      child: Column(
        children: <Widget>[

          CircularPercentIndicator(
            radius: 170,
            startAngle: 180,
            lineWidth: 12,
            progressColor: Colors.blue,
            backgroundColor: Colors.grey.withOpacity(0.2),
            percent: league.steps >= league.goal ? 1 : league.steps/league.goal,
            circularStrokeCap: CircularStrokeCap.round,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  league.steps.toString(),
                  style: TextStyle(fontSize: 30, color: isCompleted ? Colors.lightGreenAccent[700] : Colors.blue, fontWeight: FontWeight.bold,),
                ),
              ],
            ),

          ),
        ],
      ),
    );
  }

  Widget leaguesPage(List<League> leagues) {
    return GridView.count(
      crossAxisCount: 2,
      children: <Widget>[
        leagueSummary(leagues[0]),
      ],
    );

  }



}



//TODO : Implement levels logic
CircularPercentIndicator levelIndicator (int level, int totalSteps) {
  return new CircularPercentIndicator(
    radius: 200,
    startAngle: 180,
    percent: totalSteps/15000,
    backgroundColor: Colors.blue[900],
    progressColor: Colors.lightBlueAccent[100],
    circularStrokeCap: CircularStrokeCap.round,
    lineWidth: 12,
    center: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Text(
          "LEVEL",
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold,),
        ),
        new Text(
          level.toString(),
          style: TextStyle(fontSize: 60, color: Colors.white, fontWeight: FontWeight.bold,),
        ),
      ],
    ),
    footer: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Padding(padding: EdgeInsets.symmetric(vertical: 1)),
        new Text(
          "LIFETIME STEPS",
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.bold,),
        ),
        new Text(
          totalSteps.toString(),
          style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold,),
        ),

      ],
    ),


  );
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
          new Padding(padding: EdgeInsets.symmetric(vertical: 5)),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  constraints: BoxConstraints.expand(height: 40),
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(
                        Icons.stars,
                        color: Colors.white,
                      ),
                      new Padding(padding: EdgeInsets.symmetric(horizontal: 50)),
                      new Text(
                        "Leaderboard",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                      ),
                      new Padding(padding: EdgeInsets.symmetric(horizontal: 50)),
                      Image.asset(
                        "images/steps_image.png",
                        height: 25,
                        width: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),

                ),
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

Widget homePage(int steps, int goal, DateTime today, List<History> history) {
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
                  Icon(Icons.calendar_today, color: Colors.grey.withOpacity(0.8), size: 20,),
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
            new Text(
              today.day.toString() + "-" + today.month.toString() + "-" + today.year.toString() + "-" + today.minute.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey.withOpacity(1)),
            ),
            new Card(
              child: Column(
                children: <Widget>[
                  new Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                  Container(
                    constraints: BoxConstraints.expand(height: 40),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Padding(padding: EdgeInsets.symmetric(horizontal: 50)),
                        new Text(
                          "Last 5 Days",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                        ),
                        new Padding(padding: EdgeInsets.symmetric(horizontal: 50)),
                      ],
                    ),

                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new CircularPercentIndicator(
                        startAngle: 180,
                        radius: 100,
                        lineWidth: 10,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        progressColor: history.isNotEmpty && history.length >= 1 ? ( history[history.length-1].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue,
                        percent: history.isNotEmpty && history.length >= 1 ? (history[history.length-1].steps < history[history.length-1].goal ? history[history.length-1].steps / history[history.length-1].goal : 1.0) : 0.0,
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                              "STEPS",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.5), fontSize: 10),
                            ),
                            new Text(
                              history.isNotEmpty && history.length >= 1 ? history[history.length-1].steps.toString() : "0",
                              style: TextStyle(fontWeight: FontWeight.bold,color: history.isNotEmpty && history.length >= 1 ? ( history[history.length-1].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      new CircularPercentIndicator(
                        startAngle: 180,
                        radius: 100,
                        lineWidth: 10,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        progressColor: history.isNotEmpty && history.length >= 2 ? ( history[history.length-2].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue,
                        percent:  history.isNotEmpty && history.length >= 2 ? (history[history.length-2].steps < history[history.length-2].goal ? history[history.length-2].steps / history[history.length-2].goal : 1.0) : 0.0,
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                              "STEPS",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.5), fontSize: 10),
                            ),
                            new Text(
                              history.isNotEmpty && history.length >= 2 ? history[history.length-2].steps.toString() : "0",
                              style: TextStyle(fontWeight: FontWeight.bold, color: history.isNotEmpty && history.length >= 2 ? ( history[history.length-2].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      new CircularPercentIndicator(
                        startAngle: 180,
                        radius: 100,
                        lineWidth: 10,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        progressColor: history.isNotEmpty && history.length >= 3 ? ( history[history.length-3].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue,
                        percent: history.isNotEmpty && history.length >= 3 ? (history[history.length-3].steps < history[history.length-3].goal ? history[history.length-3].steps / history[history.length-3].goal : 1.0) : 0.0,
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                              "STEPS",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.5), fontSize: 10),
                            ),
                            new Text(
                              history.isNotEmpty && history.length >= 3 ? history[history.length-3].steps.toString() : "0",
                              style: TextStyle(fontWeight: FontWeight.bold, color: history.isNotEmpty && history.length >= 3 ? ( history[history.length-3].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new CircularPercentIndicator(
                        startAngle: 180,
                        radius: 100,
                        lineWidth: 10,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        progressColor: history.isNotEmpty && history.length >= 4 ? ( history[history.length-4].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue,
                        percent: history.isNotEmpty && history.length >= 4 ? (history[history.length-4].steps < history[history.length-4].goal ? history[history.length-4].steps / history[history.length-4].goal : 1.0) : 0.0,
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                              "STEPS",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.5), fontSize: 10),
                            ),
                            new Text(
                              history.isNotEmpty && history.length >= 4 ? history[history.length-4].steps.toString() : "0",
                              style: TextStyle(fontWeight: FontWeight.bold, color: history.isNotEmpty && history.length >= 4 ? ( history[history.length-4].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      new Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                      new CircularPercentIndicator(
                        startAngle: 180,
                        radius: 100,
                        lineWidth: 10,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        progressColor: history.isNotEmpty && history.length >= 5 ? ( history[history.length-5].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue,
                        percent: history.isNotEmpty && history.length >= 5 ? (history[history.length-5].steps < history[history.length-5].goal ? history[history.length-5].steps / history[history.length-5].goal : 1.0) : 0.0,
                        circularStrokeCap: CircularStrokeCap.round,
                        animation: true,
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                              "STEPS",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.5), fontSize: 10),
                            ),
                            new Text(
                              history.isNotEmpty && history.length >= 5 ? history[history.length-5].steps.toString() : "0",
                              style: TextStyle(fontWeight: FontWeight.bold, color: history.isNotEmpty && history.length >= 5 ? ( history[history.length-5].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue, fontSize: 18),
                            ),
                          ],
                        ),
                      ),

                    ],
                  ),
                  new Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                ],
              ),
            ),
          ],
        )
      ],
    ),
  );
}




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

class League {
  int steps;
  int score;
  int goal;
  int multiplier;
  String name;

  League(int steps, int goal, int multiplier, String name) {
    this.steps = steps;
    this.goal = goal;
    this.multiplier = multiplier;
    this.name = name;
  }
}

class LeagueMember {
  String name;
  int steps;
  int score;

}

class trophyPage extends StatefulWidget {
  @override
  _trophyPageState createState() => _trophyPageState();
}

class _trophyPageState extends State<trophyPage> {
  @override
  Widget build(BuildContext context) {
    return null;
  }
}

class tempGoalsPage extends StatefulWidget {
  @override
  _tempGoalsState createState() => _tempGoalsState();
}

class _tempGoalsState extends State<tempGoalsPage> {
  @override
  Widget build(BuildContext context) {
    return null;
  }
}




