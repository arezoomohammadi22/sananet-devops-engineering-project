const express = require("express");
const app = express();

const PORT = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.send(`Hello from Node.js app behind Nginx reverse proxy! 💚
Request came from: ${req.headers["x-forwarded-for"] || req.ip}
Host: ${req.headers["host"]}`);
});

app.get("/healthz", (req, res) => {
  res.status(200).send("OK");
});

app.listen(PORT, () => {
  console.log(`Node.js app listening on port ${PORT}`);
});

