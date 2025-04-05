import React, { useEffect, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { db, logout } from "../firebase/firebaseConfig";
import { collection, getDocs } from "firebase/firestore";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faMessage, faNotesMedical, faHistory } from "@fortawesome/free-solid-svg-icons";
import "./Home.css"; // External CSS for styling

const Home = () => {
  const [data, setData] = useState([]);
  const [user, setUser] = useState([]);

  const navigate = useNavigate();
  const location = useLocation();

  const goToPrescription = (patientId) => {
    navigate(`/prescription/${patientId}`);
  };

  const goToHistory = (patientId) => {
    navigate(`/history/${patientId}`);
  };

  const goToChat = (patientId) => {
    navigate(`/chat/${patientId}`);
  };

  useEffect(() => {
    const fetchData = async () => {
      try {
        const usersCollection = collection(db, "users");
        const usersSnapshot = await getDocs(usersCollection);
        // console.log("Users:");
        // // Get the number of documents
        // const usersCount = usersSnapshot.size;

        // // Get each document's unique ID
        // const userIds = usersSnapshot.docs.map((doc) => doc.id);

        // console.log("Number of users:", usersCount);
        // console.log("User IDs:", userIds);

        const usersData = await Promise.all(
          usersSnapshot.docs.map(async (userDoc) => {
            const userData = { id: userDoc.id };

            // Fetch personal_details
            const personalDetailsRef = collection(db, "users", userDoc.id, "personal_details");
            const personalDetailsSnap = await getDocs(personalDetailsRef);
            const personalDetails = personalDetailsSnap.docs.map((doc) => doc.data());

            // Fetch profile
            const profileRef = collection(db, "users", userDoc.id, "profile");
            const profileSnap = await getDocs(profileRef);
            const profile = profileSnap.docs.map((doc) => doc.data());

            // Get username (prioritizing personal_details, then profile)
            const username =
              personalDetails.find((d) => d.username)?.username ||
              profile.find((d) => d.username)?.username ||
              "Unknown User";

            const profilePicture =
              personalDetails.find((d) => d.profilePicture)?.profilePicture ||
              profile.find((d) => d.profilePicture)?.profilePicture ||
              "Unknown Image";

            return {
              id: userDoc.id,
              username,
              personalDetails,
              profile,
              profilePicture
            };
          })
        );

        setData(usersData);
      } catch (error) {
        console.error("Error fetching Firestore data:", error);
      }
    };

    fetchData();
  }, []);

  // Load user data from localStorage on mount
  useEffect(() => {
    const storedUser = localStorage.getItem("user");
    if (storedUser) {
      setUser(JSON.parse(storedUser));
    } else {
      navigate("/"); // Redirect to sign-in if no user is found
    }
  }, [navigate]);

  const handleLogout = async () => {
    await logout();
    localStorage.removeItem("user"); // Remove user data
    navigate("/"); // Redirect to sign-in
  };

  return (
    <div className="div-container">

      {user ? (
        <div className="user-info">
          <img className="user-info-img" referrerPolicy="no-referrer" src={ user.photoURL } />
          <p className="title-medium">Welcome, {user.displayName}!</p>
          <p className="user-email">Email: {user.email}</p>
          <button className="logout-btn" onClick={handleLogout}>Logout</button>
        </div>
      ) : (
        <p>No user data found. Please sign in.</p>
      )}

      <br />

      <h2 className="title">Patients Details</h2><br />

      {data.length === 0 ? (
        <p>Loading...</p>
      ) : (
        <>
          {data.map((user) => (
            <div className="chat-box">
              <div key={user.id}>
                <div style={{ display: "flex"}}>
                  <div style={{flex: 1, padding: 10}}>
                    <img src={user.profilePicture} alt="Home Icon" className="profile-image" />
                  </div>
                  <div style={{flex: 6, marginLeft: 15}}>
                    <p className="username">{user.username}</p>
                    <p className="userid">User ID: {user.id}</p>
                  </div>
                </div>
                <div>
                  <center>
                    <button className="button" onClick={() => goToChat(user.id)}>
                      <FontAwesomeIcon icon={faMessage} /> Chat
                    </button>
                    <button className="button" onClick={() => goToPrescription(user.id)}>
                      <FontAwesomeIcon icon={faNotesMedical} /> Prescription
                    </button>
                    <button className="button" onClick={() => goToHistory(user.id)}>
                      <FontAwesomeIcon icon={faHistory} /> History
                    </button>
                  </center>
                </div>
              </div>
            </div>
          ))}
        </>
      )}
    </div>
  );
};

export default Home;
