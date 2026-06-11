import os
import json
import re

# Old keys from app_strings.dart
old_keys = [
    "appName", "appFullName", "appTagline", "welcomeTo", "loading", "error", "retry", "cancel", "confirm",
    "save", "edit", "delete", "search", "noData", "noInternet", "unknownError", "success", "submit", "next",
    "back", "close", "share", "download", "viewAll", "seeMore", "by", "points", "rank", "accuracy", "questions",
    "minutes", "seconds", "hours", "days", "streak", "badge", "premium", "tryAgain", "goBack", "comingSoon", "optional",
    "login", "register", "logout", "email", "password", "confirmPassword", "name", "district", "forgotPassword",
    "sendOtp", "verifyOtp", "orContinueWith", "googleSignIn", "guestLogin", "alreadyAccount", "noAccount",
    "signUp", "targetScore", "welcomeBack", "createAccount", "resetPassword", "passwordChanged", "invalidEmail",
    "weakPassword", "emailNotFound", "wrongPassword", "networkError", "skip", "getStarted", "onboardTitle1",
    "onboardSub1", "onboardTitle2", "onboardSub2", "onboardTitle3", "onboardSub3", "onboardTitle4", "onboardSub4",
    "home", "goodMorning", "goodAfternoon", "goodEvening", "examIn", "daysLeft", "hoursLeft", "dailyGoal",
    "questionsToday", "studyStreak", "streakDays", "weeklyProgress", "yourProgress", "continueStudying",
    "quickActions", "todayCurrentAffairs", "weakSubjects", "practiceMore", "homeTab", "testsTab", "materialsTab",
    "analyticsTab", "profileTab", "mockTests", "startTest", "fullMock", "subjectTest", "chapterTest",
    "dailyChallenge", "testInstructions", "questionsCount", "duration", "difficulty", "startNow", "language",
    "previous", "submitTest", "confirmSubmit", "markForReview", "clearResponse", "questionPalette", "answered",
    "unanswered", "markedForReview", "timeLeft", "autoSubmit", "testResult", "yourScore", "correct", "wrong",
    "unattempted", "percentage", "viewSolutions", "retake", "nextTest", "timeAnalysis", "avgTimePerQuestion",
    "strongSubjects", "weakSubjectsResult", "explanation", "reportError", "correctAnswer", "yourAnswer",
    "questionBank", "filter", "subject", "chapter", "topic", "difficultyLevel", "easy", "medium", "hard",
    "searchQuestions", "bookmarkAdded", "bookmarkRemoved", "myBookmarks", "revealAnswer", "practiceSimilar",
    "noQuestionsFound", "allSubjects", "studyMaterials", "downloadPdf", "pdfDownloaded", "openPdf",
    "bookmarkPage", "shareNote", "downloadedMaterials", "storageUsed", "deleteDownload", "viewOnline",
    "materialNotFound", "currentAffairs", "daily", "monthly", "weeklyQuiz", "searchNews", "readMore", "source",
    "publishedOn", "quizStart", "quizResult", "noArticles", "analytics", "overview", "subjectPerformance",
    "testHistory", "tips", "totalAttempted", "avgAccuracy", "totalTime", "bestScore", "weakestSubject",
    "strongestSubject", "improvementTip", "studyStreakLabel", "noDataYet", "loadingChart", "leaderboard",
    "stateRank", "districtRank", "friendsRank", "weeklyRank", "yourRank", "noLeaderboard", "aiAssistant",
    "typeMessage", "askTnpsc", "suggestedQuestions", "thinking", "tapToAsk", "clearChat", "profile",
    "editProfile", "myAchievements", "examReadiness", "targetScoreLabel", "studyProgress", "allBadges",
    "locked", "unlocked", "settings", "appLanguage", "darkMode", "notifications", "dailyReminder", "clearCache",
    "privacyPolicy", "terms", "deleteAccount", "version", "premiumBadge", "subjectTamil", "subjectGS",
    "subjectAptitude", "fieldRequired", "passwordTooShort", "passwordMismatch", "downloadFailed",
    "uploadFailed", "testLoadFailed", "questionsFailed", "sessionExpired", "noInternetMsg", "serverError"
]

mapping = {}
for k in old_keys:
    mapping[k] = k # keep exact key name to avoid breaking the app logic, but populate ARB

arb_en = { "@@locale": "en" }
arb_ta = { "@@locale": "ta" }

# Some explicit overrides from user prompt
arb_en["appName"] = "Thiral"
arb_ta["appName"] = "திரல்"

arb_en["loginTitle"] = "Welcome Back"
arb_ta["loginTitle"] = "மீண்டும் வரவேற்கிறோம்"

arb_en["loginSubtitle"] = "Your TNPSC journey continues"
arb_ta["loginSubtitle"] = "உங்கள் TNPSC பயணம் தொடர்கிறது"

arb_en["loginEmailHint"] = "Email Address"
arb_ta["loginEmailHint"] = "மின்னஞ்சல் முகவரி"

arb_en["loginPasswordHint"] = "Password"
arb_ta["loginPasswordHint"] = "கடவுச்சொல்"

arb_en["loginButton"] = "Login"
arb_ta["loginButton"] = "உள்நுழை"

arb_en["loginGoogleButton"] = "Continue with Google"
arb_ta["loginGoogleButton"] = "Google மூலம் தொடரவும்"

arb_en["loginGuestButton"] = "Continue as Guest"
arb_ta["loginGuestButton"] = "விருந்தினராக தொடரவும்"

arb_en["dashboardExamCountdown"] = "{days} days to exam"
arb_ta["dashboardExamCountdown"] = "தேர்வுக்கு {days} நாட்கள் உள்ளன"
arb_en["@dashboardExamCountdown"] = {
  "placeholders": { "days": { "type": "int" } }
}
arb_ta["@dashboardExamCountdown"] = {
  "placeholders": { "days": { "type": "int" } }
}

arb_en["dashboardDailyTarget"] = "Today's Target: {count} Questions"
arb_ta["dashboardDailyTarget"] = "இன்றைய இலக்கு: {count} கேள்விகள்"
arb_en["@dashboardDailyTarget"] = {
  "placeholders": { "count": { "type": "int" } }
}
arb_ta["@dashboardDailyTarget"] = {
  "placeholders": { "count": { "type": "int" } }
}

arb_en["dashboardStreak"] = "🔥 {days} Day Streak"
arb_ta["dashboardStreak"] = "🔥 {days} நாள் தொடர்ச்சி"
arb_en["@dashboardStreak"] = {
  "placeholders": { "days": { "type": "int" } }
}
arb_ta["@dashboardStreak"] = {
  "placeholders": { "days": { "type": "int" } }
}


# Simple generation for the rest
import re
def camel_to_title(name):
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1 \2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1 \2', s1).title()

for key in old_keys:
    if key not in arb_en:
        arb_en[key] = camel_to_title(key)
    if key not in arb_ta:
        arb_ta[key] = camel_to_title(key) + " (Tamil)"

# Ensure directory exists
os.makedirs('lib/l10n', exist_ok=True)

with open('lib/l10n/app_en.arb', 'w', encoding='utf-8') as f:
    json.dump(arb_en, f, indent=2, ensure_ascii=False)

with open('lib/l10n/app_ta.arb', 'w', encoding='utf-8') as f:
    json.dump(arb_ta, f, indent=2, ensure_ascii=False)

# Now iterate all dart files and replace
def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as file:
        content = file.read()
    
    new_content = content
    # Replace context.s.key with context.l10n.key
    # Also replace variable `s.` with `l10n.` if declared as `final s = context.s;`
    new_content = new_content.replace('context.s', 'context.l10n')
    new_content = new_content.replace('final s = context.s', 'final l10n = context.l10n')
    new_content = new_content.replace(' s.', ' l10n.')
    new_content = new_content.replace('(s.', '(l10n.')
    new_content = new_content.replace('{s.', '{l10n.')

    # Edge cases for old AppStrings provider usage
    new_content = new_content.replace('ref.read(appStringsProvider)', 'AppLocalizations.of(context)!')

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as file:
            file.write(new_content)

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

print("Migration completed.")
