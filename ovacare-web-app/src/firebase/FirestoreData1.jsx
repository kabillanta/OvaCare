import React, { useEffect, useState } from "react";
import { db } from "./firebaseConfig";
import { collection, getDocs } from "firebase/firestore";

const FirestoreData1 = () => {
  const [data, setData] = useState([]);
  const [count, setCount] = useState(0);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const querySnapshot = await getDocs(collection(db, "users")); // Change "users" if needed
        const items = querySnapshot.docs.map((doc) => ({
          id: doc.id,
          ...doc.data(),
        }));

        setData(items); // Store documents
        setCount(items.length); // Store count of documents
        setLoading(false);
      } catch (error) {
        console.error("Error fetching Firestore data:", error);
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  return (
    <div>
      <h2>Firestore Data</h2>
      <p><strong>Total Documents:</strong> {loading ? "Loading..." : count}</p>
      {loading ? (
        <p>Loading...</p>
      ) : data.length === 0 ? (
        <p>No data found.</p>
      ) : (
        data.map((doc) => (
          <div key={doc.id} style={{ border: "1px solid black", padding: "10px", margin: "10px" }}>
            <strong>Document ID:</strong> {doc.id} <br />
            {Object.entries(doc).map(([key, value]) =>
              key !== "id" ? (
                <div key={key}>
                  <strong>{key}:</strong> {JSON.stringify(value)}
                </div>
              ) : null
            )}
          </div>
        ))
      )}
    </div>
  );
};

export default FirestoreData1;
