import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pusher/models/chat_model.dart';
import 'package:pusher_websocket_flutter/pusher.dart';
import 'package:pusher_http_dart/pusher_http_dart.dart' as p;

class ChatPage extends StatefulWidget {
  final String userName;
  const ChatPage({this.userName});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Channel _channel;
  final List<ChatModel> messages = [];
  final TextEditingController _textEditingController =
      TextEditingController(text: '');
  @override
  void initState() {
    super.initState();
    initPusher();
  }

  Future<void> initPusher() async {
    try {
      await Pusher.init("2c5ceed64081647c85a0", PusherOptions(cluster: "eu"),
          enableLogging: true);
    } on PlatformException catch (e) {
      print(e.message);
    }
    Pusher.connect(onConnectionStateChange: (val) {
      print(val.currentState);
    }, onError: (e) {
      print(e.message);
    });
    _channel = await Pusher.subscribe('channelName');
    _channel.bind('eventName', (onEvent) {
      final message = ChatModel.fromJson(onEvent.data);
      setState(() {
        messages.add(message);
      });
      // print(onEvent.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final message = messages.elementAt(index);
                    return Directionality(
                      textDirection: widget.userName == message.user
                          ? TextDirection.ltr
                          : TextDirection.rtl,
                      child: ListTile(
                        title: Text("${message.user}"),
                        subtitle: Text("${message.message}"),
                      ),
                    );
                  }),
            ),
            Container(
              color: Colors.grey[200],
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18))),
                    ),
                  )),
                  TextButton.icon(
                      style: ButtonStyle(),
                      onPressed: () async {
                        p.Pusher pusher = p.Pusher(
                            '1171697',
                            '2c5ceed64081647c85a0',
                            '682f5ceca00b684aaf47',
                            p.PusherOptions(cluster: 'eu'));
                        final message = _textEditingController.text.trim();
                        final data = ChatModel(
                                user: '${widget.userName}', message: '$message')
                            .toMap();
                        p.Response response = await pusher
                            .trigger(['channelName'], 'eventName', data);
                        _textEditingController.text = '';
                        // print("res: $response");
                      },
                      icon: Icon(Icons.send),
                      label: Text("")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    Pusher.disconnect();
    super.deactivate();
  }
}