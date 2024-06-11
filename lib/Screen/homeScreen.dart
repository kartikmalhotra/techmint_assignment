import 'package:drive_assignment/Screen/googleHttpClient.dart';
import 'package:flutter/material.dart';
import 'package:drive_assignment/Data/Recent.dart';
import 'package:drive_assignment/Widget/recent.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v2.dart';

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return HomeScreenPage();
  }
}

class HomeScreenPage extends StatefulWidget {
  HomeScreenPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _HomeScreenPageState createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: recents.length,
        itemBuilder: (context, index) {
          return Container(
            child: RecentWidget(
              recent: recents[index],
            ),
          );
        },
      ),
    );
  }
}
