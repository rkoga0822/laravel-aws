#!/bin/bash
set -e

DEPLOY_PATH="/var/www/laravel"
SSH_CMD="ssh -i ~/.ssh/deploy_key -o StrictHostKeyChecking=no"

echo "Deploying to staging..."

# コードを転送（vendor/ はサーバー側で composer install するため除外）
rsync -avz --delete \
  -e "${SSH_CMD}" \
  --exclude='.git' \
  --exclude='.env' \
  --exclude='vendor/' \
  --exclude='storage/logs' \
  ./ ${DEPLOY_USER}@${DEPLOY_HOST}:${DEPLOY_PATH}

# サーバー上でデプロイ後の処理を実行
echo "Running post-deploy commands..."
${SSH_CMD} ${DEPLOY_USER}@${DEPLOY_HOST} \
  "cd ${DEPLOY_PATH} && \
   composer install --no-dev --optimize-autoloader && \
   php artisan config:clear && \
   php artisan migrate --force"

echo "Deployed successfully!"