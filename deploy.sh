#!/bin/bash

# POS CHAMA Deployment Script for Vercel

echo "🚀 Starting POS CHAMA deployment process..."

# Check if Vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "❌ Vercel CLI not found. Installing..."
    npm install -g vercel
fi

# Login to Vercel (will prompt for authentication)
echo "🔐 Please login to Vercel..."
vercel login

# Initialize and deploy
echo "📦 Deploying to Vercel..."
vercel --prod

echo "✅ Deployment complete!"
echo "🌐 Your POS CHAMA system should be available at the provided URL"
echo ""
echo "📋 Next steps:"
echo "1. Set up your Supabase database"
echo "2. Configure environment variables in Vercel dashboard"
echo "3. Update your domain to POSCHAMA.vercel.app (if desired)"
