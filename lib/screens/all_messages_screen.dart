import 'package:flutter/material.dart';
import 'package:su_fridges/screens/direct_message_screen.dart';


class DMPreview {

  final String name;
  final String surname;
  final String messagePreview;

  DMPreview(this.name, this.surname, this.messagePreview);
}




class AllMessagesScreen extends StatefulWidget {
  AllMessagesScreen({super.key});
  static const routeName = '/main/all-messages';

  @override
  State<AllMessagesScreen> createState() => _AllMessagesScreenState();
}

class _AllMessagesScreenState extends State<AllMessagesScreen> {
  List<DMPreview> dmPreviews = [
    //this will be later fetched from a seperate messages document in the database
    DMPreview("Imran", "Hasanzade", "this is the message preivew"),
    DMPreview("Mazen", "Zeybek", "this is the message preivew"),


  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Messages")),
      body: ListView.builder(
        itemCount: dmPreviews.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(dmPreviews[index].name[0]),
              ),
              onTap:  () {
                Navigator.push(
                    context,
                    MaterialPageRoute( builder: (context) => DirectMessageScreen(
                        name: dmPreviews[index].name, surname: dmPreviews[index].surname
                    )));
              },
              title: Text("${dmPreviews[index].name} ${dmPreviews[index].surname}"),
              subtitle: Text(dmPreviews[index].messagePreview),

            ),
          );
        },
      ),

    );;
  }
}

