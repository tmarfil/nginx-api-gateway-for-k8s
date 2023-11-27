const express = require("express");
const jwt = require("jsonwebtoken");
const app = express();
const port = 3000;

// Function to convert JSON to HTML
function jsonToHtml(json) {
  return Object.entries(json)
    .map(([key, value]) => {
      return `<span class="key">${key}</span>: <span class="value">${value}</span>`;
    })
    .join("<br>");
}

app.get("*", (req, res) => {
  // Capture all HTTP headers
  const headers = req.headers;

  // Check for JWT in the Authorization header
  let decodedTokenHtml = "";
  if (headers.authorization && headers.authorization.startsWith("Bearer ")) {
    const token = headers.authorization.split(" ")[1];
    try {
      const decoded = jwt.decode(token); // Decoding the JWT without verifying
      decodedTokenHtml = jsonToHtml(decoded);
    } catch (error) {
      decodedTokenHtml = '<span class="error">Invalid JWT</span>';
    }
  }

  // HTML for displaying the headers and JWT
  const html = `
    <html>
    <head>
    <style>
        body {
            font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
            background-color: #F5F5F5;
            color: #333;
        }
        .banner {
            background-color: #013C71; /* NGINX Green */
            color: #FFFFFF;
            padding: 10px;
            text-align: left;
        }
        .main {
            text-align: center;
        }
        .main h1 {
            font-size: 48px;
            font-weight: bold;
        }
        .jwt {
            background-color: #E6E6E6; /* Light Grey */
            color: #333; /* Dark Grey */
            padding: 10px;
            margin: 20px;
            border-radius: 4px;
        }
        .key {
            color: #8DC63F; /* Light Green for header names */
            font-weight: bold;
        }
        .value {
            color: #FFFFFF; /* White for header values */
        }
        .error {
            color: #FF0000; /* Red for errors */
        }
    </style>
</head>

    <body>
        <div class="banner">
            ${jsonToHtml(headers)}
        </div>
        <div class="jwt">
            <strong>Decoded JWT:</strong><br>
            {<br>
            ${decodedTokenHtml}<br>
            }
        </div>
        <div class="main">
            <h1 id="jobTitle">Loading...</h1>
        </div>
        <script>
            fetch('/get-job')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('jobTitle').innerText = data.job;
                })
                .catch(error => {
                    console.error('Error fetching job title:', error);
                    document.getElementById('jobTitle').innerText = 'Error fetching job title';
                });
        </script>
    </body>
    </html>`;

  res.send(html);
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
