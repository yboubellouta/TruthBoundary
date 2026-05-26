import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, user }

class AppUser {
  final String uid;
  final String email;
  final UserRole role;

  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == UserRole.admin;

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.user,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role == UserRole.admin ? 'admin' : 'user',
    };
  }
}
