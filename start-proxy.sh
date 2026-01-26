#!/bin/bash
echo "🚀 Starting CORS Proxy Server..."
echo ""
echo "Installing dependencies (if needed)..."
npm install express http-proxy-middleware cors --save-dev 2>/dev/null || echo "Dependencies already installed or npm not found"
echo ""
echo "Starting proxy server..."
node proxy-server.js
