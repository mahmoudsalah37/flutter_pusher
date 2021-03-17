import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pusher/models/chat_model.dart';
import 'package:intl/intl.dart' as i;
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
  final ScrollController _scrollController = ScrollController();
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
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 1000,
          duration: Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn,
        );
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
              child: Scrollbar(
//                showTrackOnHover: true,
                controller: _scrollController,
                child: ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      final message = messages.elementAt(index);
                      bool isMe = widget.userName == message.user;
                      return Directionality(
                        textDirection:
                            isMe ? TextDirection.ltr : TextDirection.rtl,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                tileColor:
                                    isMe ? Colors.grey[300] : Colors.blue[300],
                                title: Text(
                                  "${message.user}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Text("${message.message}"),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  "${message.date}",
                                  style: TextStyle(
                                      fontSize: 10.0, color: Colors.grey[500]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
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
                                user: '${widget.userName}',
                                message: '$message',
                                date:
                                    '${i.DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now())}')
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
