import 'package:db_proj_blogappui/widgets/Likebtn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../pages/Blogpage.dart';

class Blogwidget extends StatefulWidget {
  final String blogID;
  final String blogTitle;
  final String blogDescription;
  final String ind;
  final DatabaseReference dbref;
  final String imageurl;
  final String searchquery;
  int likescount;

  Blogwidget({
    Key? key,
    required this.blogID,
    required this.blogTitle,
    required this.blogDescription,
    required this.ind,
    required this.dbref,
    required this.imageurl,
    required this.searchquery,
    required this.likescount,
  }) : super(key: key);

  @override
  State<Blogwidget> createState() => _BlogwidgetState();
}

class _BlogwidgetState extends State<Blogwidget> {
  final dbref = FirebaseDatabase.instance.ref("testusers");
  final key = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: widget.dbref.child("allBlogs").child(widget.ind).onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (!snapshot.hasData ||
              snapshot.data?.snapshot.value == null) {
            return Center(child: Text("No data available."));
          } else {
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
                  final searchval = items["Title"].toString().toLowerCase();
                  if (searchval.contains(widget.searchquery.toLowerCase())) {
                    return myCustomlistile(items, index);
                  } else if (widget.searchquery.isEmpty) {
                    return myCustomlistile(items, index);
                  }
                } else if (items == null) {
                  return Container();
                } else {
                  return ListTile(
                    title: Text(items.toString()),
                  );
                }
                return Container(); // This line is added to handle all cases.
              },
            );
          }
        },
      ),
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
                    blogID: widget.blogID,
                    blogTitle: items["Title"],
                    blogDescription: items["Desc"],
                    ind: widget.ind,
                    dbref: dbref,
                    imageurl: items["imageurl"],
                  ),
                ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Likebtn(
                      onTap: () {},
                      likescount: items["Likes"] is String
                          ? int.tryParse(items["Likes"] ?? '0')
                          : items["Likes"],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: InkWell(
                        onTap: () {},
                        child: Icon(
                          Icons.comment_outlined,
                          size: 24,
                          color: const Color.fromARGB(255, 136, 132, 132),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
