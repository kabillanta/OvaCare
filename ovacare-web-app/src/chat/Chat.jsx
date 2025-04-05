import React, { useEffect, useState, useRef } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { db } from "../firebase/firebaseConfig"; // Ensure this path is correct
import { collection, addDoc, query, orderBy, onSnapshot, serverTimestamp } from "firebase/firestore";
import './Chat.css';

const Chat = () => {
	const [messages, setMessages] = useState([]);
	const [newMessage, setNewMessage] = useState("");
	const chatRef = useRef(null);
	const [user, setUser] = useState([]);
	const { patientId } = useParams(); // Get patient ID from URL params

	const navigate = useNavigate();

	// Fetch messages in real-time
	useEffect(() => {
		const chatCollection = collection(db, "chat");
		const q = query(chatCollection, orderBy("timestamp", "asc")); // Sort by time

		const unsubscribe = onSnapshot(q, (snapshot) => {
			setMessages(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));

			// Auto-scroll to the latest message
			if (chatRef.current) {
				setTimeout(() => {
					chatRef.current.scrollTop = chatRef.current.scrollHeight;
				}, 100);
			}
		});

		return () => unsubscribe(); // Cleanup on unmount
	}, []);

	// Send message to Firestore
	const sendMessage = async () => {
		if (!newMessage.trim()) return; // Prevent empty messages

		try {
			await addDoc(collection(db, "chat"), {
				text: newMessage,
				doctorId: user.uid,
				patientId,
				sender: "doctor",
				timestamp: serverTimestamp(),
			});
			setNewMessage(""); // Clear input field
		} catch (error) {
			console.error("Error sending message:", error);
		}
	};

	// Format timestamp to "DD MMM YYYY, HH:mm"
	const formatTimestamp = (timestamp) => {
		if (!timestamp) return "Sending...";
		const date = timestamp.toDate();
		return new Intl.DateTimeFormat("en-GB", {
			day: "2-digit",
			month: "short",
			year: "numeric",
			hour: "2-digit",
			minute: "2-digit",
		}).format(date);
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

	return (
		<div className="div-container">
			<center>
				<div className="chat-container">
					<div className="chat-box-container" ref={chatRef}>
						{messages.map((msg) => (
							<div key={msg.id} className="chat-message">
								<span className="message-sender">{msg.sender}</span><br />
								<span className="message-text">{msg.text}</span><br />
								<span className="message-time">{formatTimestamp(msg.timestamp)}</span>
							</div>
						))}
					</div>

					<div className="chat-input-container">
						<input
							type="text"
							placeholder="Type a message..."
							value={newMessage}
							onChange={(e) => setNewMessage(e.target.value)}
							onKeyPress={(e) => e.key === "Enter" && sendMessage()}
						/>
						<button onClick={sendMessage}>Send</button>
					</div>
				</div>
			</center>
			
		</div>
	);
};

export default Chat;
