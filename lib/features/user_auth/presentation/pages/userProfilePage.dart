import 'dart:convert';
import 'dart:io';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';

import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;
  final _nameController = TextEditingController();     // Username
  final _fullNameController = TextEditingController(); // Full name
  final _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? '';
    _loadFullName();
  }

  void _loadFullName() async {
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user!.uid).get();
      final fullName = doc.data()?['fullName'] ?? '';
      _fullNameController.text = fullName;
    }
  }

Future<void> _pickImage() async {
  // For Web and mobile support, use file_picker instead of image_picker
  final result = await FilePicker.platform.pickFiles(type: FileType.image);

  if (result != null) {
    final file = result.files.single;
    final imagePath = file.path;

    setState(() {
      _selectedImage = File(imagePath!); // Save the selected image
    });

    final imageUrl = await _uploadImageToCloudinary(context);
    if (imageUrl != null) {
      await user?.updatePhotoURL(imageUrl);
      setState(() {}); // refresh the UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated")),
      );
    }
  }
}

Future<String?> _uploadImageToCloudinary(BuildContext context) async {
  const cloudName = 'dt2dokj4b';
  const uploadPreset = 'laptop-harbor-preset';

  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
    withData: true, // Needed to access bytes
  );

  if (result == null || result.files.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No image selected")),
    );
    return null;
  }

  final file = result.files.first;
  final fileBytes = file.bytes;
  final fileName = file.name;

  if (fileBytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to read image bytes")),
    );
    return null;
  }

  final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  final request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

  final response = await request.send();
  final responseData = await http.Response.fromStream(response);

  if (response.statusCode == 200) {
    final data = jsonDecode(responseData.body);
    return data['secure_url'];
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to upload image to Cloudinary")),
    );
    return null;
  }
}


  Future<void> _updateProfile() async {
    if (_nameController.text.isNotEmpty) {
      await user?.updateDisplayName(_nameController.text);
    }

    if (_fullNameController.text.isNotEmpty) {
      await _firestore.collection('users').doc(user!.uid).set({
        'fullName': _fullNameController.text,
      }, SetOptions(merge: true));
    }

    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
  }

  Future<void> _changePassword() async {
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }

    try {
      await user?.updatePassword(_passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated")),
      );
      _passwordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, '/wishlist');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Username
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'e.g. john_doe123',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Full Name
                  TextField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'e.g. John Doe',
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Email (readonly)
                  Text(
                    user?.email ?? 'No email',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: _updateProfile,
                    icon: const Icon(Icons.save),
                    label: const Text("Save Changes"),
                  ),
                  const SizedBox(height: 30),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'New Password'),
                  ),
                  const SizedBox(height: 10),

                  TextButton.icon(
                    onPressed: _changePassword,
                    icon: const Icon(Icons.lock_reset),
                    label: const Text("Change Password"),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
