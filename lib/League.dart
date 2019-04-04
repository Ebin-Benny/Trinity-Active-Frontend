
import 'package:flutter/material.dart';

import 'LeagueMember.dart';
import 'User.dart';

class League {
  String leagueID;
  String name;
  int goal;
  List<LeagueMember> members = new List();
  Widget leaderboard;


  League(int goal, String name) {
    this.name = name;
    this.goal = goal;

    if(this.members.length >= 0) {
      this.leaderboard = membersToLeaderboard();
    }
  }

  League.withID(int goal, String name, String id) {
    this.name = name;
    this.goal = goal;
    this.leagueID = id;
  }

  //Test contructor TODO: REMOVE
  League.asTestLeague (int goal, String name, String leagueID) {
    this.goal = goal;
    this.name = name;
    this.leagueID = leagueID;
    members.add(new LeagueMember("125", "Ebin Benny", leagueID, 9864));
    members.add(new LeagueMember("125", "Caolan Wall", leagueID, 58056));
    members.add(new LeagueMember("123", "John Zhang", leagueID, 1345));
    members.add(new LeagueMember("124", "David Scollard", leagueID, 16210));
    members.add(new LeagueMember("125", "Baptiste Frere", leagueID, 21690));
    this.leaderboard = membersToLeaderboard();
  }

  LeagueMember getMember(String userID) {
    for(int i = 0; i < this.members.length; i++) {
      if(this.members[i].userId == userID) {
        return this.members[i];
      }
    }
    return null;
  }


  void addMember(LeagueMember newMember) {
    this.members.add(newMember);
    updateLeaderboard();
  }

  void updateLeaderboard() {
    this.leaderboard = membersToLeaderboard();
  }

  Widget membersToLeaderboard() {
    print(this.name);
    List<LeagueMember> sortedMembers = this.members;
    if(this.members.length == 0) {
      print("no members");
      return null;
    }
    else {
      print(this.members[0].score);
      int currentHighestScore = 0;
      LeagueMember member = null;
      int highestScoreIndex = 0;
      for(int i = 0; i < sortedMembers.length; i++) {
        currentHighestScore = sortedMembers[i].score;
        highestScoreIndex = i;
        print("i : " + i.toString());
        print("current highest score: " + currentHighestScore.toString());
        for(int j = i; j < sortedMembers.length; j++) {
          print("j : " + j.toString());
          if(sortedMembers[j].score > currentHighestScore) {
            print("currentMembers score : " + sortedMembers[j].score.toString());
            currentHighestScore = sortedMembers[j].score;
            highestScoreIndex = j;
            print("highest score index: " + highestScoreIndex.toString());
          }

        }
        LeagueMember temp = sortedMembers[i];
        sortedMembers[i] = sortedMembers[highestScoreIndex];
        sortedMembers[highestScoreIndex] = temp;
      }
      for(int i = 0; i < sortedMembers.length; i++) {
        print(sortedMembers[i].score);
      }
      return Column(
        children: memberToListTile(sortedMembers),
      );
    }
  }

  List<ListTile> memberToListTile(List<LeagueMember> sortedMembers) {
    List<ListTile> leaderboard = new List();
    for(int i = 0; i < sortedMembers.length; i++) {
      ListTile listTile = new ListTile(
        leading: new Text(
          (i+1).toString(),
        ),
        title: new Text(
          sortedMembers[i].name,
        ),
        trailing: new Text(
          sortedMembers[i].score.toString(),
        ),
      );
      leaderboard.add(listTile);
    }
    return leaderboard;
  }
}