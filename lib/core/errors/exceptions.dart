/// Application error types with user-friendly messages
abstract class AppException implements Exception {
  final String message;
  final String messageTamil;
  final String? code;

  const AppException({
    required this.message,
    required this.messageTamil,
    this.code,
  });

  @override
  String toString() => message;
}

/// Server-side errors
class ServerException extends AppException {
  const ServerException({
    super.message = 'Server error occurred',
    super.messageTamil = 'சர்வர் பிழை ஏற்பட்டது',
    super.code,
  });
}

/// Network connectivity errors
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.messageTamil = 'இணைய இணைப்பு இல்லை',
    super.code,
  });
}

/// Local cache/storage errors
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error occurred',
    super.messageTamil = 'உள்ளூர் சேமிப்பு பிழை',
    super.code,
  });
}

/// Authentication errors
class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication failed',
    super.messageTamil = 'அங்கீகாரம் தோல்வியடைந்தது',
    super.code,
  });

  factory AuthException.invalidEmail() => const AuthException(
        message: 'Invalid email address',
        messageTamil: 'தவறான மின்னஞ்சல் முகவரி',
        code: 'invalid-email',
      );

  factory AuthException.wrongPassword() => const AuthException(
        message: 'Wrong password',
        messageTamil: 'தவறான கடவுச்சொல்',
        code: 'wrong-password',
      );

  factory AuthException.userNotFound() => const AuthException(
        message: 'User not found',
        messageTamil: 'பயனர் கிடைக்கவில்லை',
        code: 'user-not-found',
      );

  factory AuthException.emailInUse() => const AuthException(
        message: 'Email already in use',
        messageTamil: 'மின்னஞ்சல் ஏற்கனவே பயன்பாட்டில் உள்ளது',
        code: 'email-already-in-use',
      );

  factory AuthException.weakPassword() => const AuthException(
        message: 'Password is too weak',
        messageTamil: 'கடவுச்சொல் மிகவும் பலவீனமானது',
        code: 'weak-password',
      );

  factory AuthException.tooManyRequests() => const AuthException(
        message: 'Too many requests. Try again later.',
        messageTamil: 'அதிக கோரிக்கைகள். பின்னர் முயற்சிக்கவும்.',
        code: 'too-many-requests',
      );

  /// Map Firebase error codes to user-friendly messages
  factory AuthException.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return AuthException.invalidEmail();
      case 'wrong-password':
      case 'invalid-credential':
        return AuthException.wrongPassword();
      case 'user-not-found':
        return AuthException.userNotFound();
      case 'email-already-in-use':
        return AuthException.emailInUse();
      case 'weak-password':
        return AuthException.weakPassword();
      case 'too-many-requests':
        return AuthException.tooManyRequests();
      default:
        return AuthException(
          message: 'Authentication error: $code',
          messageTamil: 'அங்கீகாரப் பிழை: $code',
          code: code,
        );
    }
  }
}

/// Firestore errors
class FirestoreException extends AppException {
  const FirestoreException({
    super.message = 'Database error occurred',
    super.messageTamil = 'தரவுத்தள பிழை ஏற்பட்டது',
    super.code,
  });
}

/// Permission errors
class PermissionException extends AppException {
  const PermissionException({
    super.message = 'Permission denied',
    super.messageTamil = 'அனுமதி மறுக்கப்பட்டது',
    super.code,
  });
}

/// Generic failure class for use with Either pattern
class Failure {
  final String message;
  final String messageTamil;
  final String? code;

  const Failure({
    required this.message,
    required this.messageTamil,
    this.code,
  });

  factory Failure.fromException(AppException exception) {
    return Failure(
      message: exception.message,
      messageTamil: exception.messageTamil,
      code: exception.code,
    );
  }

  @override
  String toString() => message;
}
