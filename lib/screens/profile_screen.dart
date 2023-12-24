import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vortex/api/apis.dart';
import 'package:vortex/helper/dialogs.dart';
import 'package:vortex/models/chat_user.dart';
import 'package:vortex/screens/auth/login_screen.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          // app bar
          appBar: AppBar(
            title: const Text("Profile"),
          ),

          // floating button to add a new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.redAccent,
              onPressed: () async {
                // For showing the progress dialog
                Dialogs.showProgressBar(context);

                // Sign Out from the app
                await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    // for hiding progress dialog
                    Navigator.pop(context);

                    // for moving to home screen
                    Navigator.pop(context);

                    // replacing home screen with login screen
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()));
                  });
                });
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
            ),
          ),

          // body
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // for adding some space
                    SizedBox(
                      width: mq.width,
                      height: mq.height * .03,
                    ),

                    // User profile picture
                    Stack(
                      children: [
                        // Profile Picture
                        ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .3),
                          child: CachedNetworkImage(
                            width: mq.height * .2,
                            height: mq.height * .2,
                            fit: BoxFit.fill,
                            imageUrl: widget.user.image,
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                                    child: Icon(CupertinoIcons.person)),
                          ),
                        ),

                        // edit image button
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                              elevation: 1,
                              onPressed: () {
                                _showBottomSheet();
                              },
                              shape: const CircleBorder(),
                              color: Colors.white,
                              child: const Icon(
                                Icons.edit,
                                color: Colors.blue,
                              )),
                        )
                      ],
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .03),

                    // user email label
                    Text(widget.user.email,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 18)),

                    // for adding some space
                    SizedBox(height: mq.height * .05),

                    // name input field
                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: "eg. Nikhil Sharma",
                          label: const Text('Name')),
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .02),

                    // about input field
                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.info,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: "eg. Feeling Happy",
                          label: const Text('About')),
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .02),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          fixedSize: Size(mq.width * .35, mq.height * 0.06)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            Dialogs.showSnackBar(
                                context, 'Profile Updated Successfully!');
                          });
                        }
                      },
                      icon: const Icon(Icons.edit, size: 25),
                      label: const Text(
                        'Update',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }

// bottom sheet for picking a profile picture for user
  _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: mq.height * 0.03, bottom: mq.height * 0.1),
            children: [
              // Pick profile picture label
              Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),

              // for adding some space
              SizedBox(height: mq.height * .02),

              // buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pick image form gallery button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, 
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * .3, mq.height * 0.15)
                    ),
                      onPressed: () {},
                      child: Image.asset('images/add_image.png')),

                  // take picture from camera button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, 
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * .3, mq.height * 0.15)
                    ),
                      onPressed: () {},
                      child: Image.asset('images/camera.png'))
                ],
              )
            ],
          );
        });
  }
}