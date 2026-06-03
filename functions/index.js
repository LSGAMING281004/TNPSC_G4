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
