import 'package:crudapps/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List blog = List.empty();
  String name = "";
  String description = "";

  get blogList => null;
  @override
  void initState() {
    super.initState();
    blog = ["Hello", "Hey There"];
  }

  createblog() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("My Blogs").doc(name);

    Map<String, String> blogList = {"blogName": name, "blogDesc": description};

    documentReference
        .set(blogList)
        .whenComplete(() => print("Data stored sucessfullt"));
  }

  deleteBlog(item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("My Blogs").doc(item);

    documentReference.delete().whenComplete(() => print("deleted sucessfully"));
  }

  updateBlog() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("My Blogs").doc(name);

    Map<String, String> blogList = {"blogName": name, "blogDesc": description};

    documentReference
        .update(blogList)
        .whenComplete(() => print("update sucessfully"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('To Do'),
        backgroundColor: Colors.brown[400],
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
              icon: Icon(Icons.person),
              label: Text('Logout'),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  print("Signed Out");
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignInScreen()));
                });
              })
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("My Blogs").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          } else if (snapshot.hasData || snapshot.data != null) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  QueryDocumentSnapshot<Object?>? documentSnapshot =
                      snapshot.data?.docs[index];
                  return Dismissible(
                      key: Key(index.toString()),
                      child: Card(
                          elevation: 4,
                          child: ListTile(
                            title: Text((documentSnapshot != null)
                                ? (documentSnapshot["blogName"])
                                : ""),
                            subtitle: Text((documentSnapshot != null)
                                ? ((documentSnapshot["blogDesc"] != null)
                                    ? documentSnapshot["blogDesc"]
                                    : "")
                                : ""),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        //todos.removeAt(index);
                                        deleteBlog((documentSnapshot != null)
                                            ? (documentSnapshot["blogName"])
                                            : "");
                                      });
                                    },
                                    icon: Icon(Icons.delete)),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        //todos.add(title);
                                        updateBlog();
                                      });
                                    },
                                    icon: Icon(Icons.edit)),
                              ],
                            ),
                          )));
                });
          }
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.red,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  title: const Text("Add Blog"),
                  content: Container(
                    width: 400,
                    height: 100,
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (String value) {
                            name = value;
                          },
                        ),
                        TextField(
                          onChanged: (String value) {
                            description = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          setState(() {
                            //todos.add(title);
                            createblog();
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text("Add"))
                  ],
                );
              });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
