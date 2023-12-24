import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vortex/models/chat_user.dart';
import 'package:vortex/models/message.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for storing self information
  static late ChatUser me;

  // to return current user
  static User get user => auth.currentUser!;

  // for checking if user exist or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I am using VorTex!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for checking if user exist or not?
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  ///*************** Chat Screen Related APIs ***************

  //  chats (collection) --> conversation_id(doc) --> messages(collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages')
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    // message sending time ( also used as id )
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final Message message = Message(
        msg: msg,
        toId: chatUser.id,
        read: '',
        type: Type.text,
        fromId: user.uid,
        sent: time);

    final ref = firestore
      .collection('chats/${getConversationID(chatUser.id)}/messages');
    await ref.doc(time).set(message.toJson());
  }
}
