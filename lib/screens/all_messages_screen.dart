import 'package:flutter/material.dart';


class DMPreview {

  final String? name;
  final String? surname;
  final String? messagePreview;

  DMPreview({this.name, this.surname, this.messagePreview});
}
//temporary: for now we are just making a demo list of these, later API will give json to populate the state
DMPreview prv1 = DMPreview(name: "Imran", surname: "Hasanzade", messagePreview: "this is the message preivew");
DMPreview prv2 = DMPreview(name: "Aaaaa", surname: "BBBbb", messagePreview: "this is the message preivew");
DMPreview prv3 = DMPreview(name: "Ccccc", surname: "DDdddd", messagePreview: "this is the message preivew");



class AllMessagesScreen extends StatefulWidget {
  AllMessagesScreen({super.key});
  static const routeName = '/main/all-messages';

  @override
  State<AllMessagesScreen> createState() => _AllMessagesScreenState();
}

class _AllMessagesScreenState extends State<AllMessagesScreen> {
  List<DMPreview> dmPreviews = [prv1, prv2, prv3];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Messages")),
      body: ListView.builder(
        itemCount: dmPreviews.length,
        itemBuilder: (context, index) {
          Card(
            child: ListTile(
              onTap:  () {print("tapped");},
              title: Text("${dmPreviews[index].name} ${dmPreviews[index].surname}"),

            ),
          );
        },
      ),

    );;
  }
}

