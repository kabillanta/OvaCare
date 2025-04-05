import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import 'dart:io'; // For handling file paths
import 'package:firebase_storage/firebase_storage.dart';

class CommunityConnectPage extends StatefulWidget {
  const CommunityConnectPage({Key? key}) : super(key: key);

  @override
  _CommunityConnectPageState createState() => _CommunityConnectPageState();
}

class _CommunityConnectPageState extends State<CommunityConnectPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker(); // For image picking
  String searchQuery = "";
  File? _image; // To store the selected image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Connect',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'FunnelSans')),
        backgroundColor: Color.fromARGB(255, 74, 98, 138),
      ),
      backgroundColor: const Color.fromARGB(255, 241, 249, 249),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildPostsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: Color.fromARGB(255, 74, 98, 138),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by tag...',
          hintStyle: const TextStyle(
              color: Color.fromARGB(255, 74, 98, 138),
              fontFamily: 'FunnelSans'),
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color.fromARGB(255, 74, 98, 138)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color.fromARGB(255, 74, 98, 138)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 74, 98, 138), width: 2),
          ),
        ),
        onChanged: (value) {
          setState(() => searchQuery = value.toLowerCase());
        },
      ),
    );
  }

  Widget _buildPostsList() {
    return StreamBuilder(
      stream: _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        var posts = snapshot.data!.docs.where((doc) {
          var data = doc.data() as Map<String, dynamic>;
          List tags = data['tags'] ?? [];
          return searchQuery.isEmpty ||
              tags.any((tag) => tag.toLowerCase().contains(searchQuery));
        }).toList();

        if (posts.isEmpty) {
          return const Center(child: Text("No posts found."));
        }

        return ListView(
          children: posts.map((doc) => _buildPostItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildPostItem(QueryDocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    var postRef = _firestore.collection('posts').doc(doc.id);
    var user = _auth.currentUser;
    List likedBy = data['likedBy'] ?? [];
    bool isAuthor =
        user?.uid == data['authorId']; // Check if the user is the author

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(data['authorId']).get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
        if (userSnapshot.hasError) {
          return Text("Error: ${userSnapshot.error}");
        } else if (!userSnapshot.hasData || userSnapshot.data == null) {
          return Text("User not found");
        }

        var userData = userSnapshot.data?.data() as Map<String, dynamic>? ?? {};

        String username = userData['userName'] ??
            "Samyuktha Mohan Alagiri"; // Fix: Use `userData` instead of `data`
        String profilePic = userData['profilePic'] ?? "https://lh3.googleusercontent.com/a/ACg8ocKFSgTNedYaWDNm-oaJpD87sd5dG_f4rb265dXk9DhbCizZ53w=s96-c";

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border:
                Border.all(color: Color.fromARGB(255, 74, 98, 138), width: 1),
            boxShadow: [
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 74, 98, 138),
                  backgroundImage:
                      profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                  child: profilePic.isEmpty
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(
                  username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 74, 98, 138),
                    fontFamily: 'FunnelSans',
                  ),
                ),
                // More Options (Edit/Delete)
                trailing: isAuthor
                    ? PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            color: Color.fromARGB(255, 74, 98, 138)),
                        onSelected: (value) {
                          if (value == "Edit") {
                            _editPost(postRef, data['content']);
                          } else if (value == "Delete") {
                            _deletePost(postRef);
                          }
                        },
                        color: Colors
                            .white, // Sets background color of the dropdown
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                              color: Color.fromARGB(255, 74, 98, 138)),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: "Edit",
                            child: Text(
                              "Edit",
                              style: TextStyle(
                                fontFamily: 'FunnelSans',
                                color: Color.fromARGB(255, 74, 98, 138),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const PopupMenuItem(
                            value: "Delete",
                            child: Text(
                              "Delete",
                              style: TextStyle(
                                fontFamily: 'FunnelSans',
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
              if (data['imageUrl'] != null)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.network(data['imageUrl'],
                      width: double.infinity, fit: BoxFit.cover),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  data['content'] ?? "",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 74, 98, 138),
                    fontFamily: 'FunnelSans',
                  ),
                ),
              ),
              if (data['tags'] != null && data['tags'].isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 6,
                    children: (data['tags'] ?? [])
                        .map<Widget>((tag) => Chip(
                              label: Text(
                                "#$tag",
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 74, 98, 138),
                                    fontFamily: 'FunnelSans'),
                              ),
                              backgroundColor: Colors.white,
                              shape: const StadiumBorder(
                                side: BorderSide(
                                    color: Color.fromARGB(255, 74, 98, 138)),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        color: likedBy.contains(user?.uid)
                            ? Colors.red
                            : Colors.grey,
                      ),
                      onPressed: () =>
                          _likePost(postRef, data['likes'] ?? 0, likedBy),
                    ),
                    Text(
                      '${data['likes'] ?? 0} Likes',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 74, 98, 138),
                        fontFamily: 'FunnelSans',
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.comment, color: Colors.grey),
                      onPressed: () => _showComments(postRef),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editPost(DocumentReference postRef, String currentContent) {
    TextEditingController contentController =
        TextEditingController(text: currentContent);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            "Edit Post",
            style: TextStyle(
              fontFamily: 'FunnelSans',
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 74, 98, 138),
            ),
          ),
          content: TextField(
            controller: contentController,
            maxLines: 4,
            style: const TextStyle(
              fontFamily: 'FunnelSans',
              color: Color.fromARGB(255, 74, 98, 138),
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 74, 98, 138),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 74, 98, 138),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 74, 98, 138),
                  width: 2,
                ),
              ),
              hintText: "Update your post...",
              hintStyle: const TextStyle(
                fontFamily: 'FunnelSans',
                color: Colors.grey,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontFamily: 'FunnelSans',
                  color: Color.fromARGB(255, 74, 98, 138),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 74, 98, 138),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                postRef.update({'content': contentController.text});
                Navigator.pop(context);
              },
              child: const Text(
                "Save",
                style: TextStyle(
                  fontFamily: 'FunnelSans',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deletePost(DocumentReference postRef) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set background to white
          title: const Text(
            "Delete Post",
            style: TextStyle(
              fontFamily: 'FunnelSans',
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 74, 98, 138),
            ),
          ),
          content: const Text(
            "Are you sure you want to delete this post?",
            style: TextStyle(
              fontFamily: 'FunnelSans',
              color: Color.fromARGB(255, 74, 98, 138),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontFamily: 'FunnelSans',
                  color: Color.fromARGB(255, 74, 98, 138),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red for delete action
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                postRef.delete();
                Navigator.pop(context);
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                  fontFamily: 'FunnelSans',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _likePost(
      DocumentReference postRef, int likes, List likedBy) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (likedBy.contains(user.uid)) {
      await postRef.update({
        'likes': likes - 1,
        'likedBy': FieldValue.arrayRemove([user.uid]),
      });
    } else {
      await postRef.update({
        'likes': likes + 1,
        'likedBy': FieldValue.arrayUnion([user.uid]),
      });
    }
  }

  Future<void> _showCreatePostDialog() async {
    final TextEditingController contentController = TextEditingController();
    final TextEditingController tagController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Create a Post',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 74, 98, 138),
              fontFamily: 'FunnelSans',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color.fromARGB(255, 74, 98, 138),
                        width: 1.5,
                      ),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_image!, fit: BoxFit.cover))
                        : const Icon(Icons.add_a_photo,
                            size: 50, color: Color.fromARGB(255, 74, 98, 138)),
                  ),
                ),
                const SizedBox(height: 16),

                // Caption Input
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  maxLength: 2200,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 74, 98, 138),
                    fontFamily: 'FunnelSans',
                  ),
                  decoration: InputDecoration(
                    labelText: "Write a caption...",
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 74, 98, 138),
                      fontFamily: 'FunnelSans',
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 74, 98, 138)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 74, 98, 138)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 74, 98, 138), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tags Input
                TextField(
                  controller: tagController,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 74, 98, 138),
                    fontFamily: 'FunnelSans',
                  ),
                  decoration: InputDecoration(
                    labelText: "Tags (comma separated)",
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(255, 74, 98, 138),
                      fontFamily: 'FunnelSans',
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 74, 98, 138)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 74, 98, 138)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 74, 98, 138), width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'FunnelSans',
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 74, 98, 138),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please write a caption.")),
                  );
                  return;
                }
                await _createPost(contentController.text, tagController.text);
                Navigator.pop(context);
              },
              child: const Text(
                "Post",
                style: TextStyle(color: Colors.white, fontFamily: 'FunnelSans'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
          FirebaseStorage.instance.ref().child('post_images/$fileName');
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _createPost(String content, String tags) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() as Map<String, dynamic>? ?? {};

    // Upload image to Firebase Storage (if selected)
    String? imageUrl;
    if (_image != null) {
      // Implement Firebase Storage upload logic here
      imageUrl = await _uploadImage(_image!);
    }

    await _firestore.collection('posts').add({
      'authorId': user.uid,
      'userName': user.displayName,
      'profilePic': user.photoURL,
      'content': content.trim(),
      'tags': tags.split(',').map((tag) => tag.trim()).toList(),
      'likes': 0,
      'likedBy': [],
      'comments': [],
      'imageUrl': imageUrl, // Add image URL if available
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Clear the image after posting
    setState(() {
      _image = null;
    });
  }

  Future<void> _showComments(DocumentReference postRef) async {
    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            width: double.infinity,
            height: 500, // Enlarged Popup
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Comments",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF4A628A), // Navy Blue
                        fontFamily: 'FunnelSans',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),

                // Comments List
                Expanded(
                  child: StreamBuilder(
                    stream: postRef.snapshots(),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      var comments = (data['comments'] ?? []) as List;

                      if (comments.isEmpty) {
                        return const Center(
                          child: Text(
                            "No comments yet. Be the first to comment!",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          var commentData =
                              comments[index] as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile Picture
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: commentData['profilePic'] !=
                                          null
                                      ? NetworkImage(commentData['profilePic'])
                                      : null,
                                  child: commentData['profilePic'] == null
                                      ? const Icon(Icons.person,
                                          color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                // Comment Content
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Username in Navy Blue
                                        Text(
                                          commentData['username'] ??
                                              "Unknown User",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'FunnelSans',
                                            color:
                                                Color(0xFF3B5998), // Navy Blue
                                          ),
                                        ),
                                        // Comment Text in Lighter Blue
                                        Text(
                                          commentData['comment'] ?? "",
                                          style: const TextStyle(
                                            fontFamily: 'FunnelSans',
                                            color: Color(
                                                0xFF1877F2), // Lighter Blue
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Comment Input Field
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF4A628A)), // Border in Navy Blue
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          style: const TextStyle(
                            fontFamily: 'FunnelSans',
                            color: Color(0xFF1877F2), // Light Blue Text
                          ),
                          decoration: const InputDecoration(
                            hintText: "Write a comment...",
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send,
                            color: Color(0xFF4A628A)), // Send Icon in Navy Blue
                        onPressed: () {
                          if (commentController.text.trim().isNotEmpty) {
                            _addComment(postRef, commentController.text);
                            commentController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addComment(DocumentReference postRef, String comment) async {
    if (comment.trim().isEmpty) return;

    final User? user = _auth.currentUser;
    if (user == null) return;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    // Create a new comment object
    final newComment = {
      'userId': user.uid,
      'username': user.displayName ?? "Unknown User",
      'profilePic': user.photoURL ?? "",
      'comment': comment.trim(),
    };

    // Update the Firestore document
    await postRef.update({
      'comments': FieldValue.arrayUnion(
          [newComment]), // Add the comment object to the array
    });
  }
}
