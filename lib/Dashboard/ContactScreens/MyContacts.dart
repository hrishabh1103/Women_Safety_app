import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyContactsScreen extends StatefulWidget {
  const MyContactsScreen({Key? key}) : super(key: key);

  @override
  _MyContactsScreenState createState() => _MyContactsScreenState();
}

class _MyContactsScreenState extends State<MyContactsScreen> {
  List<String> contactsList = [];

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  // Loads contacts from SharedPreferences and updates the state
  Future<void> loadContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      contactsList = prefs.getStringList("numbers") ?? [];
    });
  }

  // Updates contacts in SharedPreferences
  Future<void> updateNewContactList(List<String> contacts) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("numbers", contacts);
  }

  // Deletes a contact and updates the list
  void deleteContact(int index) {
    setState(() {
      String removedContactName = contactsList[index].split("***")[0] ?? "No Name";
      contactsList.removeAt(index);
      updateNewContactList(contactsList); // Update the SharedPreferences
      Fluttertoast.showToast(msg: "$removedContactName removed!");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFCFE),
      appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: Text(
            "SOS Contacts",
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Image.asset("assets/phone_red.png"),
            onPressed: () {},
          )
      ),
      body: contactsList.isNotEmpty ? Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(child: Divider(indent: 20, endIndent: 20)),
                Text("Swipe left to delete Contact"),
                Expanded(child: Divider(indent: 20, endIndent: 20)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: contactsList.length,
              itemBuilder: (context, index) {
                final contactName = contactsList[index].split("***")[0] ?? "No Name";
                final contactNumber = contactsList[index].split("***")[1] ?? "No Contact";

                return Slidable(
                  key: ValueKey(index),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (context) => deleteContact(index),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: Container(
                    color: Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        backgroundImage: AssetImage("assets/user.png"),
                      ),
                      title: Text(contactName),
                      subtitle: Text(contactNumber),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
        ],
      ) : Center(
        child: Text("No Contacts found!"),
      ),
    );
  }
}
