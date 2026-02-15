#!/bin/bash

# Update System
sudo dnf update -y

# Install Node.js, Nginx, Git
sudo dnf install -y nodejs nginx git

# Install PM2 and Serve globally
sudo npm install -g pm2 serve

# Start Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Clone Repo (if not already done)
# git clone https://github.com/UnpredictablePrashant/TravelMemory.git
# cd TravelMemory

# Setup Backend
cd backend
npm install
# Note: Ensure .env exists
cd ..

# Setup Frontend
cd frontend
npm install
npm run build
cd ..

# Copy Nginx Config for Amazon Linux (uses conf.d instead of sites-enabled)
# We assume nginx.conf is in the deployment folder
sudo cp deployment/nginx.conf /etc/nginx/conf.d/travelmemory.conf

# Restart Nginx to apply changes
sudo systemctl restart nginx

# Start PM2
pm2 start deployment/ecosystem.config.js
pm2 save
pm2 startup
