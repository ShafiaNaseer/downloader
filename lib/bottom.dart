import 'package:downloader/twitter_down.dart';
import 'package:downloader/video_down.dart';
import 'package:flutter/material.dart';

import 'insta_downloader.dart';

class MyNavigationBar extends StatefulWidget {
  const MyNavigationBar ({Key? key}) : super(key: key);

  @override
  _MyNavigationBarState createState() => _MyNavigationBarState();
}

class _MyNavigationBarState extends State<MyNavigationBar > {
  int _selectedIndex = 0;
    final List<Widget> _widgetOptions = <Widget>[
     HomePage(),
      HomePageInsta(),
      TwitterDown()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'YouTube',
                backgroundColor: Colors.green
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.access_time),
                label: 'Instagram',
                backgroundColor: Colors.yellow
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.download),
                label: 'Twitter',
                backgroundColor: Colors.yellow
            ),

          ],
          type: BottomNavigationBarType.shifting,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          iconSize: 40,
          onTap: _onItemTapped,
          elevation: 5
      ),
    );
  }
}  