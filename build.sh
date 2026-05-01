#!/bin/bash
echo "N8N_ASSISTANT_WEBHOOK_URL=$N8N_ASSISTANT_WEBHOOK_URL" > .env
echo "N8N_PAYMENT_WEBHOOK_URL=$N8N_PAYMENT_WEBHOOK_URL" >> .env
echo "N8N_API_KEY=$N8N_API_KEY" >> .env
git clone https://github.com/flutter/flutter.git -b stable --depth 1
./flutter/bin/flutter build web --release --wasm
