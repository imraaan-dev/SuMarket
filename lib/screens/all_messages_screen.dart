import 'package:flutter/material.dart';
import 'direct_message_screen.dart';


class DMPreview {

  final String name;
  final String surname;
  final String messagePreview;

  DMPreview(this.name, this.surname, this.messagePreview);
}




class AllMessagesScreen extends StatefulWidget {
  const AllMessagesScreen({super.key});
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

  void _removeMessage(int index) {
    setState(() {
      dmPreviews.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message removed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Messages")),
      body: dmPreviews.isEmpty
          ? const Center(
              child: Text('No messages yet'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: dmPreviews.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(dmPreviews[index].name[0]),
                    ),
                    title: Text("${dmPreviews[index].name} ${dmPreviews[index].surname}"),
                    subtitle: Text(dmPreviews[index].messagePreview),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _removeMessage(index),
                      tooltip: 'Remove message',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DirectMessageScreen(
                            name: dmPreviews[index].name,
                            surname: dmPreviews[index].surname,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

