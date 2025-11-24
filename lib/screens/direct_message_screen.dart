import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

class DirectMessageArguments {
  DirectMessageArguments({
    this.listingTitle,
    this.sellerName,
    this.name,
    this.surname,
  });

  final String? listingTitle;
  final String? sellerName;
  final String? name;
  final String? surname;
}

class DirectMessageScreen extends StatelessWidget {
  const DirectMessageScreen({
    super.key,
    this.name,
    this.surname,
    this.arguments,
  });

  final String? name;
  final String? surname;
  final DirectMessageArguments? arguments;

  static const routeName = '/direct-message';

  String get _displayName {
    if (arguments != null) {
      return arguments!.sellerName ?? arguments!.listingTitle ?? 'Seller';
    }
    if (name != null && surname != null) {
      return '$name $surname';
    }
    return name ?? 'Seller';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_displayName)),
      body: MessagesScreen(),
    );
  }
}


class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  //this will be populated through a fetch later, for now mock messages
  List<Message> messages = [
    Message(text: "test", date: DateTime.now().subtract(Duration(days: 10)), sentByMe: true),
    Message(text: "test", date: DateTime.now().subtract(Duration(days: 10)), sentByMe: false),
    Message(text: "test", date: DateTime.now().subtract(Duration(days: 11)), sentByMe: true),
    Message(text: "test", date: DateTime.now().subtract(Duration(days: 11)), sentByMe: false),
    Message(text: "test", date: DateTime.now().subtract(Duration(days: 12)), sentByMe: true),
    Message(text: "test", date: DateTime.now().subtract(Duration(days: 12)), sentByMe: false),
    Message(text: "test", date: DateTime.now().subtract(Duration(days: 13)), sentByMe: true),
    Message(text: "test", date: DateTime.now().subtract(Duration(days: 13)), sentByMe: false),
    Message(text: "Hello", date: DateTime.now(), sentByMe: true),
    Message(text: "Hi", date: DateTime.now().add(Duration(minutes: 3)), sentByMe: false),
    Message(text: "Are you still selling the fridge?", date: DateTime.now().add(Duration(minutes: 4)), sentByMe: true),
    Message(text: "No, it got sold", date: DateTime.now().add(Duration(days: 1)), sentByMe: false),


  ];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(

        children: [
          Expanded(child: GroupedListView(
              reverse: true,
              order: GroupedListOrder.DESC,
              elements: messages,
              groupBy: (message) => DateTime(
                message.date.year,
                message.date.month,
                message.date.day
              ),
              groupHeaderBuilder: (message) => SizedBox(
                height: 100,
                child: Center(
                  child: Card(
                    color: Colors.blueAccent[300],
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(DateFormat.yMMMd().format(message.date)),
                    ),
                  ),
                ),
              ),
              itemBuilder: (context, message) => Align(
                alignment: message.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Card(
                  shadowColor: Colors.transparent,
                  color: message.sentByMe ? Colors.blue[700] : Colors.blue[100],
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      message.text,
                      style: message.sentByMe ? TextStyle(color: Colors.white): null),
                  ),
                ),)
          )),

          Container(
            child: TextField(
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.send),
                contentPadding: EdgeInsets.all(10),
                hintText: "Type message...",
                border: OutlineInputBorder()
              ),
            ),
          )

        ],
      ),
    );
  }
}

class Message {
  final String text;
  final DateTime date;
  final bool sentByMe;

  Message({required this.text, required this.date, required this.sentByMe});
}
