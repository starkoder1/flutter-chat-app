import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/widgets/user_image_picker.dart';

final firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  var _isAuthenticating = false;
  final _form = GlobalKey<FormState>();

  var userEmail = '';
  var userPass = '';
  var userName = '';
  File? selectedImage;

  void _onSubmit() async {
    if (_form.currentState!.validate()) {
      _form.currentState!.save();
    } else {
      return;
    }

    if (!_isLogin &&
        selectedImage == null /*if in signup mode and image is not picked*/) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Image cannot be empty")));
      return;
    }

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        final userCredentials = await firebase.signInWithEmailAndPassword(
            email: userEmail, password: userPass);
        print(userCredentials);
        print(userCredentials);
      } else {
        final userCredentials = await firebase.createUserWithEmailAndPassword(
            email: userEmail, password: userPass);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user-images')
            .child(
                '${userCredentials.user!.uid}.jpg'); //accessing storage bucket reference
        // Fire

        await storageRef.putFile(selectedImage!); //start upload task
        final pictureurl =
            await storageRef.getDownloadURL(); //get download link

        // print(pictureurl);
        // print(userCredentials);
        // print(userCredentials);
        FirebaseFirestore.instance
            .collection('users')  
            .doc(userCredentials.user!.uid)
            .set({
          'username': userName,
          'email': userEmail,
          'profile_url': pictureurl,
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication Failed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, left: 20, bottom: 20, right: 20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              UserImagePicker(
                                onPickImage: (pickedImage) {
                                  selectedImage = pickedImage;
                                },
                              ),
                            const SizedBox(
                              height: 16,
                            ),
                            if (!_isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                  label: Text("Username"),
                                ),
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 6) {
                                    return 'Username must be at least 6 characters';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  userName = newValue!;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text("Email Address"),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    !(value.contains('@'))) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                userEmail = newValue!;
                              },
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text("Password"),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.length < 6) {
                                  return 'Password must be at least 6 characters long';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                userPass = newValue!;
                              },
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            if (_isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!_isAuthenticating)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                onPressed: _onSubmit,
                                child: Text(_isLogin ? 'Login' : 'Signup'),
                              ),
                            if (!_isAuthenticating)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? 'Create an Account'
                                    : 'I have an account'),
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
