# Travel Memory Deployment Guide (Amazon Linux 2023)

This guide details the steps to deploy the Travel Memory MERN application on an AWS **Amazon Linux 2023** instance. The deployment includes setting up the backend and frontend, configuring Nginx as a reverse proxy and load balancer, scaling the application with PM2, and connecting a custom domain via Cloudflare.

## Prerequisites
- An AWS Account.
- A Custom Domain (managed via Cloudflare).
- Basic familiarity with terminal/SSH.

---

## 1. AWS EC2 Instance Setup

### Step 1.1: Launch Instance
1.  Log in to the AWS Management Console and navigate to **EC2**.
2.  Click **Launch Instance**.
3.  **Name**: `TravelMemory-Server`
4.  **AMI**: Select **Amazon Linux 2023 AMI**.
5.  **Instance Type**: `t2.micro` (Free tier eligible) or `t3.micro`.
6.  **Key Pair**: Create a new key pair (e.g., `travel-memory-key`) and download the `.pem` file. **Keep this safe.**
7.  **Network Settings**:
    -   **Security Group**: Create a new security group.
    -   **Inbound Rules**:
        -   Allow **SSH** (Port 22) from `My IP` (for security).
        -   Allow **HTTP** (Port 80) from `Anywhere` (0.0.0.0/0).
        -   Allow **HTTPS** (Port 443) from `Anywhere` (0.0.0.0/0).
8.  **Storage**: Default (8GB gp3) is sufficient.
9.  Click **Launch Instance**.

### Step 1.2: Connect to Instance
Open your terminal (or Putty) and navigate to the folder with your key file.
```bash
chmod 400 travel-memory-key.pem  # Secure the key
ssh -i "travel-memory-key.pem" ec2-user@<EC2-Public-IP>
```

---

## 2. Server Environment Setup

Update package lists and install necessary tools: Node.js, Nginx, Git, PM2.

```bash
# Update System
sudo dnf update -y

# Install Node.js (via DNF)
sudo dnf install -y nodejs

# Install Nginx
sudo dnf install -y nginx

# Install Git
sudo dnf install -y git

# Verify installations
node -v
npm -v
nginx -v

# Install PM2 globally
sudo npm install -g pm2
sudo npm install -g serve
```

---

## 3. Application Deployment

### Step 3.1: Clone Repository
```bash
git clone https://github.com/nik-hil-10/TravelMemory-Deployment.git
cd TravelMemory-Deployment
```

### Step 3.2: Backend Configuration
1.  Navigate to backend:
    ```bash
    cd backend
    ```
2.  Install dependencies:
    ```bash
    npm install
    ```
3.  **Create `.env` file**:
    ```bash
    nano .env
    ```
    Content (Replace with your actual MongoDB connection string):
    ```env
    MONGO_URI=mongodb+srv://<username>:<password>@cluster0.abcde.mongodb.net/travelmemory
    PORT=3000
    ```
    *Note: Obtain connection string from MongoDB Atlas.*

### Step 3.3: Frontend Configuration
1.  Navigate to frontend:
    ```bash
    cd ../frontend
    ```
2.  Install dependencies:
    ```bash
    npm install
    ```
3.  **Update `url.js`**: Connect frontend to the backend load balancer (Nginx).
    ```bash
    nano src/url.js
    ```
    Content:
    ```javascript
    export const baseUrl = "https://nikhilappsstore.store/api"; 
    // Or whatever your custom domain is.
    ```
4.  Build the React app:
    ```bash
    npm run build
    ```

---

## 4. Scaling & Load Balancing (PM2 Setup)

We use PM2 to manage multiple instances of the backend and serve the frontend.

### Step 4.1: PM2 Ecosystem File
Create `ecosystem.config.js` in the root:

```javascript
module.exports = {
  apps: [
    {
      name: "backend-1",
      script: "./backend/index.js",
      env: { PORT: 3001 }
    },
    {
      name: "backend-2",
      script: "./backend/index.js",
      env: { PORT: 3002 }
    },
    {
      name: "frontend-1",
      script: "serve",
      env: {
        PM2_SERVE_PATH: './frontend/build',
        PM2_SERVE_PORT: 4000,
        PM2_SERVE_SPA: 'true'
      }
    },
    {
      name: "frontend-2",
      script: "serve",
      env: {
        PM2_SERVE_PATH: './frontend/build',
        PM2_SERVE_PORT: 4001,
        PM2_SERVE_SPA: 'true'
      }
    }
  ]
};
```

### Step 4.2: Start Processes
```bash
# Start all apps
pm2 start ecosystem.config.js

# Save configuration to restart on reboot
pm2 save
pm2 startup
```

---

## 5. Nginx Configuration (Reverse Proxy & Load Balancer)

Configure Nginx to act as the Gateway, Load Balancer, and Reverse Proxy.

### Step 5.1: Create Configuration
```bash
sudo nano /etc/nginx/conf.d/travelmemory.conf
```
*(Note: On Amazon Linux, we use `conf.d` instead of `sites-available`).*

**Content**:
```nginx
upstream backend_cluster {
    server 127.0.0.1:3001;
    server 127.0.0.1:3002;
}

upstream frontend_cluster {
    server 127.0.0.1:4000;
    server 127.0.0.1:4001;
}

server {
    listen 80;
    server_name nikhilappsstore.store;

    # Frontend Load Balancing
    location / {
        proxy_pass http://frontend_cluster;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API Load Balancing
    location /api/ {
        rewrite ^/api/(.*) /$1 break;
        proxy_pass http://backend_cluster;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Step 5.2: Adjust Default Nginx Config
Ensure `/etc/nginx/nginx.conf` does not conflict. (We comment out the default server block).

### Step 5.3: Restart Nginx
```bash
sudo systemctl enable nginx
sudo systemctl restart nginx
```

---

## 6. Domain Setup (Cloudflare)

1.  **Cloudflare DNS**:
    -   Add `A` record: `@` -> `EC2 Public IP` (Proxied).
    -   Add `CNAME` record: `www` -> `nikhilappsstore.store` (Proxied).
2.  **SSL**:
    -   Set **SSL/TLS encryption** mode to **Flexible** (Critical for EC2 HTTP communication).

---

## 7. Verification

1.  **Visit Site**: `https://nikhilappsstore.store`
2.  **Add Trip**: data is saved to MongoDB.
3.  **Check Logs**: `pm2 logs`
