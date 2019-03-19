import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}



class LoginPageState extends State<LoginPage> {
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
                Buttons.GoogleDark,
                onPressed: () {
                  setLogInState(true);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SamplePage()));
//                  Navigator.pop(context);
                }
            ),

          ],
        ),
      ),
    );
  }

}
