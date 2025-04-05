import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Header from "./header/Header";
import Home from "./home/Home";
import Prescription from "./prescription/Prescription";
import History from "./history/History";
import SignIn from "./signin/SignIn";
import Chat from "./chat/Chat";

const App = () => {
  return (
    <>
      <Header />
      <Router>
        <Routes>
          <Route path="/" element={<SignIn />} />
          <Route path="/dashboard" element={<Home />} />
          <Route path="/login" element={<SignIn />} />
          <Route path="/prescription/:patientId" element={<Prescription />} />
          <Route path="/history/:patientId" element={<History />} />
          <Route path="/chat/:patientId" element={<Chat />} />
        </Routes>
      </Router>
    </>
  );
};

export default App;
