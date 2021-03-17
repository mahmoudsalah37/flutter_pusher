import 'package:flutter/material.dart';
import 'package:flutter_pusher/pages/login/login.dart';
import 'package:flutter_pusher/pages/map/map_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MapScreen(),
                ),
              ),
              child: Text('Map'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LoginPage(),
                ),
              ),
              child: Text('Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
