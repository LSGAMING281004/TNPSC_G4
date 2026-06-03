import 'package:cloud_firestore/cloud_firestore.dart';

/// Admin user model stored in Firestore adminUsers/{uid}.
class AdminUserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // superAdmin | contentAdmin | viewer
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  const AdminUserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.lastLoginAt,
    this.createdAt,
  });

  bool get isSuperAdmin => role == 'superAdmin';
  bool get isContentAdmin => role == 'contentAdmin';
  bool get isViewer => role == 'viewer';
  bool get canWrite => isSuperAdmin || isContentAdmin;

  factory AdminUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'viewer',
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'lastLoginAt': lastLoginAt != null
          ? Timestamp.fromDate(lastLoginAt!)
          : FieldValue.serverTimestamp(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  AdminUserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    DateTime? lastLoginAt,
    DateTime? createdAt,
  }) {
    return AdminUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
