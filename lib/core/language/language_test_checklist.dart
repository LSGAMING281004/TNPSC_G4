// Language Management Manual Test Checklist
// Run through these after every language-related change:
//
// CORE SWITCHING
// 1.  Settings → tap Tamil → bottom nav labels change to Tamil immediately ✓
// 2.  Settings → tap Tamil → open Mock Test → questions show in Tamil ✓
// 3.  Settings → tap English → open Mock Test → questions show in English ✓
// 4.  Settings → tap Both → open Mock Test → Tamil text above, English below ✓
// 5.  Both mode → check navigation bar is NOT bilingual (English only) ✓
// 6.  Tamil mode → check error messages are in Tamil ✓
// 7.  Switch language mid-conversation in AI chat → system prompt updates on next message ✓
// 8.  Kill app → reopen → language persists from Hive ✓
// 9.  Login on new device → language syncs from Firestore preferredLanguage field ✓
//
// TEST GUARD
// 10. Start mock test → language toggle in app bar is disabled (grayed out + tooltip) ✓
// 11. Submit test / exit test → language toggle re-enables ✓
//
// MISSING TRANSLATIONS
// 12. Question with empty questionTa → shows English with "Tamil translation pending" badge ✓
// 13. Question with empty questionEn → shows Tamil with "English translation pending" badge ✓
// 14. Both mode with one empty translation → shows available one without divider ✓
//
// ONBOARDING
// 15. Onboarding slide 0 → language selection visible before content slides ✓
// 16. Onboarding: tapping a language and "Continue" saves preference ✓
// 17. Remaining onboarding slides use chosen language ✓
//
// QUESTION BANK & REVIEW
// 18. Both mode in Question Bank → option tiles show Tamil above English ✓
// 19. QuestionCard shows correct/wrong coloring alongside bilingual text ✓
// 20. Explanation section in BilingualText shows Tamil + English stacked ✓
//
// ANALYTICS
// 21. Analytics charts: subject names change with mode (தமிழ் vs Tamil) ✓
// 22. Tamil mode → subjectTamil / subjectGS / subjectAptitude in Tamil ✓
//
// FONTS
// 23. Tamil mode → Noto Sans Tamil font applied to Tamil text ✓
// 24. English mode → system font (no Tamil font overhead) ✓
//
// KEYBOARD
// 25. Tamil mode + search TextField → info chip "தமிழ் அல்லது ஆங்கிலத்தில் தட்டச்சு செய்யலாம்" visible ✓
//
// AI ASSISTANT
// 26. Tamil mode → AI responds only in Tamil ✓
// 27. English mode → AI responds only in English ✓
// 28. Both mode → AI responds Tamil first, then "---", then English ✓
//
// SETTINGS PREVIEW
// 29. Settings language section → live preview card updates immediately on tap ✓
// 30. Settings language section → correct option is radio-selected visually ✓
