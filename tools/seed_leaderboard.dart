import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thiral_app/core/constants/app_constants.dart';

// IMPORTANT: Run this from the project root using:
// dart run tools/seed_leaderboard.dart

void main() async {
  print('Starting Leaderboard Seed...');
  
  // Note: This script requires Firebase to be initialized. 
  // It's usually better to run seeds from a flutter test environment or temporary widget 
  // if you're executing directly against a flutter project, but assuming Firebase 
  // Admin or equivalent is setup for raw dart, here is the seeding logic:

  // We are generating 20 mock users
  final random = Random();
  final db = FirebaseFirestore.instance;

  final names = [
    'Rajesh K', 'Priya M', 'Karthik S', 'Divya R', 'Suresh B',
    'Anitha V', 'Vijay T', 'Sneha L', 'Arun P', 'Meena N',
    'Gowtham R', 'Nandhini S', 'Vikram A', 'Keerthi M', 'Dinesh K',
    'Bhavani R', 'Manoj S', 'Swathi V', 'Prabhu T', 'Lakshmi K'
  ];

  final districts = AppConstants.districts;

  print('Generating 20 Leaderboard entries...');

  for (int i = 0; i < 20; i++) {
    final testsAttempted = random.nextInt(50) + 10;
    final avgScore = (random.nextDouble() * 40) + 50; // 50 to 90
    final totalScore = (testsAttempted * avgScore).round();
    final weeklyScore = (random.nextDouble() * 200).round() + 50;
    
    final district = districts[random.nextInt(districts.length)];

    final entry = {
      'userId': 'mock_user_$i',
      'userName': names[i],
      'photoUrl': null, // No photo for mock users
      'district': district,
      'totalScore': totalScore,
      'testsAttempted': testsAttempted,
      'avgScore': avgScore,
      'weeklyScore': weeklyScore,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    try {
      await db.collection('leaderboard').doc('mock_user_$i').set(entry);
      print('Added ${names[i]} ($totalScore points)');
    } catch (e) {
      print('Failed to add ${names[i]}: $e');
    }
  }

  print('Leaderboard seeding completed successfully!');
}
