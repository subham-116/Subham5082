# Use Node.js 18 base image
FROM node:18

# Set working directory
WORKDIR /usr/src/app

# Copy package.json and install dependencies
COPY package*.json ./
RUN npm install

# Copy rest of the app
COPY . .

# Make binaries executable (important!)
RUN chmod +x ./bin/*

# Expose the port used by the app
EXPOSE 3000

# Start the app
CMD ["node", "src/index.js"]
