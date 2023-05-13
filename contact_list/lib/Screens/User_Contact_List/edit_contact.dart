// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_list/Screens/User_Contact_List/user_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'contact.dart';

class EditContact extends StatefulWidget {
  String? userid;
  String contactId;
  final String currentName;
  final String currentPhoneNumber;
  EditContact(
      {required this.currentName,
      required this.currentPhoneNumber,
      required this.userid,
      required this.contactId,
      super.key});

  @override
  State<EditContact> createState() => _EditContactState();
}

class _EditContactState extends State<EditContact> {
  TextEditingController nameController = TextEditingController();
  TextEditingController numController = TextEditingController();

  String username = "";
  String usernum = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    numController = TextEditingController(text: widget.currentPhoneNumber);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    numController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 40, 39, 39),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Edit Contact",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(left: 40),
                width: MediaQuery.of(context).size.width - 80,
                child: TextFormField(
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  controller: nameController,
                  validator: (value) {
                    if (value!.isNotEmpty) {
                      username = value;
                      return null;
                    } else {
                      return "Enter valid name";
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black,
                    hintText: "Name",
                    hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 186, 181, 181)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.only(left: 40),
                width: MediaQuery.of(context).size.width - 80,
                child: TextFormField(
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.length != 10) {
                      return "Enter valid number";
                    } else {
                      usernum = value;
                      return null;
                    }
                  },
                  controller: numController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black,
                    hintText: "Number",
                    hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 186, 181, 181)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(11),
                      borderSide: BorderSide(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 28.0),
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 118, 112, 112)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                        TextStyle(fontSize: 20)),
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.all(10)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        await updateContact(
                          widget.userid,
                          widget.contactId,
                          username,
                          usernum,
                        ).then((value) {
                          setState(() {});
                          Navigator.pop(context);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Contact updated successfully'),
                          ),
                        );
                        // Clear the form fields
                        nameController.clear();
                        numController.clear();
                      } catch (e) {
                        print('Error creating contact: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error creating contact'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text("Update"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateContact(
      String? userID, String contactID, String name, String num) async {
    try {
      final document = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userID)
          .collection('contacts')
          .doc(contactID);

      await document.update({'name': name, 'number': num});
    } catch (e) {
      print("An exception occured ${e}");
    }
  }
}
