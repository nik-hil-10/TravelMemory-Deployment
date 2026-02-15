# MongoDB Atlas Setup Guide

This guide covers getting your connection string and setting up the database for Travel Memory.

## Part 1: Get Connection String (As per your Screenshot)

1.  **Go to MongoDB Atlas** -> **Database** -> **Connect**.
2.  **Select Driver**:
    *   **Driver**: `Node.js` (Your screenshot showed "C# / .NET", change it to Node.js).
    *   **Version**: `5.5 or later` (or whatever is default).
3.  **Copy the Connection String**:
    *   It will look like: 
        `mongodb+srv://admin:<db_password>@cluster0.vrkxrs4.mongodb.net/?appName=Cluster0`
    *   **Note**: We will use the simplified version without the query parameters for your `.env`.

## Part 2: Configure Server (The Critical Step)

1.  **Connect to your EC2**:
    ```bash
    ssh -i "travel-memory-key.pem" ec2-user@13.126.92.45
    ```

2.  **Open the .env file**:
    ```bash
    nano backend/.env
    ```

3.  **Delete everything and Paste EXACTLY this**:
    (I have constructed this using the correct format for Mongoose and your specific cluster address).

    ```env
    MONGO_URI=mongodb+srv://<username>:<password>@cluster0.vrkxrs4.mongodb.net/travelmemory
    PORT=3000
    ```

4.  **Save and Exit**:
    *   Press `Ctrl+O`, then `Enter`.
    *   Press `Ctrl+X`.

5.  **Restart the App**:
    ```bash
    pm2 restart all
    ```

## Part 3: Required Collections

**Good news! You do NOT need to create collections manually.**
Mongoose (the library used in the backend) automatically creates the collection when the first document is saved.

*   **Database Name**: `travelmemory`
*   **Collection Name**: `tripdetails` (This is defined in your code `models/trip.model.js`).

**Just start the app and add a trip—MongoDB will do the rest!**
