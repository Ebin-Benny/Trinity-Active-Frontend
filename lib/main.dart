import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';
import 'dart:math';
import 'League.dart';
import 'User.dart';
import 'History.dart';
import 'DrawerCreator.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'LoginPage.dart';


const double RADIUS = 250;
bool isCompleted = false;
Color blue = Colors.blue;
Color blueDark = Colors.blue[700];
int _score = 0;
int _steps = 0;
int _multiplier = 1;
bool showGoalOptions = false;
int numberOfLevels = 50;
bool _isLoggedIn = false;

void main() {
  runApp(new MaterialApp(home: new Scaffold(body: new LoginPage())));
}

class SamplePage extends StatefulWidget {
  @override
  SamplePageState createState() => SamplePageState();
}



class SamplePageState extends State<SamplePage> with TickerProviderStateMixin{

  int _currentIndex = 1;

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

//  _openPage(Widget page) {
//    Navigator.push(
//      context,
//      new MaterialPageRoute(
//        builder: (BuildContext context) => page,
//      ),
//    );
//  }


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
  User testUser = new User("17330000", "Owen Johnston", 0, 10000, 1, 0, 1);


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
    League testLeague = new League(new List<User>(), 5000, "testLeague");
    leaguesList.add(testLeague);
    testUser.setStepHistory(history);
    Widget home = homePage(testUser, today);
    Widget historyScreen = historyPage(testUser);
    Widget leagues = leaguesPage(leaguesList);
    Widget specificLeague = leaguesFocus(currentLeagueName, steps, goal, leaderboard, totalSteps, testUser);
    _screens[1] = home;
    _screens[0] = historyScreen;
    _screens[2] = leagues;
    _screens[3] = specificLeague;
    DrawerCreator drawerCreator = new DrawerCreator(testUser, context);
    return Scaffold(
      drawer: drawerCreator.drawer,
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
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(1.0, 6.0),
                    blurRadius: 40.0,
                  ),
                ],
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
      testUser.setSteps(testUser.getSteps() + 1);
    });
  }

  void setGoal(int newGoal) {
    setState(() {
      testUser.setPersonalGoal(newGoal);
      checkCompletion(testUser.getSteps(), testUser.getPersonalGoal());
    });
  }

  void newDay() {
    setState(() {
      testUser.addHistoryEntry(new History(today, testUser.getSteps(), testUser.getPersonalGoal()));
      testUser.addHistoryAsCardWidget(new History(today, testUser.getSteps(), testUser.getPersonalGoal()));
      print(testUser.getStepHistory().length);
      for(int i = 0; i < history.length; i++) {
        print(testUser.getStepHistory()[i].steps.toString() + "  index:" + i.toString());
      }
      testUser.setLifetimeSteps(testUser.getLifetimeSteps() + testUser.getSteps());
      testUser.updateLevel();
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
      testUser.setSteps(stepCountValue - testUser.getLifetimeSteps());
      if(testUser.getSteps() >= testUser.getPersonalGoal()) {
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

  InkWell leagueSummary(League league) {
    return new InkWell(
      splashColor: Colors.blue.withOpacity(0.2),
      onTap: () {
        _currentIndex = 3;
      },
      child: Column(
        children: <Widget>[
          new Padding(padding: EdgeInsets.symmetric(vertical: 5)),
          CircularPercentIndicator(
            animation: true,
            radius: 170,
            startAngle: 180,
            lineWidth: 12,
            progressColor: isCompleted ? Colors.lightGreenAccent[400] : Colors.blue,
            backgroundColor: Colors.grey.withOpacity(0.2),
            percent: testUser.getSteps() >= league.goal ? 1 : testUser.getSteps()/league.goal,
            circularStrokeCap: CircularStrokeCap.round,
            header: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Icon(
                  Icons.group,
                  color: Colors.grey,
                ),
                new Text(
                  league.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey.withOpacity(1)),
                ),
              ],
            ),
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                  testUser.getSteps().toString(),
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
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: .8,
        children: <Widget>[
          leagueSummary(leagues[0]),
          leagueSummary(leagues[0]),
          leagueSummary(leagues[0]),
          leagueSummary(leagues[0]),
          leagueSummary(leagues[0]),
          leagueSummary(leagues[0]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(
          Icons.add,
        ),
      ),
    );

  }



}



//TODO : Implement levels logic
CircularPercentIndicator levelIndicator (User user) {
  return new CircularPercentIndicator(
    radius: 200,
    startAngle: 180,
    percent: user.percentToNextLevel(),
    backgroundColor: Colors.blue[900],
    animation: true,
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
          user.getLevel().toString(),
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
          user.getLifetimeSteps().toString(),
          style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold,),
        ),

      ],
    ),


  );
}

//TODO : Figure out how we are going to store the steps and goal values
CircularPercentIndicator mainIndicator(User user) {
  int score = user.getSteps() * 2;
  return new CircularPercentIndicator(
    startAngle: 180,
    radius: RADIUS,
    lineWidth: 15,
    animation: true,
    percent: user.getSteps() < user.getPersonalGoal() ? user.getSteps() / user.getPersonalGoal() : 1,
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
          user.getSteps().toString(),
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
                user.getPersonalGoal().toString(),
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



CircularPercentIndicator homeIndicator(User user) {
  return new CircularPercentIndicator(
      startAngle: 180,
      radius: RADIUS,
      lineWidth: 15,
      animation: true,
      percent: user.getSteps() < user.getPersonalGoal() ? user.getSteps() / user.getPersonalGoal() : 1,
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
            user.getSteps().toString(),
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
                user.getPersonalGoal().toString(),
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
Widget leaguesFocus(String currentLeagueName, int steps, int goal, List<Widget> leaderboard, int totalSteps, User user) {
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
                    mainIndicator(user),
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
                Column(children: leaderboard,),
              ],
            ),
          ),
        ]),
  ));
}

Widget historyGraph(User user) {
  List<LinearPercentIndicator> lines = new List(30);
  List<History> last30Days = user.historyLast30Days();
  double pixelToStepsRatio = 260 / user.highestStepCountFromList(last30Days);
  for(int i = 0; i < lines.length; i++) {
    lines[i] = lineInGraph(last30Days[i], pixelToStepsRatio);
  }
  return(
      Container(
        height: 300,
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
                begin: FractionalOffset.bottomCenter,
                end: FractionalOffset.topCenter,
                colors: [
                  Colors.lightBlueAccent,
                  Colors.blueAccent,
                ]
            )
        ),
        child: new RotatedBox(
          quarterTurns: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: lines,
          ),
        ),
      )
  );
}

LinearPercentIndicator lineInGraph (History history, double pixelToStepsRatio) {
  int historySteps = 0;
  if(history != null) {
    historySteps = history.getSteps();
  }
  return(
    LinearPercentIndicator(
//      width: 260,
      width: historySteps * pixelToStepsRatio,
      progressColor: Colors.white,
      backgroundColor: Colors.blue.withOpacity(0),
      lineHeight: 4,
      percent: 1.0,
      animation: true,
    )
  );
}

Widget historyPage(User user) {
  return(
    ListView(
      children: <Widget>[
        historyGraph(user),
        Column(
            children: user.getHistoryAsCardWidgets().isNotEmpty ? user.getHistoryAsCardWidgets() : <Widget> [new Padding(padding: EdgeInsets.symmetric(vertical: 10)), new Text("No history to show.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),)]
        ),
      ],
    )
  );
}

Widget homePage(User user, DateTime today) {
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
            homeIndicator(user),
//            new Text(
//              today.day.toString() + "-" + today.month.toString() + "-" + today.year.toString() + "-" + today.minute.toString(),
//              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey.withOpacity(1)),
//            ),
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
                        progressColor: user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 1 ? ( user.getStepHistory()[user.getStepHistory().length-1].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue,
                        percent: user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 1 ? (user.getStepHistory()[user.getStepHistory().length-1].steps < user.getStepHistory()[user.getStepHistory().length-1].goal ? user.getStepHistory()[user.getStepHistory().length-1].steps / user.getStepHistory()[user.getStepHistory().length-1].goal : 1.0) : 0.0,
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
                              user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 1 ? user.getStepHistory()[user.getStepHistory().length-1].steps.toString() : "0",
                              style: TextStyle(fontWeight: FontWeight.bold,color: user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 1 ? ( user.getStepHistory()[user.getStepHistory().length-1].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      new CircularPercentIndicator(
                        startAngle: 180,
                        radius: 100,
                        lineWidth: 10,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        progressColor: user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 2 ? ( user.getStepHistory()[user.getStepHistory().length-2].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue,
                        percent:  user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 2 ? (user.getStepHistory()[user.getStepHistory().length-2].steps < user.getStepHistory()[user.getStepHistory().length-2].goal ? user.getStepHistory()[user.getStepHistory().length-2].steps / user.getStepHistory()[user.getStepHistory().length-2].goal : 1.0) : 0.0,
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
                              user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 2 ? user.getStepHistory()[user.getStepHistory().length-2].steps.toString() : "0",
                              style: TextStyle(fontWeight: FontWeight.bold, color: user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 2 ? ( user.getStepHistory()[user.getStepHistory().length-2].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      new CircularPercentIndicator(
                        startAngle: 180,
                        radius: 100,
                        lineWidth: 10,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        progressColor: user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 3 ? ( user.getStepHistory()[user.getStepHistory().length-3].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue,
                        percent: user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 3 ? (user.getStepHistory()[user.getStepHistory().length-3].steps < user.getStepHistory()[user.getStepHistory().length-3].goal ? user.getStepHistory()[user.getStepHistory().length-3].steps / user.getStepHistory()[user.getStepHistory().length-3].goal : 1.0) : 0.0,
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
                              user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 3 ? user.getStepHistory()[user.getStepHistory().length-3].steps.toString() : "0",
                              style: TextStyle(fontWeight: FontWeight.bold, color: user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 3 ? ( user.getStepHistory()[user.getStepHistory().length-3].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue, fontSize: 18),
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
                        progressColor: user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 4 ? ( user.getStepHistory()[user.getStepHistory().length-4].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue,
                        percent: user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 4 ? (user.getStepHistory()[user.getStepHistory().length-4].steps < user.getStepHistory()[user.getStepHistory().length-4].goal ? user.getStepHistory()[user.getStepHistory().length-4].steps / user.getStepHistory()[user.getStepHistory().length-4].goal : 1.0) : 0.0,
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
                              user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 4 ? user.getStepHistory()[user.getStepHistory().length-4].steps.toString() : "0",
                              style: TextStyle(fontWeight: FontWeight.bold, color: user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 4 ? ( user.getStepHistory()[user.getStepHistory().length-4].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue, fontSize: 18),
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
                        progressColor: user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 5 ? ( user.getStepHistory()[user.getStepHistory().length-5].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue,
                        percent: user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 5 ? (user.getStepHistory()[user.getStepHistory().length-5].steps < user.getStepHistory()[user.getStepHistory().length-5].goal ? user.getStepHistory()[user.getStepHistory().length-5].steps / user.getStepHistory()[user.getStepHistory().length-5].goal : 1.0) : 0.0,
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
                              user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 5 ? user.getStepHistory()[user.getStepHistory().length-5].steps.toString() : "0",
                              style: TextStyle(fontWeight: FontWeight.bold, color: user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 5 ? ( user.getStepHistory()[user.getStepHistory().length-5].isComplete ? Colors.lightGreenAccent[700]  : Colors.blue ) : Colors.blue, fontSize: 18),
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

void toggleGoalOptions() {
  if(showGoalOptions) {
    showGoalOptions = false;
  }
  else {
    showGoalOptions = true;
  }
}

void setLogInState(bool state) {
  _isLoggedIn = state;
}







