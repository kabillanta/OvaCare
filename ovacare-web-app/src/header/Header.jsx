import React, { useEffect, useState } from "react";
import './Header.css'

const Header = () => {
  const [data, setData] = useState([]);

  return (
    <div className="header">
      <p>OvaCare Doctor</p>
    </div>
  );
};

export default Header;
