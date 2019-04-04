import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'Request.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'LeagueMember.dart';
import 'package:random_string/random_string.dart';
import 'StepBucket.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';



const double RADIUS = 250;
bool isCompleted = false;
Color blue = Colors.blue;
Color blueDark = Colors.blue[700];
int _score = 0;
int _steps = 0;
int _multiplier = 1;
bool showGoalOptions = false;
bool showLeagueOptions = false;
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

  File jsonFile;
  Directory dir;
  String filename = "stepBucketsTest3.json";
  bool fileExists = false;
  Map<String, dynamic> fileContent;
  Map<String, dynamic> fileContentSaved;

  List<StepBucket> stepBuckets = new List();
  StepBucket currentBucket = new StepBucket(steps, today.day);
  bool bucketUpdatedFromFile = true;

  bool updatedStep = false;



  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      print("here");
      jsonFile = new File(directory.path + "/" + filename);
      fileExists = jsonFile.existsSync();
      if(fileExists) {
        this.setState(
            () => fileContent = json.decode(jsonFile.readAsStringSync())
        );
        this.setState(
                () => fileContentSaved = fileContent
        );
        if(/*currentBucket.getSteps() < num.parse(fileContent["value"])*/currentBucket.day == num.parse(fileContent["key"])) {
          currentBucket.updateSteps(num.parse(fileContent["value"]));
          print(fileContent["value"] + "----------------------------------------------------------");
          bucketUpdatedFromFile = true;
        }
        else {
          bucketUpdatedFromFile = false;
        }
      }
    });
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    _animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  void createFile(Map<String, dynamic> content, Directory dir, String filename) {
    print("Creating file");
    File file = new File(dir.path + "/" + filename);
    file.createSync();
    fileExists = true;
    file.writeAsStringSync(json.encode(content));
  }

  void readJson(File jsonFile) {
    Map<String, dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
    print(jsonFileContent.toString());

  }

  void writeToFile(String key, String value) {
    //print("Writing to file.." );
    Map<String, dynamic> content = {"key": key, "value":value};
    if(fileExists) {
      //print("File exists");
      Map<String, dynamic> jsonFileContent = json.decode(jsonFile.readAsStringSync());
      jsonFileContent.addAll(content);
      jsonFile.writeAsStringSync(json.encode(jsonFileContent));
    }
    else {
      print("No file exists...");
      createFile(content, dir, filename);
    }
    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
  }

  int _currentIndex = 1;

  AnimationController _controller;
  Animation _animation;

  final textController = TextEditingController();
  final setLeagueNameController = TextEditingController();
  final setLeagueGoalController = TextEditingController();
  final setLeagueDurationController = TextEditingController();
  final addLeagueController = TextEditingController();
  bool showErrorMessage = false;



  @override
  void dispose() {
    _controller.dispose();
    textController.dispose();
    setLeagueDurationController.dispose();
    setLeagueGoalController.dispose();
    setLeagueNameController.dispose();
    super.dispose();
  }

  StreamSubscription<int> _subscription;


  String currentLeagueName = "SWENG 37";
  static int steps = 0;
  int totalSteps = 0;
  int goal = 10000;
  int level = 1;
  List<Widget> _screens = new List(5);
  List<Widget> leaderboard =  new List(7);
  static DateTime today = new DateTime.now();
  List<History> history = new List();
  List<League> leaguesList = new List();
  static User testUser = new User("0", "not logged in", 0, 0, 0, 1234, 0);
  List<InkWell> leaguesAsWidgets = new List(testUser.leagues.length);




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
    if(testUser.getStepHistory().isEmpty) {
      testUser.setStepHistory(history);
    }
    //If the buckets steps are less than the one saved
//    if(currentBucket.getSteps() < num.parse(fileContent["value"]) && currentBucket.day == num.parse(fileContent["key"])) {
//      currentBucket.updateSteps(num.parse(fileContent["value"]));
//      print("ahhh------------------1");
//    }
    Widget home = homePage(testUser, today, currentBucket, fileContent, fileContentSaved);
    Widget historyScreen = historyPage(testUser);
    Widget leagues = leaguesPage(testUser.leagues);
    _screens[1] = home;
    _screens[0] = historyScreen;
    _screens[2] = leagues;
    _screens[4] = addLeaguePage(context, setLeagueNameController, setLeagueGoalController, setLeagueDurationController, testUser);
    DrawerCreator drawerCreator = new DrawerCreator(testUser, context);
    return Scaffold(
      drawer: drawerCreator.drawer,
      appBar: new AppBar(
        title:
        Row(
          children: <Widget>[
//            Image.asset(
//              "images/trinity-logo.png",
//              scale: 10,
//            ),
            new Text("Trinity Active"),
            new Text(testUser.leagues.length.toString()),
          ],
        ),
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
        currentIndex: _currentIndex == 3 || _currentIndex == 4 ? 2 : _currentIndex,
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

  Widget leagueOptions() {
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
                        onPressed: toggleLeagueOptions,
                      )
                    ],
                  ),
                  Icon(
                    Icons.group_add,
                    size: 80,
                    color: Colors.blue,
                  ),
                  new Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                  new Text(
                    "ENTER LEAGUE ID",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.grey.withOpacity(1)),

                  ),
                  new Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  Container(
                    width: 200,
                    child: new TextField(
                      controller: addLeagueController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.1),
                        //hintText: "league id",
                      ),
                    ),
                  ),
                  new Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  new Text(
                    "OR",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.withOpacity(1)),
                  ),
                  RaisedButton(
                    onPressed: () {
                      toggleLeagueOptions();
                      _currentIndex = 4;
                    },
                    child: Text(
                      "CREATE NEW LEAGUE",
                      style: TextStyle(color: Colors.white),

                    ),
                    color: Colors.blue,
                  ),
                  new Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FloatingActionButton(
                        child: Icon(Icons.check),
                        onPressed: () {
//                          League hardcodedLeague = new League.asTestLeague(15000, "Trinity", "dEOwJO");
//                          hardcodedLeague.addMember(new LeagueMember(testUser.userID, testUser.name, "dEOwJo", 368));
//                          testUser.addLeague(hardcodedLeague);
//                          hardcodedLeague.updateLeaderboard();
                          if(addLeagueController.text.isNotEmpty) {
                            League league;
                            Request.getLeague(addLeagueController.text).then((League returned) {
                              league = returned;
                              if(league != null) {
                                setState(() {
                                  Request.addUserToLeague(league.leagueID, testUser);
                                  testUser.addLeague(league);
                                });
                              }
                            });
                            toggleLeagueOptions();
                          }

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

  void setUser(User user) {
    testUser = user;
    print(testUser.name);
    print("^^name^^");
  }

  void setGoal(int newGoal) {
    setState(() {
      testUser.setPersonalGoal(newGoal);
      checkCompletion(currentBucket.getSteps(), testUser.getPersonalGoal());
    });
  }

  void newDay() async {
    setState(() {

      testUser.setLifetimeSteps(testUser.getLifetimeSteps() + currentBucket.getSteps());
      testUser.updateLevel();
      testUser.addHistoryEntry(new History(today, currentBucket.getSteps(), testUser.getPersonalGoal()));
      testUser.addHistoryAsCardWidget(new History(today, currentBucket.getSteps(), testUser.getPersonalGoal()));


      StepBucket newBucket = new StepBucket(0, currentBucket.day+1);
      bucketUpdatedFromFile = false;
      newBucket.stepOffset = testUser.getSteps();
      stepBuckets.add(currentBucket);
      currentBucket = newBucket;
      checkCompletion(currentBucket.getSteps(), testUser.getPersonalGoal());
      for(int i = 0; i < history.length; i++) {
        print(testUser.getStepHistory()[i].steps.toString() + "  index:" + i.toString());
      }

      testUser.updateCardHistory();

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
      int stepOffset;
      int previousStepCountValue;
      bool stepChanged = false;
      if(current.day != today.day) {
        today = current;
        newDay();
      }
      if(testUser.getSteps() != stepCountValue) {
        stepChanged = true;
      }
      else {
        stepChanged = false;
      }
      previousStepCountValue = testUser.getSteps();
      testUser.setSteps(stepCountValue /*- testUser.getLifetimeSteps()*/);

      steps = stepCountValue;
      //checks if the
      writeToFile(currentBucket.day.toString(),currentBucket.getSteps().toString());
      //print(fileContent.toString());
      if(!bucketUpdatedFromFile) {
        if(testUser.getSteps() < currentBucket.getSteps()) {
          currentBucket.updateSteps(currentBucket.getSteps() + testUser.getSteps());
          print("ahhh------------------2----------------------------------------------------------------------------------------------------");
        }
        else {
          currentBucket.updateSteps(testUser.getSteps());
          print("ahhh------------------5");
        }
      }
      else if(stepChanged){
        currentBucket.updateSteps(currentBucket.getSteps() + (testUser.getSteps() - previousStepCountValue));
        if(stepCountValue != 0 && !updatedStep) {
          currentBucket.updateSteps(currentBucket.getSteps()-stepCountValue);
          updatedStep = true;
        }
        print("ahhh------------------6" + bucketUpdatedFromFile.toString());
      }
      //print(currentBucket.toString());
      checkCompletion(currentBucket.getSteps(), testUser.getPersonalGoal());
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
    LeagueMember currentLeagueMember = league.getMember(testUser.getUserID());
    return new InkWell(
      splashColor: Colors.blue.withOpacity(0.2),
      onTap: () {
        _screens[3] = leaguesFocus(league, leaderboard, testUser);
        _currentIndex = 3;
      },
      child: Column(
        children: <Widget>[
          new Padding(padding: EdgeInsets.symmetric(vertical: 5)),
          Stack(
            children: <Widget>[
              CircularPercentIndicator(
                animation: true,
                radius: 170,
                startAngle: 180,
                lineWidth: 12,
                progressColor: (currentBucket.getSteps() >= league.goal) ? Colors.lightGreenAccent[400] : Colors.blue,
                backgroundColor: Colors.grey.withOpacity(0.2),
                percent: currentBucket.getSteps() >= league.goal ? 1 : currentBucket.getSteps()/league.goal,
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
                      currentBucket.getSteps().toString(),
                      style: TextStyle(fontSize: 30, color:(currentBucket.getSteps() >= league.goal) ? Colors.lightGreenAccent[700] : Colors.blue, fontWeight: FontWeight.bold,),
                    ),
                  ],
                ),
              ),
              Align(
                child: Column(
                  children: <Widget>[
                    new Padding(padding: EdgeInsets.symmetric(vertical: 90)),
                    Container(
                      color: (currentBucket.getSteps() >= league.goal) ? Colors.lightGreenAccent[700] : Colors.blue[700],
                      width: 40,
                      height: 27,
                      child: Center(
                        child: Text(
                          ("x2"),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold,),
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget leaguesPage(List<League> leagues) {
    this.leaguesAsWidgets = new List(leagues.length);
    for(int i = 0; i < leagues.length; i++) {
      this.leaguesAsWidgets[i] = leagueSummary(leagues[i]);
    }
    return Scaffold(
      body:
      GridView.count(
        crossAxisCount: 2,
        childAspectRatio: .8,
        children: this.leaguesAsWidgets,
      ),
      floatingActionButton: showLeagueOptions ? leagueOptions() : FloatingActionButton(
        onPressed: () {
          toggleLeagueOptions();
        },
        child: Icon(
          Icons.add,
        ),
      ),
      floatingActionButtonLocation: showLeagueOptions ? FloatingActionButtonLocation.centerDocked : null,
    );
  }

  Widget addLeaguePage(BuildContext context,TextEditingController nameController, TextEditingController stepController, TextEditingController durationController, User currentUser) {
    League newLeague;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    height: 160,
                    decoration: new BoxDecoration(
                      gradient: new LinearGradient(
                          begin: FractionalOffset.bottomCenter,
                          end: FractionalOffset.topCenter,
                          colors: [
                            Colors.lightBlueAccent,
                            Colors.blueAccent,
                          ]
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          "NEW LEAGUE",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
                        ),
                        new Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.group,
                              color: Colors.white,
                              size: 40,
                            ),
                            Container(
                              width: 200,
                              child: new TextField(
                                controller: nameController,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.05),
                                  hintText: "League Name",
                                ),
                              ),
                            ),
                            new Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  new Padding(padding: EdgeInsets.symmetric(vertical: 15)),
                  new Text(
                    "SET DAILY STEP GOAL",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey),
                  ),
                  new Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        "images/steps_image.png",
                        height: 35,
                        width: 30,
                        color: Colors.blue,
                      ),
                      Container(
                        width: 200,
                        child: new TextField(
                          controller: stepController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.05),
                          ),
                        ),
                      ),
                      new Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                    ],
                  ),
                  new Padding(padding: EdgeInsets.symmetric(vertical: 20)),
//                  new Text(
//                    "SET DURATION OF LEAGUE",
//                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey),
//                  ),
//                  new Padding(padding: EdgeInsets.symmetric(vertical: 5)),
//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: <Widget>[
//                      Icon(
//                        Icons.timer,
//                        size: 35,
//                        color: Colors.blue,
//                      ),
//                      Container(
//                        width: 200,
//                        child: new TextField(
//                          controller: durationController,
//                          keyboardType: TextInputType.number,
//                          textAlign: TextAlign.center,
//                          decoration: InputDecoration(
//                            filled: true,
//                            fillColor: Colors.black.withOpacity(0.05),
//                          ),
//                        ),
//                      ),
//                      new Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
//                    ],
//                  ),
//                  new Padding(padding: EdgeInsets.symmetric(vertical: 15)),
//              Container(
//                height: 70,
//                width: 260,
//                decoration: new BoxDecoration(
//                    gradient: new LinearGradient(
//                        begin: FractionalOffset.bottomCenter,
//                        end: FractionalOffset.topCenter,
//                        colors: [
//                          Colors.lightBlueAccent,
//                          Colors.blueAccent,
//                        ]
//                    ),
//                    border: new Border.all(
//                      color: Colors.blue,
//                      width: 0,
//                      style: BorderStyle.solid,
//                    ),
//                    borderRadius: new BorderRadius.all(
//                      new Radius.circular(15),
//                    ),
//                    boxShadow: [
//                      new BoxShadow(
//                          color: Colors.grey.withOpacity(0.5),
//                          blurRadius: 5,
//                          offset: new Offset(3,3)
//                      ),
//                    ]
//                ),
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    Row(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                      children: <Widget>[
//                        Container(
//                          width: 180,
//                          height: 50,
//                          decoration: new BoxDecoration(
//                            color: Colors.white,
//                            border: new Border.all(
//                              color: Colors.white,
//                              width: 5,
//                              style: BorderStyle.solid,
//                            ),
//                            borderRadius: new BorderRadius.all(
//                              new Radius.circular(5),
//                            ),
//                          ),
//                          child: Column(
//                            mainAxisAlignment: MainAxisAlignment.center,
//                            children: <Widget>[
//                              new Text(
//                                newLeague != null ? newLeague.leagueID : "",
//                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.black.withOpacity(0.6)),
//                                textAlign: TextAlign.center,
//                              ),
//                            ],
//                          ),
//                        ),
//                        new Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
//                        IconButton(
//                          icon: Icon(
//                            Icons.content_copy,
//                            color: Colors.white.withOpacity(0.8),
//                            size: 40,
//                          ),
//                          onPressed: () {
//                            ClipboardData data = new ClipboardData(text: "aJk4Tz");
//                            Clipboard.setData(data);
//                          },
//                        )
//                      ],
//                    ),
//
//                  ],
//                ),
//              ),
                  new Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                  ),
                  new Text(
                    showErrorMessage ? "Please complete all fields." : "",
                    style: TextStyle(color: Colors.red),
                  ),
                  new RaisedButton(
                    onPressed: () {
                      if(stepController.text.isNotEmpty && nameController.text.isNotEmpty) {
                        newLeague = new League(num.parse(stepController.text), nameController.text);
//                        newLeague.leagueID = randomAlpha(6);
//                        newLeague.addMember(new LeagueMember(currentUser.userID, currentUser.name, newLeague.leagueID, 0));
//                        print(newLeague.leagueID);
//                        currentUser.addLeague(newLeague);
                        LeagueMember thisMember = new LeagueMember.leagueless(currentUser.userID, currentUser.name, 0);
                        String leagueId;
                        Request.postNewLeague(newLeague, thisMember).then((String id) {
                          leagueId = id;
                          thisMember.setLeagueId(leagueId);
                          Request.getLeague(leagueId).then((League returned){
                            newLeague = returned;
                            print("--------------");
                            print(newLeague.leagueID);
                            print(newLeague.members[0].name);
                            print("--------------");
                            if(newLeague != null) {
                              setState(() {
                                currentUser.addLeague(newLeague);
                                print("ADDED!");
                              });
                            }
                          });
                        });
                        print(currentUser.leagues.length);




                        _currentIndex = 2;
                        stepController.clear();
                        durationController.clear();
                        nameController.clear();
                        showErrorMessage = false;
                      }
                      else {
                        setState(() {
                          showErrorMessage = true;
                          print("empty form");
                          print(showErrorMessage);
                        });
                      }
                    },
                    child: new Text(
                      "CREATE LEAGUE",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue,
                  ),

                ],
              )
            ],
          ),
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                _currentIndex = 2;
                showErrorMessage = false;
              },
            ),
          )
        ],
      )
    );
  }

  Widget leaguesFocus(League league, List<Widget> leaderboard, User user) {
    return (Stack(
      children: <Widget>[
        Center(
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
                        league.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.grey.withOpacity(1)),
                      ),
                    ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      leagueIndicator(user, league, currentBucket),
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
                      league.leaderboard != null ? league.leaderboard : new Text(""
                        "No members to show.",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey.withOpacity(0.6)),
                      )
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    new Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                    new Text(
                      "League ID",
                      style: TextStyle(color: Colors.grey.withOpacity(0.7), fontWeight: FontWeight.bold),
                    ),
                    Container(
                      height: 70,
                      width: 260,
                      decoration: new BoxDecoration(
                          gradient: new LinearGradient(
                              begin: FractionalOffset.bottomCenter,
                              end: FractionalOffset.topCenter,
                              colors: [
                                Colors.lightBlueAccent,
                                Colors.lightBlue,
                              ]
                          ),
                          border: new Border.all(
                            color: Colors.blue,
                            width: 0,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: new BorderRadius.all(
                            new Radius.circular(15),
                          ),
                          boxShadow: [
                            new BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 5,
                                offset: new Offset(3,3)
                            ),
                          ]
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 180,
                                height: 50,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Text(
                                      league.leagueID,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.black.withOpacity(0.6)),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              new Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                              IconButton(
                                icon: Icon(
                                  Icons.content_copy,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 40,
                                ),
                                onPressed: () {
                                  ClipboardData data = new ClipboardData(text: league.leagueID);
                                  Clipboard.setData(data);
                                },
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    new Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                  ],
                )
              ]),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.grey,
              size: 40,
            ),
            onPressed: () {
              _currentIndex = 2;
              showErrorMessage = false;
            },
          ),
        )
      ],
    ));
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
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
Widget leagueIndicator(User user, League league, StepBucket currentBucket) {
  int score = user.getSteps() * 2;

  return new Stack(
    children: <Widget>[
      CircularPercentIndicator(
        startAngle: 180,
        radius: RADIUS,
        lineWidth: 15,
        animation: true,
        percent: currentBucket.getSteps() < league.goal ? currentBucket.getSteps() / league.goal : 1,
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
              style: TextStyle(fontSize: 50, color: (currentBucket.getSteps() >= league.goal) ? Colors.lightGreenAccent[700] : Colors.blue, fontWeight: FontWeight.bold,),
            ),
            new Text(
              "STEPS",
              style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.5), fontWeight: FontWeight.bold,),
            ),
            new Text(
              currentBucket.getSteps().toString(),
              style: TextStyle(fontSize: 24, color: (currentBucket.getSteps() >= league.goal) ? Colors.lightGreenAccent[700] : Colors.blue, fontWeight: FontWeight.bold,),
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
                    league.goal.toString(),
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
        progressColor: (currentBucket.getSteps() >= league.goal) ? Colors.lightGreenAccent[400] : Colors.blue,
        backgroundColor: Colors.grey.withOpacity(0.2),
      ),
      Positioned(
        top: RADIUS-22,
        left: RADIUS/2 - 30,
        child: Container(
          color: (currentBucket.getSteps() >= league.goal) ? Colors.lightGreenAccent[700] : Colors.blue[700],
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
  );



}


CircularPercentIndicator homeIndicator(User user, StepBucket currentBucket) {
  return new CircularPercentIndicator(
      startAngle: 180,
      radius: RADIUS,
      lineWidth: 15,
      animation: true,
      percent: currentBucket.getSteps() < user.getPersonalGoal() ? currentBucket.getSteps() / user.getPersonalGoal() : 1,
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
            currentBucket.getSteps().toString(),
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


Widget historyGraph(User user) {
  List<LinearPercentIndicator> lines = new List(30);
  List<History> last30Days = user.historyLast30Days();
  int highestStepCount = user.highestStepCountFromList(last30Days);
  double pixelToStepsRatio = 260 / highestStepCount;
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
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                new Padding(padding: EdgeInsets.symmetric(vertical: 10)),
                new Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: new Text(
                          highestStepCount.toString(),
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                        decoration: new BoxDecoration(
                          color: Colors.white,
                          border: new Border.all(
                            color: Colors.white,
                            width: 5,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: new BorderRadius.vertical(
                            top: new Radius.circular(5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 2,
                  color: Colors.white.withOpacity(0.5)
                ),

              ],
            ),
            new RotatedBox(
              quarterTurns: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: lines,
              ),
            ),
          ],
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

Widget homePage(User user, DateTime today, StepBucket currentBucket, Map<String, dynamic> fileContent, Map<String, dynamic> fileContentSaved) {
  return Center(
    child: ListView(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
            ),
            new Text(fileContentSaved.toString()),
            new Text(fileContent.toString()),
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
            homeIndicator(user, currentBucket),
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
                  new Padding(padding: EdgeInsets.symmetric(vertical: 2)),
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
                        header: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey.withOpacity(0.8), size: 12,),
                              new Text(
                                user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 1 ? user.getStepHistory()[user.getStepHistory().length-1].day.day.toString() +"-"+ user.getStepHistory()[user.getStepHistory().length-1].day.month.toString():"",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.8), fontSize: 12),
                              ),
                            ]
                        ),
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
                        header: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey.withOpacity(0.8), size: 12,),
                              new Text(
                                user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 2 ? user.getStepHistory()[user.getStepHistory().length-2].day.day.toString() +"-"+ user.getStepHistory()[user.getStepHistory().length-2].day.month.toString():"",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.8), fontSize: 12),
                              ),
                            ]
                        ),
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
                        header: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey.withOpacity(0.8), size: 12,),
                              new Text(
                                user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 3 ? user.getStepHistory()[user.getStepHistory().length-3].day.day.toString() +"-"+ user.getStepHistory()[user.getStepHistory().length-3].day.month.toString():"",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.8), fontSize: 12),
                              ),
                            ]
                        ),
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
                        header: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey.withOpacity(0.8), size: 12,),
                              new Text(
                                user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 4 ? user.getStepHistory()[user.getStepHistory().length-4].day.day.toString() +"-"+ user.getStepHistory()[user.getStepHistory().length-4].day.month.toString():"",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.8), fontSize: 12),
                              ),
                            ]
                        ),
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
                        header: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey.withOpacity(0.8), size: 12,),
                              new Text(
                                user.getStepHistory().isNotEmpty && user.getStepHistory().length >= 5 ? user.getStepHistory()[user.getStepHistory().length-5].day.day.toString() +"-"+ user.getStepHistory()[user.getStepHistory().length-5].day.month.toString():"",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.8), fontSize: 12),
                              ),
                            ]
                        ),
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
    print("dont show");
  }
  else {
    showGoalOptions = true;
    print("show");
  }

}

void toggleLeagueOptions() {
  if(showLeagueOptions) {
    showLeagueOptions = false;
    print("dont show");
  }
  else {
    showLeagueOptions = true;
    print("show");
  }

}

void setLogInState(bool state) {
  _isLoggedIn = state;
}

