// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddContact extends StatefulWidget {
  String? userid;
  AddContact({required this.userid, super.key});

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  TextEditingController nameController = TextEditingController();
  TextEditingController numController = TextEditingController();

  String username = "";
  String usernum = "";
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 40, 39, 39),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Add Contact"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                        Map<String, dynamic> tomap() {
                          return {"name": username, "number": usernum};
                        }

                        await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(widget.userid)
                            .collection('contacts')
                            .add(tomap());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Contact created successfully'),
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
                  child: Text("Save"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
