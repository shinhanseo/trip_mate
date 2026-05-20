import admin from "firebase-admin";
import fs from "node:fs";
import path from "node:path";

function getServiceAccount() {
  const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;

  if (!serviceAccountPath) {
    throw new Error("FIREBASE_SERVICE_ACCOUNT_PATH is not set");
  }

  const resolvedPath = path.resolve(process.cwd(), serviceAccountPath);
  const raw = fs.readFileSync(resolvedPath, "utf8");

  return JSON.parse(raw);
}

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(getServiceAccount()),
  });
}

export const firebaseMessaging = admin.messaging();