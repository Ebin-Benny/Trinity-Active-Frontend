import 'package:flutter/material.dart';
import 'main.dart' as main;
import 'User.dart';
import 'LoginPage.dart';

class DrawerCreator {
  ListView drawerListView;
  Drawer drawer;

  DrawerCreator(User user, BuildContext context) {
    this.drawerListView = new ListView(
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
                        user.getName(),
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold,),
                      ),
                    ],
                  ),
                  main.levelIndicator(user)
                ],
              ),
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
                main.toggleGoalOptions();
              },
            ),

          ],
        ),
      ],
    );


    this.drawer = new Drawer(child: drawerListView,);
  }
}
