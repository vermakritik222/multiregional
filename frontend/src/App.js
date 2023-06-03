import logo from "./logo.svg";
import "./App.css";
import axios from "axios";
import { useEffect, useState } from "react";

function App() {
  const [data, setData] = useState("");
  const fetchData = async () => {
    console.log("api", process.env.REACT_APP_API_URL);
    const res = await axios.get(`${process.env.REACT_APP_API_URL}/api/ip`);
    console.log(res);
    setData(res?.data);
  };

  useEffect(() => {
    fetchData();
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <div style={{ color: "green" }}>
          Status: <span style={{ fontWeight: "bolder" }}>{data?.status}</span>
        </div>
        <div>ip: {data?.ipData?.ip}</div>
        <div>hostname: {data?.hostname}</div>
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <a
          className="App-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default App;
