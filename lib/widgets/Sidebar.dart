import 'dart:io';

import 'package:db_proj_blogappui/pages/AddBlogpage.dart';
import 'package:db_proj_blogappui/pages/UserBlogpage.dart';
import 'package:db_proj_blogappui/widgets/Toast_msg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../pages/Login.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  User? currentuser = FirebaseAuth.instance.currentUser;
  String? _profilePictureUrl; // To store the profile image URL
  File? image;
  final imagepicker = ImagePicker();
  DatabaseReference dref = FirebaseDatabase.instance.ref("images");
  final storageRef = FirebaseStorage.instance.ref("NewImagesFolder");
  final key = FirebaseAuth.instance.currentUser!.uid;
  int id = 0;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  void _loadProfilePicture() async {
    DatabaseReference profileRef = dref.child(key).child("profile");
    DataSnapshot snapshot = await profileRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>?; // Cast to a Map
      if (data != null && data.containsKey("imageurlProfile")) {
        setState(() {
          _profilePictureUrl = data["imageurlProfile"];
        });
      }
    }
  }

  Future getimagefromgallery() async {
    final pickedFile = await imagepicker.pickImage(
        source: ImageSource.gallery, imageQuality: 100);
    setState(() {});
    if (pickedFile != null) {
      image = File(pickedFile.path);
    } else {
      Toast_msg().showMsg("No image Selected");
      print("No image Selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              'username',
              style: TextStyle(fontSize: 15),
            ),
            accountEmail: Text(
              currentuser?.email ?? 'email@gmail.com',
              style: TextStyle(fontSize: 15),
            ),
            currentAccountPicture: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 4, color: Colors.white),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: _profilePictureUrl != null
                          ? Image.network(
                              _profilePictureUrl!,
                              height: 190,
                              width: 190,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              'https://plus.unsplash.com/premium_photo-1683121769247-7824fdc324de?q=80&w=870&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                              height: 190,
                              width: 190,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    hoverColor: Colors.black,
                    onTap: () async {
                      await getimagefromgallery();
                      if (image != null) {
                        id++;
                        final refimg =
                            storageRef.child("img").child("$key/$id");

                        UploadTask uploadTask = refimg.putFile(
                          image!.absolute,
                          SettableMetadata(
                            contentType: "image/jpeg",
                          ),
                        );

                        Future.value(uploadTask).then((value) async {
                          final downloadurl = await refimg.getDownloadURL();
                          print("Image Url WA910 => $downloadurl");

                          dref.child(key).child("profile").set(
                              {"imageurlProfile": downloadurl}).then((value) {
                            Toast_msg().showMsg("Image Uploaded in db");
                            setState(() {
                              _profilePictureUrl = downloadurl;
                            });
                          }).onError((error, stackTrace) {
                            Toast_msg().showMsg(error.toString());
                          });
                        }).onError((error, stackTrace) {
                          Toast_msg().showMsg(error.toString());
                        });
                      }
                    },
                    child: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 4, color: Colors.white),
                        color: Colors.grey,
                      ),
                      child: Icon(
                        Icons.edit,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.redAccent,
            ),
          ),
          ListTile(
            leading: Icon(Icons.my_library_books),
            title: Text('My Blogs'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserBlogpage(
                    blogID: '',
                    blogDescription: '',
                    blogTitle: '',
                    ind: '',
                    dbref: FirebaseDatabase.instance.ref("Appusers"),
                    imageurl: '',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Add Post'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddBlogpage(
                    updatepostid: '',
                    likescount: 0,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            onTap: () => null,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout_outlined),
            title: Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut().then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
