import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/shared/models/current_affairs_model.dart';
// Note: Adjust import path for firebase_options.dart based on your setup.
import '../lib/firebase_options.dart';

/// Seed script to populate Firestore with 10 sample Current Affairs articles.
/// Run via: flutter run tools/seed_current_affairs.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;
  final collection = firestore.collection('current_affairs');

  print('Starting to seed 10 current affairs articles...');

  final articles = _generateSampleArticles();
  
  int count = 0;
  for (final a in articles) {
    await collection.doc(a.id).set(a.toMap());
    count++;
    print('Seeded ${a.titleEnglish} ($count/10)...');
  }

  print('Finished seeding $count current affairs articles successfully!');
}

List<CurrentAffairsModel> _generateSampleArticles() {
  final now = DateTime.now();
  
  return [
    CurrentAffairsModel(
      id: 'ca_001',
      titleTamil: 'தமிழ்நாடு அரசின் புதிய "முதலமைச்சர் திறன் மேம்பாட்டுத் திட்டம்" அறிமுகம்',
      titleEnglish: 'TN Govt Launches New "Chief Minister Skill Development Scheme"',
      contentTamil: 'தமிழ்நாடு முதலமைச்சர் புதிய திறன் மேம்பாட்டுத் திட்டத்தை தொடங்கி வைத்தார்.\nஇந்த திட்டம் 1 லட்சம் இளைஞர்களுக்கு வேலைவாய்ப்பை உருவாக்கும் நோக்கத்தில் அமைக்கப்பட்டுள்ளது.\nதொழில்நுட்பம் மற்றும் செயற்கை நுண்ணறிவு சார்ந்த பயிற்சிகள் இலவசமாக வழங்கப்படும்.',
      contentEnglish: 'The Tamil Nadu Chief Minister launched a new Skill Development Scheme.\nThis scheme aims to create employment opportunities for 1 lakh youth.\nTraining in technology and Artificial Intelligence will be provided free of cost.',
      category: 'TN_State',
      importance: 'high',
      publishedAt: now.subtract(const Duration(hours: 2)),
      tags: ['tn govt', 'schemes', 'employment'],
      hasQuiz: true,
    ),
    CurrentAffairsModel(
      id: 'ca_002',
      titleTamil: 'தேசிய அறிவியல் தினம் 2026: "நிலையான எதிர்காலத்திற்கான அறிவியல்"',
      titleEnglish: 'National Science Day 2026: "Science for a Sustainable Future"',
      contentTamil: 'சர் சி.வி. ராமன் ராமன் விளைவைக் கண்டுபிடித்ததை நினைவுகூரும் வகையில் தேசிய அறிவியல் தினம் கொண்டாடப்படுகிறது.\nஇந்த ஆண்டின் கருப்பொருள் "நிலையான எதிர்காலத்திற்கான அறிவியல்" என்பதாகும்.\nபள்ளி மற்றும் கல்லூரிகளில் பல்வேறு அறிவியல் கண்காட்சிகள் நடைபெற்றன.',
      contentEnglish: 'National Science Day is celebrated to commemorate the discovery of the Raman Effect by Sir C.V. Raman.\nThis year\'s theme is "Science for a Sustainable Future".\nVarious science exhibitions were held in schools and colleges.',
      category: 'Science',
      importance: 'medium',
      publishedAt: now.subtract(const Duration(days: 1)),
      tags: ['science day', 'national', 'cv raman'],
      hasQuiz: false,
    ),
    CurrentAffairsModel(
      id: 'ca_003',
      titleTamil: 'இஸ்ரோவின் ககன்யான் திட்டம்: விண்வெளி வீரர்கள் தேர்வு நிறைவு',
      titleEnglish: 'ISRO\'s Gaganyaan Mission: Astronaut Selection Completed',
      contentTamil: 'இந்தியாவின் முதல் மனித விண்வெளிப் பயணத் திட்டமான ககன்யானுக்கான விண்வெளி வீரர்கள் தேர்வு வெற்றிகரமாக நிறைவடைந்தது.\nநான்கு விமானப்படை விமானிகள் தேர்ந்தெடுக்கப்பட்டு அவர்களுக்கு ரஷ்யாவில் பயிற்சி அளிக்கப்பட்டு வருகிறது.\nஇந்த திட்டம் 2026 ஆம் ஆண்டின் இறுதியில் செயல்படுத்தப்படும் என இஸ்ரோ தெரிவித்துள்ளது.',
      contentEnglish: 'The astronaut selection for India\'s first human spaceflight mission, Gaganyaan, has been successfully completed.\nFour Air Force pilots have been selected and are undergoing training in Russia.\nISRO announced that the mission will be executed by the end of 2026.',
      category: 'Science',
      importance: 'high',
      publishedAt: now.subtract(const Duration(days: 2)),
      tags: ['isro', 'space', 'gaganyaan'],
      hasQuiz: true,
    ),
    CurrentAffairsModel(
      id: 'ca_004',
      titleTamil: 'மத்திய பட்ஜெட் 2026-27: கல்வி மற்றும் சுகாதாரத்திற்கு அதிக நிதி ஒதுக்கீடு',
      titleEnglish: 'Union Budget 2026-27: High Allocation for Education and Health',
      contentTamil: 'நிதி அமைச்சர் 2026-27 ஆம் ஆண்டிற்கான மத்திய பட்ஜெட்டை நாடாளுமன்றத்தில் தாக்கல் செய்தார்.\nஇந்த பட்ஜெட்டில் கல்வி மற்றும் சுகாதாரத் துறைகளுக்கு முன்னுரிமை அளிக்கப்பட்டுள்ளது.\nபுதிய எய்ம்ஸ் மருத்துவமனைகள் மற்றும் ஐஐடி கல்வி நிறுவனங்கள் அமைக்க நிதி ஒதுக்கப்பட்டுள்ளது.',
      contentEnglish: 'The Finance Minister presented the Union Budget for the year 2026-27 in the Parliament.\nPriority has been given to the education and health sectors in this budget.\nFunds have been allocated to establish new AIIMS hospitals and IIT educational institutions.',
      category: 'Economy',
      importance: 'high',
      publishedAt: now.subtract(const Duration(days: 5)),
      tags: ['budget', 'economy', 'national'],
      hasQuiz: true,
    ),
    CurrentAffairsModel(
      id: 'ca_005',
      titleTamil: 'சர்வதேச செஸ் சாம்பியன்ஷிப்: தமிழக வீரர் தங்கம் வென்றார்',
      titleEnglish: 'International Chess Championship: TN Player Wins Gold',
      contentTamil: 'ஜெர்மனியில் நடைபெற்ற சர்வதேச செஸ் சாம்பியன்ஷிப் போட்டியில் தமிழ்நாட்டைச் சேர்ந்த இளம் வீரர் தங்கம் வென்று சாதனை படைத்துள்ளார்.\nஇவர் உலகின் முதல் 10 செஸ் வீரர்களின் பட்டியலில் இடம்பிடித்துள்ளார்.\nமாநில அரசு இவருக்கு ஊக்கத்தொகை வழங்கி கவுரவித்துள்ளது.',
      contentEnglish: 'A young chess player from Tamil Nadu has achieved a milestone by winning gold at the International Chess Championship held in Germany.\nHe has secured a place in the list of the top 10 chess players in the world.\nThe state government has honored him by providing a cash incentive.',
      category: 'Sports',
      importance: 'medium',
      publishedAt: now.subtract(const Duration(days: 8)),
      tags: ['sports', 'chess', 'tamil nadu'],
      hasQuiz: false,
    ),
    CurrentAffairsModel(
      id: 'ca_006',
      titleTamil: 'தமிழ்நாடு அரசின் புதிய "மகளிர் உரிமைத் தொகை" விரிவாக்கம்',
      titleEnglish: 'Expansion of TN Govt\'s "Women\'s Basic Income Scheme"',
      contentTamil: 'தமிழ்நாடு அரசு கலைஞர் மகளிர் உரிமைத் திட்டத்தை மேலும் விரிவுபடுத்தியுள்ளது.\nஇதன் மூலம் மேலும் 10 லட்சம் பெண்கள் பயனடைவார்கள் என்று அறிவிக்கப்பட்டுள்ளது.\nஇந்த திட்டம் பெண்களின் பொருளாதார சுதந்திரத்தை மேம்படுத்தும் நோக்கில் செயல்படுத்தப்படுகிறது.',
      contentEnglish: 'The Tamil Nadu government has further expanded the Kalaignar Magalir Urimai Thittam (Women\'s Basic Income Scheme).\nIt has been announced that an additional 10 lakh women will benefit from this.\nThis scheme is implemented with the aim of improving the economic independence of women.',
      category: 'TN_State',
      importance: 'high',
      publishedAt: now.subtract(const Duration(days: 12)),
      tags: ['tn govt', 'women empowerment', 'schemes'],
      hasQuiz: true,
    ),
    CurrentAffairsModel(
      id: 'ca_007',
      titleTamil: 'உலக சுற்றுச்சூழல் தினம்: தமிழ்நாட்டில் 1 கோடி மரக்கன்றுகள் நடும் திட்டம்',
      titleEnglish: 'World Environment Day: 1 Crore Sapling Plantation Drive in TN',
      contentTamil: 'உலக சுற்றுச்சூழல் தினத்தை முன்னிட்டு, தமிழ்நாட்டில் 1 கோடி மரக்கன்றுகளை நடும் மாபெரும் திட்டம் தொடங்கப்பட்டுள்ளது.\nபள்ளி மாணவர்கள் மற்றும் தன்னார்வலர்கள் இந்த திட்டத்தில் பெருமளவில் பங்கேற்றுள்ளனர்.\nகாடுகளின் பரப்பளவை அதிகரிப்பதே இதன் முக்கிய நோக்கமாகும்.',
      contentEnglish: 'On the occasion of World Environment Day, a massive drive to plant 1 crore saplings has been launched in Tamil Nadu.\nSchool students and volunteers have participated in this drive in large numbers.\nThe main objective is to increase the forest cover.',
      category: 'TN_State',
      importance: 'medium',
      publishedAt: now.subtract(const Duration(days: 15)),
      tags: ['environment', 'tn state', 'nature'],
      hasQuiz: false,
    ),
    CurrentAffairsModel(
      id: 'ca_008',
      titleTamil: 'ஆசிய தடகளப் போட்டிகள்: தமிழக வீராங்கனை புதிய சாதனை',
      titleEnglish: 'Asian Athletics Championships: TN Athlete Sets New Record',
      contentTamil: 'ஜப்பானில் நடைபெறும் ஆசிய தடகளப் போட்டிகளில் நீளம் தாண்டுதலில் தமிழக வீராங்கனை புதிய ஆசிய சாதனை படைத்துள்ளார்.\nஇதன் மூலம் அவர் வரவிருக்கும் ஒலிம்பிக் போட்டிகளுக்கு தகுதி பெற்றுள்ளார்.\nதேசிய அளவிலான விளையாட்டுத் துறை அவருக்கு வாழ்த்துக்களைத் தெரிவித்துள்ளது.',
      contentEnglish: 'A female athlete from Tamil Nadu has set a new Asian record in long jump at the Asian Athletics Championships held in Japan.\nWith this, she has qualified for the upcoming Olympic Games.\nThe national sports fraternity has extended its congratulations to her.',
      category: 'Sports',
      importance: 'medium',
      publishedAt: now.subtract(const Duration(days: 18)),
      tags: ['sports', 'athletics', 'tamil nadu'],
      hasQuiz: true,
    ),
    CurrentAffairsModel(
      id: 'ca_009',
      titleTamil: 'புதிய தேசிய கல்விக் கொள்கை 2026: முக்கிய திருத்தங்கள் வெளியீடு',
      titleEnglish: 'New National Education Policy 2026: Key Amendments Released',
      contentTamil: 'மத்திய கல்வி அமைச்சகம் புதிய தேசிய கல்விக் கொள்கையில் சில முக்கிய திருத்தங்களை வெளியிட்டுள்ளது.\nதொழிற்கல்வி மற்றும் திறன் மேம்பாட்டிற்கு அதிக முக்கியத்துவம் அளிக்கப்பட்டுள்ளது.\nமாநில மொழிகளில் உயர்கல்வி கற்பதற்கான வாய்ப்புகள் அதிகரிக்கப்பட்டுள்ளன.',
      contentEnglish: 'The Union Ministry of Education has released some key amendments to the New National Education Policy.\nMore emphasis has been placed on vocational education and skill development.\nOpportunities for pursuing higher education in state languages have been increased.',
      category: 'National',
      importance: 'high',
      publishedAt: now.subtract(const Duration(days: 22)),
      tags: ['education', 'nep', 'national'],
      hasQuiz: true,
    ),
    CurrentAffairsModel(
      id: 'ca_010',
      titleTamil: 'ஜி20 உச்சி மாநாடு 2026: பொருளாதார வளர்ச்சிக்கான புதிய ஒப்பந்தங்கள்',
      titleEnglish: 'G20 Summit 2026: New Agreements for Economic Growth',
      contentTamil: 'இந்த ஆண்டு நடைபெற்ற ஜி20 உச்சி மாநாட்டில் உலகளாவிய பொருளாதார வளர்ச்சிக்கான புதிய ஒப்பந்தங்கள் கையெழுத்தாகின.\nகாலநிலை மாற்றம் மற்றும் டிஜிட்டல் பொருளாதாரம் குறித்து விரிவாக விவாதிக்கப்பட்டது.\nஇந்தியா இந்த மாநாட்டில் முக்கிய பங்காற்றியது.',
      contentEnglish: 'New agreements for global economic growth were signed at this year\'s G20 Summit.\nClimate change and the digital economy were discussed in detail.\nIndia played a key role in this summit.',
      category: 'International',
      importance: 'medium',
      publishedAt: now.subtract(const Duration(days: 28)),
      tags: ['g20', 'international', 'economy'],
      hasQuiz: false,
    ),
  ];
}
