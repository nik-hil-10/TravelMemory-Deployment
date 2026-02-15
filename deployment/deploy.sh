#!/bin/bash

# Update and Install Dependencies
sudo apt update && sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs nginx

# Install PM2 and Serve globally
sudo npm install -g pm2 serve

# Clone Repo (if not already done, or pull)
# git clone https://github.com/UnpredictablePrashant/TravelMemory.git
# cd TravelMemory

# Setup Backend
cd backend
npm install
# Note: You need to create .env manually with MONGO_URI
cd ..

# Setup Frontend
cd frontend
npm install
npm run build
cd ..

# Copy Nginx Config
sudo cp deployment/nginx.conf /etc/nginx/sites-available/travelmemory
sudo ln -s /etc/nginx/sites-available/travelmemory /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl restart nginx

# Start PM2
pm2 start deployment/ecosystem.config.js
pm2 save
pm2 startup
