const { initializeApp, cert } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const serviceAccount = require("./serviceAccountKey.json");

initializeApp({
  credential: cert(serviceAccount),
});

const targetUid = "hOpxY5eLTkUUmWOWIBsPAPcbx2y1";

async function setAdminRole(uid) {
  try {
    await getAuth().setCustomUserClaims(uid, { role: "admin" });
    console.log(`Berhasil! User dengan UID ${uid} sekarang adalah ADMIN.`);
  } catch (error) {
    console.error("Gagal mengatur custom claim:", error);
  }
}
setAdminRole(targetUid);
