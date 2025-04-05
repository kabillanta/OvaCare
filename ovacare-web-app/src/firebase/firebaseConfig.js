// Import Firebase
import { initializeApp } from "firebase/app";
import { getAuth, GoogleAuthProvider, signInWithPopup, signOut } from "firebase/auth";
import { getFirestore, doc, setDoc } from "firebase/firestore";

const firebaseConfig = {
    apiKey: "AIzaSyBqOKgb9ikjHi9Dqd3q0DzL-1M1U6hiAqA",
    authDomain: "ovacare-64b6d.firebaseapp.com",
    projectId: "ovacare-64b6d",
    storageBucket: "ovacare-64b6d.firebasestorage.app",
    messagingSenderId: "1037568236918",
    appId: "1:1037568236918:web:1f35a12337c79dc6f0ae57",
    measurementId: "G-ZF80Q3ZZ36"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

const provider = new GoogleAuthProvider();

// Google Sign-In function
export const signInWithGoogle = async () => {
  try {
    const result = await signInWithPopup(auth, provider);
    const user = result.user;

    // Save user info to Firestore
    const userRef = doc(db, "doctor", user.uid);
    await setDoc(userRef, {
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      photoURL: user.photoURL
    }, { merge: true });

    return user;
  } catch (error) {
    console.error("Google Sign-In Error:", error);
  }
};

// Google Sign-Out function
export const logout = async () => {
  try {
    await signOut(auth);
  } catch (error) {
    console.error("Sign-Out Error:", error);
  }
};

export { db, auth };
