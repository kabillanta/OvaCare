import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { db, logout } from "../firebase/firebaseConfig";
import { collection, addDoc } from "firebase/firestore";
import "./Prescription.css"; // Import CSS file

const Prescription = () => {
  const [prescription, setPrescription] = useState("");
  const [appointmentDate, setAppointmentDate] = useState("");
  const [medicines, setMedicines] = useState([{ name: "", quantity: "" }]); // Dynamic fields
  const { patientId } = useParams(); // Get patient ID from URL params
  const [user, setUser] = useState([]);

  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!prescription || !appointmentDate || medicines.some(med => !med.name || !med.quantity)) {
      alert("Please enter all fields correctly.");
      return;
    }

    try {
      // Reference to the "doctor_chat" subcollection under the specified patient
      const medicationsRef = collection(db, "medications");

      // Add a new document inside "doctor_chat"
      await addDoc(medicationsRef, {
        doctorId: user.uid, // Use the doctor's UID
        patientId, // Use the patient's ID from the URL
        prescription,
        appointmentDate,
        medicines, // Store medicines array inside the same document
        timestamp: new Date(),
      });

      alert("Prescription, appointment, and medicines added successfully!");
      setPrescription("");
      setAppointmentDate("");
      setMedicines([{ name: "", quantity: "" }]); // Reset medicine fields
    } catch (error) {
      console.error("Error adding prescription:", error);
    }
  };

  // Add a new medicine field
  const addMedicineField = () => {
    setMedicines([...medicines, { name: "", quantity: "" }]);
  };

  // Remove a medicine field
  const removeMedicineField = (index) => {
    if (medicines.length > 1) {
      setMedicines(medicines.filter((_, i) => i !== index));
    }
  };

  // Handle input change for medicines
  const handleMedicineChange = (index, field, value) => {
    const updatedMedicines = medicines.map((med, i) =>
      i === index ? { ...med, [field]: value } : med
    );
    setMedicines(updatedMedicines);
  };

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
          <img className="user-info-img" src={user.photoURL} alt="Profile" />
          <p className="title-medium">Welcome, {user.displayName}!</p>
          <p className="user-email">Email: {user.email}</p>
          <button className="logout-btn" onClick={handleLogout}>Logout</button>
        </div>
      ) : (
        <p>No user data found. Please sign in.</p>
      )}

      <br />

      <div className="user-details-form" >
        <h2 className="chat-title">Add Doctor Prescription</h2>
        <form onSubmit={handleSubmit} className="chat-form">
          <center>
            <label>Prescription:</label><br />
            <textarea
              className="chat-textarea"
              placeholder="Enter prescription"
              value={prescription}
              onChange={(e) => setPrescription(e.target.value)}
              required
            /><br /><br />
            
            <label>Next Appointment Date:</label><br />
            <input
              type="date"
              className="chat-input"
              value={appointmentDate}
              onChange={(e) => setAppointmentDate(e.target.value)}
              required
            /><br /><br />

            <label>Medicines & Quantity:</label><br />
            <div className="medicines-div">
              {medicines.map((medicine, index) => (
                <div key={index} className="medicine-row">
                  <input
                    type="text"
                    placeholder="Medicine Name"
                    className="chat-input medicine-input"
                    value={medicine.name}
                    onChange={(e) => handleMedicineChange(index, "name", e.target.value)}
                    required
                  /><br />
                  <input
                    type="number"
                    placeholder="Quantity"
                    className="chat-input medicine-input"
                    value={medicine.quantity}
                    onChange={(e) => handleMedicineChange(index, "quantity", e.target.value)}
                    required
                  /><br />
                  <button type="button" className="remove-button" onClick={() => removeMedicineField(index)}>✖</button><br />
                </div>
              ))}
            </div><br />
            <button type="button" className="add-button" onClick={addMedicineField}>+ Add Medicine</button><br /><br />
            <button type="submit" className="chat-button">Save</button>
          </center>
        </form>
      </div>

      
    </div>
  );
};

export default Prescription;
