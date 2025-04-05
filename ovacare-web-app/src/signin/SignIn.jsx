// src/App.js
import React, { useState } from "react";
import { db, signInWithGoogle, logout } from "../firebase/firebaseConfig";
import { useNavigate } from "react-router-dom";
import { doc, setDoc } from "firebase/firestore";
import mainImage from "../assets/main.jpeg";

function SignIn() {
  const [user, setUser] = useState(null);
  const navigate = useNavigate();

  const handleSignIn = async () => {
    const userData = await signInWithGoogle();
    if (userData) {
      localStorage.setItem("user", JSON.stringify({
        uid: userData.uid,
        displayName: userData.displayName,
        email: userData.email,
        photoURL: userData.photoURL
      }));

      // Reference to the "doctor" collection with the user's UID as the document ID
        const doctorRef = doc(db, "doctor", userData.uid);

        // Store user details in Firestore (create or update)
        await setDoc(doctorRef, {
            name: userData.displayName,
            email: userData.email,
            photoURL: userData.photoURL,
            createdAt: new Date(), // Timestamp for tracking when the record was created
        }, { merge: false }); // "Merge: true" ensures existing data isn't overwritten

      setUser(userData);
      navigate("/dashboard"); // Navigate without passing state
    }
  };

  const handleLogout = async () => {
    await logout();
    localStorage.removeItem("user"); // Clear stored user data
    setUser(null);
    navigate("/"); // Redirect to sign-in
  };

  return (
    <div className="div-container">
        <center>
            <div style={{ marginTop: "20px"}}>
                {user ? (
                    <div>
                    <img src={user.photoURL} alt="User" width={50} />
                    <h2>Welcome, {user.displayName}</h2>
                    <button onClick={handleLogout}>Logout</button>
                    </div>
                ) : (
                    <>  
                        <div className="signin-form">
                            <p className="title"> Sign In</p><br />
                            <img src={mainImage} alt="Home Icon" width={300} height={300} style={{borderRadius: 20}}/><br /><br />
                            <button onClick={handleSignIn}>Sign in with Google</button>
                        </div>
                    </>
                )}
            </div>
        </center>
    </div>
  );
}

export default SignIn;
