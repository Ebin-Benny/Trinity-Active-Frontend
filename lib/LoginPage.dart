import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'main.dart';
import 'User.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'Request.dart' as request;
import 'dart:async';


class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}



class LoginPageState extends State<LoginPage> {

  SamplePageState samplePageState = new SamplePageState();
  bool isLoggedIn = false;
  var profileData;
  User loggedInUser;

  void initiateFacebookLogin() async {
    var facebookLogin = FacebookLogin();
    var facebookLoginResult =
    await facebookLogin.logInWithReadPermissions(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${facebookLoginResult
                .accessToken.token}');

        var profile = json.decode(graphResponse.body);

        onLoginStatusChanged(true, profileData: profile);
        //TODO: Add request call here
        bool userExists = await request.Request.userLookup(profileData['id'].toString());
       // bool userExists = false;
        if(userExists) {
          print("Exists!");
          this.loggedInUser = new User.newUser(profileData['id'].toString(), profileData['name'].toString());
          print(this.loggedInUser.userID);
          this.loggedInUser = await request.Request.getUserHomepage(this.loggedInUser);
          print(this.loggedInUser.getStepHistory()[0].getSteps());
          this.loggedInUser.updateCardHistory();
        }
        else {
          print("No User Exists!");
          this.loggedInUser = new User.newUser(profileData['id'].toString(), profileData['name'].toString());
          request.Request.postNewUser(this.loggedInUser);
          print(this.loggedInUser.userID);
        }
        samplePageState.setUser(loggedInUser);
        print(loggedInUser.name);
        Navigator.push(context, MaterialPageRoute(builder: (context) => SamplePage()));
        break;
    }
  }

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: new BoxDecoration(
            gradient: new LinearGradient(
                begin: FractionalOffset.topLeft,
                end: FractionalOffset.bottomRight,
                colors: [
                  Colors.blue[700],
                  Colors.lightBlueAccent,
                  Colors.lightGreenAccent,
                ]
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "images/TrinityActive-logo.png",
              width: 200,
              height: 200,
            ),
            new Padding(padding: EdgeInsets.symmetric(vertical: 20)),
            new SignInButton(
                Buttons.Facebook,
                onPressed: () {
                  initiateFacebookLogin();
//                  Navigator.pop(context);
                }
            ),

          ],
        ),
      ),
    );
  }


}
