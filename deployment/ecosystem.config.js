module.exports = {
    apps: [
        {
            name: "backend-1",
            cwd: "./backend",
            script: "index.js",
            env: {
                PORT: 3001,
                // MONGO_URI will be loaded from .env or system env
            }
        },
        {
            name: "backend-2",
            cwd: "./backend",
            script: "index.js",
            env: {
                PORT: 3002,
                // MONGO_URI will be loaded from .env or system env
            }
        },
        {
            name: "frontend-1",
            script: "serve",
            env: {
                PM2_SERVE_PATH: './frontend/build',
                PM2_SERVE_PORT: 4000,
                PM2_SERVE_SPA: 'true',
                PM2_SERVE_HOMEPAGE: '/index.html'
            }
        },
        {
            name: "frontend-2",
            script: "serve",
            env: {
                PM2_SERVE_PATH: './frontend/build',
                PM2_SERVE_PORT: 4001,
                PM2_SERVE_SPA: 'true',
                PM2_SERVE_HOMEPAGE: '/index.html'
            }
        }
    ]
};
