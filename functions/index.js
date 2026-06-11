const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const auth = admin.auth();

// ─────────────────────────────────────────────
// 1. Set Admin Role (callable by superAdmin)
// ─────────────────────────────────────────────
exports.setAdminRole = onCall(async (request) => {
  // Verify caller is superAdmin
  const callerUid = request.auth?.uid;
  if (!callerUid) throw new HttpsError("unauthenticated", "Not signed in.");

  const callerDoc = await db.collection("adminUsers").doc(callerUid).get();
  if (!callerDoc.exists || callerDoc.data().role !== "superAdmin") {
    throw new HttpsError("permission-denied", "Only superAdmin can assign roles.");
  }

  const { targetUid, role } = request.data;
  const validRoles = ["superAdmin", "contentAdmin", "viewer", "user"];
  if (!validRoles.includes(role)) {
    throw new HttpsError("invalid-argument", `Invalid role: ${role}`);
  }

  // Set custom claim
  await auth.setCustomUserClaims(targetUid, { admin: role !== "user", role });

  // Update/create adminUsers doc
  if (role === "user") {
    await db.collection("adminUsers").doc(targetUid).delete();
  } else {
    const user = await auth.getUser(targetUid);
    await db.collection("adminUsers").doc(targetUid).set({
      email: user.email,
      name: user.displayName || user.email?.split("@")[0] || "Admin",
      role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });
  }

  // Log
  await db.collection("admin_activity_log").add({
    adminUid: callerUid,
    action: `Set role '${role}' for user`,
    targetCollection: "adminUsers",
    targetId: targetUid,
    timestamp: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true, message: `Role '${role}' set for ${targetUid}` };
});

// ─────────────────────────────────────────────
// 2. Update analytics summary daily
// ─────────────────────────────────────────────
exports.updateAnalyticsSummary = onSchedule("every 24 hours", async () => {
  const [usersSnap, questionsSnap, testsSnap, materialsSnap, attemptsSnap] =
    await Promise.all([
      db.collection("users").count().get(),
      db.collection("questions").count().get(),
      db.collection("mock_tests").count().get(),
      db.collection("study_materials").count().get(),
      db.collection("test_attempts").count().get(),
    ]);

  // Count today's active users
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const activeSnap = await db.collection("users")
    .where("lastSeenAt", ">=", admin.firestore.Timestamp.fromDate(today))
    .count().get();

  await db.collection("analytics_summary").doc("daily").set({
    totalUsers: usersSnap.data().count,
    totalQuestions: questionsSnap.data().count,
    totalMockTests: testsSnap.data().count,
    totalMaterials: materialsSnap.data().count,
    totalAttempts: attemptsSnap.data().count,
    todayActiveUsers: activeSnap.data().count,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
});

// ─────────────────────────────────────────────
// 3. Auto-increment question count on creation
// ─────────────────────────────────────────────
exports.onQuestionCreated = onDocumentCreated(
  "questions/{questionId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    // Update subject metadata
    const subject = data.subject || "Unknown";
    await db.collection("metadata").doc("questionCounts").set(
      { [subject]: admin.firestore.FieldValue.increment(1) },
      { merge: true }
    );
  }
);

// ─────────────────────────────────────────────
// 4. Send FCM notification (Firestore triggered)
// ─────────────────────────────────────────────
exports.onNotificationCreated = onDocumentCreated(
  "notifications/{notifId}",
  async (event) => {
    const data = event.data?.data();
    if (!data || !data.title || !data.body) return;

    const topic = data.topic || "all_users";
    try {
      const result = await admin.messaging().send({
        topic,
        notification: { title: data.title, body: data.body },
        data: { type: "admin_notification", id: event.params.notifId },
      });

      await event.data.ref.update({
        status: "Delivered",
        fcmResponse: result,
      });
    } catch (err) {
      await event.data.ref.update({
        status: "Failed",
        error: err.message,
      });
    }
  }
);

// ─────────────────────────────────────────────
// 5. onTestAttemptCreated (Leaderboard, Achievements, Notification)
// ─────────────────────────────────────────────
exports.onTestAttemptCreated = onDocumentCreated(
  "test_attempts/{attemptId}",
  async (event) => {
    const data = event.data?.data();
    if (!data || !data.userId) return;

    const userId = data.userId;
    const score = data.score || 0;
    const testId = data.testId || "unknown";

    // 1. Update user document (avg score, streak, tests attempted)
    const userRef = db.collection("users").doc(userId);
    const userDoc = await userRef.get();
    
    let totalScore = score;
    let testsAttempted = 1;
    let streak = 1;
    let district = "Tamil Nadu";
    let userName = "Unknown";

    if (userDoc.exists) {
      const userData = userDoc.data();
      totalScore += userData.totalScore || 0;
      testsAttempted += userData.testsAttempted || 0;
      district = userData.district || district;
      userName = userData.name || userName;
      streak = userData.streak || 0;
      
      const lastTestDate = userData.lastTestDate ? userData.lastTestDate.toDate() : null;
      const today = new Date();
      if (lastTestDate && lastTestDate.getDate() === today.getDate() - 1) {
        streak += 1;
      } else if (!lastTestDate || lastTestDate.getDate() !== today.getDate()) {
        streak = 1; // Reset streak if missed a day
      }
    }
    
    const avgScore = testsAttempted > 0 ? totalScore / testsAttempted : 0;

    await userRef.set({
      totalScore,
      testsAttempted,
      avgScore,
      streak,
      lastTestDate: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    // 2. Achievements Check
    const achievements = [];
    if (testsAttempted === 1) achievements.push("first_test");
    if (score >= 90) achievements.push("score_90");
    if (streak === 7) achievements.push("streak_7");
    
    if (achievements.length > 0) {
      await db.collection("user_achievements").doc(userId).set({
        unlocked: admin.firestore.FieldValue.arrayUnion(...achievements),
        lastUnlockedAt: admin.firestore.FieldValue.serverTimestamp()
      }, { merge: true });
    }

    // 3. Update Leaderboard Entry
    const lbRef = db.collection("leaderboard").doc(userId);
    const lbDoc = await lbRef.get();
    let weeklyScore = score;
    if (lbDoc.exists) {
      weeklyScore += lbDoc.data().weeklyScore || 0;
    }

    await lbRef.set({
      userId,
      userName,
      photoUrl: userDoc.exists ? userDoc.data().photoUrl : null,
      district,
      totalScore,
      testsAttempted,
      avgScore,
      weeklyScore,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    // 4. Send Push Notification
    const token = userDoc.exists ? userDoc.data().fcmToken : null;
    if (token) {
      await admin.messaging().send({
        token,
        notification: { 
          title: "Test Completed! 🎯", 
          body: `Your result: ${score} — View detailed analysis` 
        },
        data: { type: "test_result", testId, attemptId: event.params.attemptId },
      });
    }
  }
);

// ─────────────────────────────────────────────
// 6. updateDailyLeaderboard (Cron: Midnight IST)
// ─────────────────────────────────────────────
exports.updateDailyLeaderboard = onSchedule({
  schedule: "30 18 * * *", // 18:30 UTC = 00:00 IST
  timeZone: "UTC"
}, async () => {
  const today = new Date();
  
  // If it's Monday (in IST, so Sunday 18:30 UTC), reset weekly scores
  // 18:30 UTC on Sunday is Monday 00:00 IST.
  if (today.getUTCDay() === 0) { 
    console.log("Resetting weekly leaderboard scores...");
    const lbSnap = await db.collection("leaderboard").get();
    const batch = db.batch();
    
    lbSnap.docs.forEach(doc => {
      batch.update(doc.ref, { weeklyScore: 0 });
    });
    
    await batch.commit();
  }
  
  // Recalculate top 100 ranks
  const top100 = await db.collection("leaderboard")
    .orderBy("weeklyScore", "desc")
    .limit(100)
    .get();
    
  const rankBatch = db.batch();
  top100.docs.forEach((doc, index) => {
    rankBatch.update(doc.ref, { rank: index + 1 });
  });
  
  await rankBatch.commit();
});

// ─────────────────────────────────────────────
// 7. sendDailyCurrentAffairs (Cron: 7 AM IST)
// ─────────────────────────────────────────────
exports.sendDailyCurrentAffairs = onSchedule({
  schedule: "30 1 * * *", // 01:30 UTC = 07:00 IST
  timeZone: "UTC"
}, async () => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  const caSnap = await db.collection("current_affairs")
    .where("date", ">=", today.toISOString())
    .limit(1)
    .get();
    
  if (!caSnap.empty) {
    const firstArticle = caSnap.docs[0].data();
    await admin.messaging().send({
      topic: "current_affairs",
      notification: { 
        title: "Today's Current Affairs | இன்றைய நடப்பு நிகழ்வுகள்", 
        body: `New articles available — ${firstArticle.titleEn}` 
      },
      data: { type: "current_affairs" },
    });
  }
});

// ─────────────────────────────────────────────
// 8. onUserCreated (Auth Trigger)
// ─────────────────────────────────────────────
const { beforeUserCreated } = require("firebase-functions/v2/identity");
exports.onUserCreated = beforeUserCreated(async (event) => {
  const user = event.data;
  
  // Note: Firestore writes in blocking triggers might delay sign-up, 
  // but we can also use standard background triggers. 
  // Using background approach instead to not block auth:
});

const { onUserCreated: backgroundUserCreated } = require("firebase-functions/v1/auth");
exports.onUserCreatedBackground = backgroundUserCreated().onUserCreated(async (user) => {
  await db.collection("users").doc(user.uid).set({
    email: user.email,
    name: user.displayName || "TNPSC Aspirant",
    photoUrl: user.photoURL || null,
    district: "Chennai", // Default
    streak: 0,
    testsAttempted: 0,
    totalScore: 0,
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  }, { merge: true });
  
  // Welcome Notification can be scheduled or sent directly if token exists (usually not present yet)
});

// ─────────────────────────────────────────────
// 9. cleanupOldConversations (Cron: Weekly Sunday Midnight IST)
// ─────────────────────────────────────────────
exports.cleanupOldConversations = onSchedule({
  schedule: "30 18 * * 0", // Sunday 18:30 UTC
  timeZone: "UTC"
}, async () => {
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
  
  const oldConvos = await db.collection("conversations")
    .where("updatedAt", "<", thirtyDaysAgo)
    .get();
    
  const batch = db.batch();
  oldConvos.docs.forEach(doc => batch.delete(doc.ref));
  await batch.commit();
  console.log(`Cleaned up ${oldConvos.size} old conversations.`);
});
