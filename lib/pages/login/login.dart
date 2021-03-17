import 'package:flutter/material.dart';
import 'package:flutter_pusher/pages/chat/chat.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _textEditingController =
      TextEditingController(text: '');
  LoginPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _textEditingController,
                decoration: InputDecoration(
                    labelText: 'User Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18))),
              ),
              SizedBox(
                height: 10.0,
              ),
              TextButton.icon(
                  // style: ButtonStyle(),
                  onPressed: () async {
                    final userName = _textEditingController.text.trim();
                    if (userName.isNotEmpty)
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ChatPage(
                                userName: userName,
                              )));
                    else
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('Enter user name!')));
                  },
                  icon: Icon(Icons.login),
                  label: Text("Login")),
            ],
          ),
        ),
      ),
    );
  }
}
