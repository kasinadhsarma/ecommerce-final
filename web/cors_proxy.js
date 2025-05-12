# filepath: /home/kasinadhsarma/ecommerce-final/web/cors_proxy.js
// A simple CORS proxy for local development
const express = require('express');
const cors = require('cors');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();

// Enable CORS for all routes
app.use(cors());

// Proxy API requests
app.use('/api', createProxyMiddleware({
  target: 'https://your-backend-api-url.com',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '', // Remove the /api prefix when forwarding
  },
  onProxyRes: function (proxyRes) {
    proxyRes.headers['Access-Control-Allow-Origin'] = '*';
  }
}));

// Start the proxy server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`CORS Proxy running on port ${PORT}`);
});

// To use this proxy:
// 1. Install dependencies: npm install express cors http-proxy-middleware
// 2. Run this file: node cors_proxy.js
// 3. Make API requests to http://localhost:3000/api/your-endpoint
