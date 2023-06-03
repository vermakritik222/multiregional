const express = require("express");
const cors = require("cors");
const os = require("os");

require("dotenv").config();

const app = express();

// JSON Parser
app.use(express.json());

// cors
const corsOption = {
  credentials: true,
  origin: [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "https://fooddeliver-app2014.herokuapp.com",
  ],
};

app.use(cors(corsOption));

// Serving static files
app.use(express.static(`${__dirname}/public`));

app.get("/", (req, res) => {
  res.send("hello");
  //     res.sendFile('build/index.html', { root: __dirname });
});

app.get("/api/ip", async (req, res) => {
  const hostname = os.hostname();

  res.json({
    status: "Success",
    hostname,
  });

});

app.all("*", (req, res, next) => {
  res.send("<h1> Invalid Page </h1>")
});

const port = process.env.PORT || 8000;

app.listen(port, () => {
  console.log(`server is running on ${port} .......`);
});
