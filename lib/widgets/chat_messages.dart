import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final currentlyAuthenticatedUser = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No messages found!"),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        }

        final loadedMessages = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 45),
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index]
                .data(); //getting the chat message data at first index

            final nextChatMessage = index + 1 <
                    loadedMessages
                        .length // checking the next message if available otherwise set to null
                ? loadedMessages[index + 1].data()
                : null;
            final currentMessageUserId =
                chatMessage['user']; //getting the user id of the first message
            late final String? nextMessageUserId;
            if (nextChatMessage != null) {
              nextMessageUserId = nextChatMessage[
                  'user']; //getting the id of the next message after first
            } else {
              nextMessageUserId = null;
            }

            final nextUserIsSame = nextMessageUserId ==
                currentMessageUserId; //checking if 2 messages have the same id for styling
            if (nextUserIsSame) {
              return MessageBubble.next(
                  message: chatMessage['message'],
                  isMe: currentlyAuthenticatedUser == currentMessageUserId);
            } else {
              return MessageBubble.first(
                  userImage: chatMessage['profileUrl'],
                  username: chatMessage['username'],
                  message: chatMessage['message'],
                  isMe: currentlyAuthenticatedUser == currentMessageUserId);
            }
          },
        );
      },
    );
  }
}
