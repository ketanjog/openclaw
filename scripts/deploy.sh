cat > deploy.sh << 'SCRIPT'
#!/bin/bash
set -e

VPS_IP="187.77.197.108"
BRANCH=$(git branch --show-current)

echo "Pushing to GitHub..."
git push origin $BRANCH

echo "Deploying to VPS..."
ssh root@$VPS_IP << 'EOF'
  cd ~/openclaw-dev
  git pull
  pnpm install
  pnpm build
  docker stop openclaw-4nr3-openclaw-1 || true
  docker rm openclaw-4nr3-openclaw-1 || true
  docker build -t openclaw:local .
  docker run -d \
    --name openclaw-4nr3-openclaw-1 \
    --restart unless-stopped \
    -v ~/.openclaw:/root/.openclaw \
    -v ~/openclaw/workspace:/root/openclaw/workspace \
    openclaw:local
  echo "✅ Deployed!"
EOF
SCRIPT

chmod +x deploy.sh
