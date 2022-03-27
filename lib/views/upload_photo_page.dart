import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:renohouz_worker/manager.dart';
import 'package:renohouz_worker/providers/user_provider.dart';
import 'package:renohouz_worker/utils/debugger.dart';
import 'package:provider/provider.dart';
import 'package:renohouz_worker/widgets/extra_dialog.dart';
import 'package:image_picker/image_picker.dart';

class UploadPhotoPage extends StatefulWidget {
  const UploadPhotoPage({Key? key}) : super(key: key);

  @override
  State<UploadPhotoPage> createState() => _UploadPhotoPageState();
}

class _UploadPhotoPageState extends State<UploadPhotoPage> {
  final ImagePicker picker = ImagePicker();
  XFile? image;
  bool isLoading = false;

  Widget popupMenu() {
    return PopupMenuButton(itemBuilder: (context) {
      return [
        PopupMenuItem(
          child: TextButton(
            onPressed: () {
              User? user = FirebaseAuth.instance.currentUser;
              showConfirmationDialog(context, 'Are you sure you want to logout?', 'Yes, logout').then((confirm) async {
                if (confirm && user != null) {
                  Manager.signOut().catchError((err) {
                    Debugger.log(err);
                    showSimpleDialog(context, 'Something went wrong. Please try again later.');
                  });
                }
              });
            },
            child: const Text('Log out'),
          ),
        )
      ];
    });
  }

  void uploadImage() {
    if (image == null) {
      showSimpleDialog(context, 'Please upload a photo of your face.');
      return;
    }
    setState(() => isLoading = true);
    context.read<UserProvider>().uploadPhoto(image!.path).catchError((err) {
      Debugger.log(err);
      showSimpleDialog(context, 'Something went wrong. Please try again.');
    }).whenComplete(() => setState(() => isLoading = false));
  }

  Widget imagePicker() {
    if (image == null) {
      return InkWell(
        onTap: () {
          picker.pickImage(source: ImageSource.gallery).then((value) {
            if (value != null) {
              setState(() => image = value);
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 96 * 0.7),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add_a_photo_rounded, size: 64),
        ),
      );
    }
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(
            maxWidth: 350,
            maxHeight: 350,
          ),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.file(File(image!.path), fit: BoxFit.contain),
        ),
        TextButton.icon(
          onPressed: () {
            picker.pickImage(source: ImageSource.gallery).then((value) {
              if (value != null) {
                setState(() => image = value);
              }
            });
          },
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Change'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload photo'), actions: [popupMenu()]),
      body: Stack(
        children: [
          ListView(
            children: [
              const SizedBox(height: 48),
              Center(
                child: imagePicker(),
              ),
              const SizedBox(height: 48),
              const Center(child: Text('Please upload a photo of your face.')),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: ButtonStyle(minimumSize: MaterialStateProperty.all(const Size(double.infinity, 56))),
                onPressed: isLoading ? null : uploadImage,
                icon: const Icon(Icons.done_rounded),
                label: Text(isLoading ? 'Loading...' : 'Done'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
