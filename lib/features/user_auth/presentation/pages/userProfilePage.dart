import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_harbor/features/user_auth/presentation/pages/wishListPage.dart';

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

  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

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
    final result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      final file = result.files.single;
      final imagePath = file.path;

      setState(() {
        _selectedImage = File(imagePath!);
      });

      final imageUrl = await _uploadImageToCloudinary(context);
      if (imageUrl != null) {
        await user?.updatePhotoURL(imageUrl);
        setState(() {});
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
      withData: true,
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

  Future<void> _submitFeedback() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both subject and message')),
      );
      return;
    }

    // Here you would submit the feedback to your backend, email service, or Firebase.
    // For this example, we will show a modal instead.
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feedback Submitted'),
        content: const Text('Thank you for your feedback! We will review it soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    _subjectController.clear();
    _messageController.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
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

                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'e.g. john_doe123',
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'e.g. John Doe',
                    ),
                  ),
                  const SizedBox(height: 10),

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
                  const SizedBox(height: 20),

                  // 💜 Wishlist Button
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const WishlistPage()),
                      );
                    },
                    icon: const Icon(Icons.favorite),
                    label: const Text("Go to Wishlist"),
                  ),
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 30),

                  // Feedback Section
                  const Text(
                    'Contact Support / Provide Feedback',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Subject Field
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Message Field
                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _submitFeedback,
                    child: const Text('Submit Feedback'),
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
