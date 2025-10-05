import 'dart:io';
import 'package:db_proj_blogappui/pages/Homepage.dart';
import 'package:db_proj_blogappui/pages/UserBlogpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

int id = 0;

class AddBlogpage extends StatefulWidget {
  final String updatepostid;
  int likescount;
  AddBlogpage(
      {super.key, required this.updatepostid, required this.likescount});

  @override
  State<AddBlogpage> createState() => _AddBlogpageState();
}

class _AddBlogpageState extends State<AddBlogpage> {
  var titlecontroller = TextEditingController();
  var desccontroller = TextEditingController();
  final dbref = FirebaseDatabase.instance.ref("testusers");
  final storageref = FirebaseStorage.instance.ref("IMAGEFOLDER");
  final key = FirebaseAuth.instance.currentUser!.uid; //user key
  File? blogimg;

  void pickImage_gallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        blogimg = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Container(
              color: Colors.redAccent,
              padding: EdgeInsets.fromLTRB(25, 30, 25, 25),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 30),
                    child: Text(
                      "My Blog",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ////////////////////////////////////// Post btn ////////////////////////////
                  InkWell(
                    onTap: () async {
                      // Instead of using id, use push() to generate a unique key
                      DatabaseReference newPostRef =
                          dbref.child("allBlogs").push();
                      if (widget.updatepostid != null &&
                          widget.updatepostid.isNotEmpty) {
                        // If updating an existing post, use the provided key
                        newPostRef =
                            dbref.child("allBlogs").child(widget.updatepostid);
                      } else {
                        // If creating a new post, generate a new key
                        newPostRef = dbref.child("allBlogs").push();
                      }

                      String blogID = newPostRef.key!; //post key

                      Map<String, dynamic> blogdata = {
                        "ID": blogID, // Use the generated key as ID
                        "Title": titlecontroller.text,
                        "Desc": desccontroller.text,
                        "Dateofpost": DateTime.now().toString(),
                        "Likes": widget.likescount.toString(),
                      };

                      final refimg =
                          await storageref.child("img").child("$key/$blogID");
                      UploadTask uploadTask = refimg.putFile(blogimg!.absolute);

                      Future.value(uploadTask).then((value) async {
                        final downloadurl = await refimg.getDownloadURL();
                        blogdata["imageurl"] = downloadurl;

                        if (widget.updatepostid != null &&
                            widget.updatepostid.isNotEmpty) {
                          dbref
                              .child("allBlogs")
                              .child('${widget.updatepostid}')
                              .update(blogdata)
                              .then((value) => {
                                    print("Sucessfully Updated home"),
                                  })
                              .onError((error, stackTrace) => {
                                    print("$error"),
                                  });
                          dbref
                              .child("userBlogs")
                              .child(key)
                              .child('${widget.updatepostid}')
                              .update(blogdata)
                              .then((value) => {
                                    print("Sucessfully Updated userblogs"),
                                  })
                              .onError((error, stackTrace) => {
                                    print("$error"),
                                  });
                        } else {
                          dbref
                              .child("allBlogs")
                              .child(blogID)
                              .set(blogdata)
                              .then((value) => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Homepage(
                                            blogID: id.toString(),
                                            blogTitle: titlecontroller.text,
                                            blogDescription:
                                                desccontroller.text,
                                            ind: key,
                                            dbref: dbref,
                                            imageurl: downloadurl,
                                            likescount: widget.likescount,
                                          ))))
                              .onError((error, stackTrace) {
                            print("Error Occured!! $error");
                          });

                          dbref
                              .child("userBlogs")
                              .child(key)
                              .child(blogID)
                              .set(blogdata)
                              .then(
                                (value) => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserBlogpage(
                                      blogID: blogID,
                                      blogTitle: titlecontroller.text,
                                      blogDescription: desccontroller.text,
                                      ind: key,
                                      dbref: dbref,
                                      imageurl: downloadurl,
                                    ),
                                  ),
                                ),
                              ); //then
                        }
                      } //future
                          ); //future then
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 200),
                      child: Text(
                        "POST",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    pickImage_gallery(); ////method to call image
                    print('Image Clicked!');
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Color(0xFFEDECF2),
                      ),
                      child: blogimg == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  iconSize: 55,
                                  color: Color.fromARGB(255, 184, 181, 181),
                                  onPressed: () {
                                    ///////////////////////image functionality/////////////////
                                    pickImage_gallery(); ////method to call image
                                  },
                                  icon: Icon(Icons.add_a_photo),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Add Photo",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300),
                                ),
                              ],
                            )
                          : Image.file(
                              blogimg!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            Scrollbar(
              child: Column(
                children: [
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: titlecontroller,
                      minLines: 2,
                      maxLines: 20,
                      decoration: InputDecoration(
                        labelText: "Title",
                        hintText: "Enter Title",
                        labelStyle: TextStyle(
                          color: Colors.redAccent,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2, color: Colors.redAccent),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: desccontroller,
                      minLines: 2,
                      maxLines: 20,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: Colors.redAccent,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2, color: Colors.redAccent),
                        ),
                        labelText: "Description",
                        hintText: "Enter Description",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
