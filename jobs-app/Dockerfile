# Use an official Node.js runtime as a parent image
FROM node:21

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (or yarn.lock) into the working directory
COPY package*.json ./

# Install any dependencies
RUN npm install

# Bundle your app's source code inside the Docker image
COPY . .

# Make your server port available to the world outside this container
EXPOSE 3000

# Define the command to run your app (This should match how you start your server)
CMD [ "node", "server.js" ]

