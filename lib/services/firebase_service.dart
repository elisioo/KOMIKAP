import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/firebase_models.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // ==================== Authentication ====================

  Future<UserCredential?> registerUser(
      String email, String password, String username) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile
      await createUserProfile(
        uid: userCredential.user!.uid,
        username: username,
        email: email,
      );

      return userCredential;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<UserCredential?> loginUser(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // ==================== User Profile ====================

  Future<void> createUserProfile({
    required String uid,
    required String username,
    required String email,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'username': username,
        'email': email,
        'profileImageUrl': null,
        'bio': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'followersCount': 0,
        'followingCount': 0,
      });
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // ==================== Saved Manga ====================

  Future<void> saveManga({
    required String uid,
    required String mangaId,
    required String title,
    String? coverImageUrl,
  }) async {
    try {
      final id = const Uuid().v4();
      final now = DateTime.now();

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('savedManga')
          .doc(mangaId)
          .set({
        'id': id,
        'uid': uid,
        'mangaId': mangaId,
        'title': title,
        'coverImageUrl': coverImageUrl,
        'lastChapterRead': 0,
        'savedAt': now,
        'lastReadAt': now,
        'isFavorite': false,
      });
    } catch (e) {
      print('Error saving manga: $e');
      rethrow;
    }
  }

  Future<void> removeSavedManga(String uid, String mangaId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('savedManga')
          .doc(mangaId)
          .delete();
    } catch (e) {
      print('Error removing saved manga: $e');
      rethrow;
    }
  }

  Future<List<SavedManga>> getSavedManga(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('savedManga')
          .orderBy('lastReadAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SavedManga.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting saved manga: $e');
      return [];
    }
  }

  Future<List<SavedManga>> getFavoriteManga(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('savedManga')
          .where('isFavorite', isEqualTo: true)
          .orderBy('savedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SavedManga.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting favorite manga: $e');
      return [];
    }
  }

  Future<void> toggleFavoriteManga(
      String uid, String mangaId, bool isFavorite) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('savedManga')
          .doc(mangaId)
          .update({'isFavorite': isFavorite});
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }

  Future<void> updateLastChapterRead(
      String uid, String mangaId, int chapterNumber) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('savedManga')
          .doc(mangaId)
          .update({
        'lastChapterRead': chapterNumber,
        'lastReadAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last chapter read: $e');
      rethrow;
    }
  }

  // ==================== Posts ====================

  Future<String> createPost({
    required String uid,
    required String username,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final postId = const Uuid().v4();
      final now = DateTime.now();

      await _firestore.collection('posts').doc(postId).set({
        'id': postId,
        'uid': uid,
        'username': username,
        'userProfileImageUrl': null,
        'content': content,
        'imageUrl': imageUrl,
        'likesCount': 0,
        'commentsCount': 0,
        'createdAt': now,
        'updatedAt': now,
        'likedBy': [],
      });

      return postId;
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      // Also delete all comments
      final comments = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .get();
      for (var doc in comments.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  Future<List<Post>> getPosts({int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting posts: $e');
      return [];
    }
  }

  Future<List<Post>> getUserPosts(String uid, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Post.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting user posts: $e');
      return [];
    }
  }

  // ==================== Likes ====================

  Future<void> likePost(String postId, String uid) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      await postRef.update({
        'likesCount': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      print('Error liking post: $e');
      rethrow;
    }
  }

  Future<void> unlikePost(String postId, String uid) async {
    try {
      final postRef = _firestore.collection('posts').doc(postId);
      await postRef.update({
        'likesCount': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([uid]),
      });
    } catch (e) {
      print('Error unliking post: $e');
      rethrow;
    }
  }

  Future<void> likeComment(String postId, String commentId, String uid) async {
    try {
      final commentRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);

      await commentRef.update({
        'likesCount': FieldValue.increment(1),
        'likedBy': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      print('Error liking comment: $e');
      rethrow;
    }
  }

  Future<void> unlikeComment(
      String postId, String commentId, String uid) async {
    try {
      final commentRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);

      await commentRef.update({
        'likesCount': FieldValue.increment(-1),
        'likedBy': FieldValue.arrayRemove([uid]),
      });
    } catch (e) {
      print('Error unliking comment: $e');
      rethrow;
    }
  }

  // ==================== Comments ====================

  Future<String> addComment({
    required String postId,
    required String uid,
    required String username,
    required String content,
  }) async {
    try {
      final commentId = const Uuid().v4();
      final now = DateTime.now();

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .set({
        'id': commentId,
        'postId': postId,
        'uid': uid,
        'username': username,
        'userProfileImageUrl': null,
        'content': content,
        'likesCount': 0,
        'createdAt': now,
        'updatedAt': now,
        'likedBy': [],
      });

      // Update post comments count
      await _firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(1),
      });

      return commentId;
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      // Update post comments count
      await _firestore.collection('posts').doc(postId).update({
        'commentsCount': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }

  Future<List<Comment>> getComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Comment.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting comments: $e');
      return [];
    }
  }

  // ==================== File Upload ====================

  Future<String> uploadProfileImage(String uid, String imagePath) async {
    try {
      final ref = _storage.ref().child('users/$uid/profile.jpg');
      await ref.putFile(File(imagePath));
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile image: $e');
      rethrow;
    }
  }

  Future<String> uploadPostImage(String uid, String imagePath) async {
    try {
      final fileName = const Uuid().v4();
      final ref = _storage.ref().child('posts/$uid/$fileName.jpg');
      await ref.putFile(File(imagePath));
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading post image: $e');
      rethrow;
    }
  }
}
