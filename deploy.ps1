# POS CHAMA Deployment Script for Vercel (PowerShell)

Write-Host "🚀 Starting POS CHAMA deployment process..." -ForegroundColor Green

# Check if Vercel CLI is installed
$vercelExists = Get-Command vercel -ErrorAction SilentlyContinue
if (-not $vercelExists) {
    Write-Host "❌ Vercel CLI not found. Installing..." -ForegroundColor Red
    npm install -g vercel
}

# Login to Vercel
Write-Host "🔐 Please login to Vercel..." -ForegroundColor Yellow
vercel login

# Deploy to production
Write-Host "📦 Deploying to Vercel..." -ForegroundColor Blue
vercel --prod

Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host "🌐 Your POS CHAMA system should be available at the provided URL" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "1. Set up your Supabase database" -ForegroundColor White
Write-Host "2. Configure environment variables in Vercel dashboard" -ForegroundColor White
Write-Host "3. Update your domain to POSCHAMA.vercel.app (if desired)" -ForegroundColor White
