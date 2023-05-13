import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_list/Screens/User_Contact_List/edit_contact.dart';
import 'package:contact_list/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Login/login_screen.dart';
import 'add_contact.dart';

class UserScreen extends StatefulWidget {
  String userid;
  UserScreen({required this.userid, super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? logedInUser;

  @override
  void initState() {
    super.initState();
    delay();
    logedInUser = widget.userid;
  }

  bool isLoading = true;

  void delay() async {
    await Future.delayed(Duration(seconds: 4));
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 40, 39, 39),
      floatingActionButton: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 118, 112, 112),
            borderRadius: BorderRadius.circular(50)),
        child: IconButton(
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddContact(
                  userid: logedInUser,
                ),
              ),
            );
          },
          icon: const Icon(Icons.add),
        ),
      ),
      appBar: AppBar(
        title: const Text("Contact List"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () async {
                // getContacts();
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.clear();
                _auth.signOut();
                // ignore: use_build_context_synchronously
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false);
              },
              icon: const Icon(Icons.logout_outlined),
            ),
          ),
        ],
      ),
      body: Container(
          child: Column(
        children: [
          Expanded(
            child: Container(
              // height: MediaQuery.of(context).size.height - 180,
              padding: const EdgeInsets.all(4),
              // margin: const EdgeInsets.all(8),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('Users')
                          .doc(widget.userid)
                          .collection('contacts')
                          .orderBy('name')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("An Error Occured ${snapshot.error}"),
                          );
                        } else if (snapshot.data?.size == 0) {
                          return const Center(
                            child: Text(
                              "No Contacts ",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          );
                        } else if (snapshot.hasData) {
                          return getContact(snapshot);
                        } else
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                      },
                    ),
            ),
          ),
        ],
      )),
    );
  }

  Widget getContact(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return ListView(
      children: snapshot.data!.docs.map((DocumentSnapshot document) {
        // print("contact id = ${document.id}");
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        return Card(
          color: Colors.black,
          child: ListTile(
            leading: CircleAvatar(
              foregroundColor: Colors.white,
              backgroundColor: data['name'].length % 2 == 0
                  ? Colors.green
                  : Colors.deepPurple,
              child: Text(
                data['name'][0],
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  data['number'],
                  style: const TextStyle(color: Colors.white),
                )
              ],
            ),
            trailing: SizedBox(
              width: 144,
              child: Row(
                children: [
                  IconButton(
                      onPressed: () async {
                        await launchPhoneDialer(data['number']);
                      },
                      icon: const Icon(
                        Icons.call,
                        color: Colors.lightBlueAccent,
                      )),
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditContact(
                              userid: logedInUser,
                              contactId: document.id,
                              currentName: data['name'],
                              currentPhoneNumber: data['number'],
                            ),
                          ),
                        );
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                      )),
                  IconButton(
                      onPressed: () {
                        deleteContact(document.id);
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void deleteContact(String contactID) async {
    try {
      await _firestore
          .collection('Users')
          .doc(widget.userid)
          .collection('contacts')
          .doc(contactID)
          .delete()
          .then(
            (value) => setState(() {}),
          );
    } catch (e) {
      print("An exception is coming ${e}");
    }
  }

  Future<void> launchPhoneDialer(String contactNumber) async {
    final Uri call = Uri(scheme: 'tel', path: contactNumber);
    try {
      if (await canLaunchUrl(call)) {
        await launchUrl(call);
      }
    } catch (error) {
      print("can not launch ${error}");
      throw ("Cannot dial");
    }
  }
}
