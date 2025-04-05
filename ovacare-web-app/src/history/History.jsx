import React, { useEffect, useState } from "react";
import { useLocation, useNavigate, useParams } from "react-router-dom";
import { db, logout } from "../firebase/firebaseConfig";
import { collection, getDocs } from "firebase/firestore";
import "./History.css"; 

const History = () => {
  const [data, setData] = useState([]);
  const [user, setUser] = useState(null);
  const [patientDetails, setPatientDetails] = useState({ username: "Unknown User" });
  const { patientId } = useParams();
  const navigate = useNavigate();

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Fetch medications for the specific patient only
        const medicationsCollection = collection(db, "medications");
        const medicationsSnapshot = await getDocs(medicationsCollection);
        const medicationsData = medicationsSnapshot.docs
          .map((doc) => ({ id: doc.id, ...doc.data() }))
          .filter((medication) => medication.patientId === patientId);

        setData(medicationsData);
      } catch (error) {
        console.error("Error fetching medications data:", error);
      }
    };

    const fetchUserDetails = async () => {
      try {
        if (!patientId) return;
        const personalDetailsRef = collection(db, "users", patientId, "personal_details");
        const personalDetailsSnap = await getDocs(personalDetailsRef);
        const personalDetails = personalDetailsSnap.docs.map((doc) => doc.data());

        const profileRef = collection(db, "users", patientId, "profile");
        const profileSnap = await getDocs(profileRef);
        const profile = profileSnap.docs.map((doc) => doc.data());

        const username =
          personalDetails.find((d) => d.username)?.username ||
          profile.find((d) => d.username)?.username ||
          "Unknown User";

        setPatientDetails({ username });
      } catch (error) {
        console.error("Error fetching user details:", error);
      }
    };

    fetchData();
    fetchUserDetails();
  }, [patientId]); // Added dependency

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
    localStorage.removeItem("user");
    navigate("/");
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return new Intl.DateTimeFormat("en-GB", { day: "2-digit", month: "short", year: "numeric" }).format(date);
  };

  return (
    <div className="div-container">
      {user ? (
        <div className="user-info">
          <img className="user-info-img" referrerPolicy="no-referrer" src={user.photoURL} alt="User" />
          <p className="title-medium">Welcome, {user.displayName}!</p>
          <p className="user-email">Email: {user.email}</p>
          <button className="logout-btn" onClick={handleLogout}>Logout</button>
        </div>
      ) : (
        <p>No user data found. Please sign in.</p>
      )}

      <br />

      <h2 className="title">Patient History</h2><br />

      {data.length === 0 ? (
        <p>Loading...</p>
      ) : (
        data.map((medication) => (
          <div className="chat-box" key={medication.id}>
            <p className="div-title">Prescription: {medication.prescription}</p>
            <div className="div-pairs">
              <div className="div-key">Appointment Date:</div>
              <div className="div-value">{formatDate(medication.appointmentDate)}</div>
            </div>
            <div className="div-pairs">
              <div className="div-key">Patient Name:</div>
              <div className="div-value">{patientDetails.username}</div>
            </div>
            <div className="div-pairs">
              <div className="div-key">Doctor Name:</div>
              <div className="div-value">{user?.displayName}</div>
            </div>
            <div className="div-pairs">
              <div className="div-key">Medicines</div>
              <div className="div-key">
                {medication.medicines.map((med, index) => (
                  <div key={index}>
                    <strong>{med.name}</strong> | Quantity: <b>{med.quantity}</b>
                  </div>
                ))}
              </div>
            </div>
            <div className="div-pairs">
              <div className="div-key">Prescription Date:</div>
              <div className="div-value">{medication.timestamp ? new Intl.DateTimeFormat("en-GB", { day: "2-digit", month: "short", year: "numeric" }).format(medication.timestamp.toDate()) : "N/A"}</div>
            </div>
          </div>
        ))
      )}
    </div>
  );
};

export default History;
