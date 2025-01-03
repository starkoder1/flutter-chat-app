import 'package:chat_app/screens/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sumbitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }
    _messageController.clear();

    final userData = await FirebaseFirestore.instance    /*getting userdata again to store it with each message below*/
        .collection('users')
        .doc(firebase.currentUser!.uid)
        .get();
    await FirebaseFirestore.instance.collection('chat').add({
      'message': enteredMessage,
      'user': firebase.currentUser!.uid,
      'createdAt': Timestamp.now(),
      'username': userData.data()!['username'],
      'profileUrl': userData.data()!['profile_url'],
      
    });                                                    //storing messages with other data
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 25),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: "Send a message",
              ),
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
            ),
          ),
          IconButton(
            onPressed: _sumbitMessage,
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
