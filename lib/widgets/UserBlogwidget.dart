import 'package:db_proj_blogappui/pages/AddBlogpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../pages/Blogpage.dart';

class UserBlogwidget extends StatefulWidget {
  final String blogID;
  final String blogTitle;
  final String blogDescription;
  final String ind;
  final DatabaseReference dbref;
  final String imageurl;
  UserBlogwidget(
      {Key? key,
      required this.blogID,
      required this.blogTitle,
      required this.blogDescription,
      required this.ind,
      required this.dbref,
      required this.imageurl})
      : super(key: key);

  @override
  State<UserBlogwidget> createState() => _UserBlogwidgetState();
}

class _UserBlogwidgetState extends State<UserBlogwidget> {
  final dbref = FirebaseDatabase.instance.ref("testusers");
  final key = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // stream: widget.dbref.child("paths").child(widget.ind).onValue,
      stream: widget.dbref.child("userBlogs").child(widget.ind).onValue,
      builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
          return Center(child: Text("No data available."));
        } else {
          // Process data here
          var data = snapshot.data!.snapshot.value;
          List<Object?> list = [];

          if (data is List) {
            list = data;
          } else if (data is Map) {
            list = data.values.toList();
          }

          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: list.length,
            itemBuilder: (context, index) {
              Object? items = list[index];
              if (items is Map<dynamic, dynamic>) {
                return myCustomlistile(items, index);
              } else if (items == null) {
                return Container();
              } else {
                return ListTile(
                  title: Text(items.toString()),
                );
              }
            },
          );
        }
      },
    );
  }

  Widget myCustomlistile(Map<dynamic, dynamic> items, int index) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Blogpage(
                          blogID: '',
                          blogTitle: '',
                          blogDescription: '',
                          ind: '',
                          dbref: dbref,
                          imageurl: '',
                        )),
              );
            },
            child: Hero(
              tag: "blogImage",
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(items["imageurl"].toString()),
                    fit: BoxFit.cover,
                    opacity: 0.8,
                  ),
                ),
              ),
            ),
          ),
          //////blog title //////
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (items != null && items["Title"] != null)
                      ? items["Title"].toString()
                      : "No Title",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                //////////update btn
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      color: const Color.fromARGB(255, 136, 132, 132),
                      icon: Icon(Icons.update),
                      onPressed: () {
                        String updatepostid = items["ID"].toString();
                        if (updatepostid != null) {
                          // int postID = postid;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddBlogpage(
                                        updatepostid: updatepostid,
                                        likescount: 0,
                                      )));
                        }
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: InkWell(
                        onTap: () {
                          String deleteid = items["ID"].toString();
                          if (deleteid != null && deleteid.isNotEmpty) {
                            widget.dbref
                                .child("userBlogs")
                                .child(key)
                                .child("${deleteid}")
                                .remove()
                                .then((value) => print(
                                    "POST DELETED ******************************************* ${deleteid}"));

                            widget.dbref
                                .child("allBlogs")
                                .child("${deleteid}")
                                .remove()
                                .then((value) => print(
                                    "POST DELETED ******************************************* ${deleteid}"));
                          }
                        },
                        child: Icon(
                          Icons.delete,
                          size: 24,
                          color: const Color.fromARGB(255, 136, 132, 132),
                        ),
                      ),
                    ),
                  ],
                ),

                ////////////like count ////////
              ],
            ),
          ),
        ],
      ),
    );
  }
}
