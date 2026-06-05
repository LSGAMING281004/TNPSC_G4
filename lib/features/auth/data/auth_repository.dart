import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../shared/models/user_model.dart';
import '../../../core/constants/app_constants.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> _createUserDocumentIfNeeded(User user, {String? name, bool isAnonymous = false}) async {
    final docRef = _firestore.collection(AppConstants.usersCollection).doc(user.uid);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      final userModel = UserModel(
        uid: user.uid,
        name: name ?? user.displayName ?? 'Scholar',
        email: user.email ?? '',
        photoUrl: user.photoURL,
        phoneNumber: user.phoneNumber,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isAnonymous: isAnonymous,
      );
      await docRef.set(userModel.toMap());
    } else {
      await docRef.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (cred.user != null) {
      await _createUserDocumentIfNeeded(cred.user!);
    }
    return cred;
  }

  Future<UserCredential> registerWithEmailPassword(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (cred.user != null) {
      await cred.user!.updateDisplayName(name);
      await _createUserDocumentIfNeeded(cred.user!, name: name);
    }
    return cred;
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user canceled

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final cred = await _auth.signInWithCredential(credential);
    if (cred.user != null) {
      await _createUserDocumentIfNeeded(cred.user!);
    }
    return cred;
  }

  Future<UserCredential> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    if (cred.user != null) {
      await _createUserDocumentIfNeeded(cred.user!, name: 'Guest User', isAnonymous: true);
    }
    return cred;
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      if (_googleSignIn.currentUser != null) _googleSignIn.signOut(),
    ]);
  }
}
