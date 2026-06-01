import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/models/user_model.dart';

/// Auth repository interface
abstract class AuthRepository {
  Future<UserModel> signInWithEmail({required String email, required String password});
  Future<UserModel> signUpWithEmail({required String name, required String email, required String password, String district, int targetScore});
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInAsGuest();
  Future<void> signOut();
  Future<void> resetPassword({required String email});
  Future<UserModel?> getCurrentUser();
  Stream<User?> get authStateChanges;
}

/// Firebase implementation of AuthRepository
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<UserModel> signInWithEmail({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user!;
      await _updateLastLogin(user.uid);
      return await _getUserFromFirestore(user.uid) ?? _createUserModel(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    } catch (e) {
      throw AuthException(message: e.toString(), messageTamil: 'உள்நுழைவு தோல்வி');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String name, required String email, required String password,
    String district = '', int targetScore = 150,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user!;
      await user.updateDisplayName(name);

      final userModel = UserModel(
        uid: user.uid, name: name, email: email,
        district: district, targetScore: targetScore,
        createdAt: DateTime.now(), lastLoginAt: DateTime.now(),
      );

      await _firestore.collection(AppConstants.usersCollection)
          .doc(user.uid).set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    } catch (e) {
      throw AuthException(message: e.toString(), messageTamil: 'பதிவு தோல்வி');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException(message: 'Google sign-in cancelled', messageTamil: 'Google உள்நுழைவு ரத்து');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Check if user exists in Firestore
      final existingUser = await _getUserFromFirestore(user.uid);
      if (existingUser != null) {
        await _updateLastLogin(user.uid);
        return existingUser;
      }

      // Create new user
      final userModel = UserModel(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        photoURL: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore.collection(AppConstants.usersCollection)
          .doc(user.uid).set(userModel.toFirestore());
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: e.toString(), messageTamil: 'Google உள்நுழைவு தோல்வி');
    }
  }

  @override
  Future<UserModel> signInAsGuest() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user!;
      final userModel = UserModel(
        uid: user.uid, name: 'Guest', email: '',
        createdAt: DateTime.now(), lastLoginAt: DateTime.now(),
      );
      await _firestore.collection(AppConstants.usersCollection)
          .doc(user.uid).set(userModel.toFirestore());
      return userModel;
    } catch (e) {
      throw AuthException(message: e.toString(), messageTamil: 'விருந்தினர் உள்நுழைவு தோல்வி');
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromCode(e.code);
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _getUserFromFirestore(user.uid);
  }

  Future<UserModel?> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  UserModel _createUserModel(User user) => UserModel(
    uid: user.uid, name: user.displayName ?? '',
    email: user.email ?? '', photoURL: user.photoURL,
    createdAt: DateTime.now(), lastLoginAt: DateTime.now(),
  );
}
