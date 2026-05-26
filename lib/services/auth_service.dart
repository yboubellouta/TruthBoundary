import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // Stream of the currently logged-in AppUser (null if signed out)
  Stream<AppUser?> get userStream {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _fetchAppUser(firebaseUser.uid);
    });
  }

  Future<AppUser?> get currentUser async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return _fetchAppUser(firebaseUser.uid);
  }

  Future<AppUser?> _fetchAppUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<AppUser?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user?.uid;
    if (uid == null) return null;
    return _fetchAppUser(uid);
  }

  Future<void> signOut() => _auth.signOut();

  // Call this once to create the first admin account manually
  Future<void> createUser(String email, String password, UserRole role) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;
    final appUser = AppUser(uid: uid, email: email, role: role);
    await _db.collection('users').doc(uid).set(appUser.toFirestore());
  }
}
