const express = require('express');
let eclecticJobs = require('./eclecticJobs'); // Changed to let for modification
const cors = require('cors');

const app = express();
const port = 3000; // You can choose any port

// Middleware to parse JSON bodies
app.use(express.json());

// POST route to append new jobs
app.post('/add-job', (req, res) => {
  const newJobs = req.body;
  if (Array.isArray(newJobs)) {
    eclecticJobs = eclecticJobs.concat(newJobs);
    res.status(200).json(eclecticJobs);
  } else {
    res.status(400).json({ error: "Invalid input, array expected" });
  }
});

app.get('/', (req, res) => {
  const randomIndex = Math.floor(Math.random() * eclecticJobs.length);
  const randomJob = eclecticJobs[randomIndex];
  res.json({ job: randomJob });
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});

