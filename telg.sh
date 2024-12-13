#!/bin/bash

botToken="7442014466:AAHDuTdM31lpMOIo_kbo0hyi-UjQfwsJzss"
chatId="-1002155957161"

sendMessageUrl="https://api.telegram.org/bot$botToken/sendMessage"
getUpdatesUrl="https://api.telegram.org/bot$botToken/getUpdates"
deleteWebhookUrl="https://api.telegram.org/bot$botToken/deleteWebhook"
getChatUrl="https://api.telegram.org/bot$botToken/getChat"

# Function to send a message
send_message() {
  echo "Sending a test message to the bot..."
  response=$(curl -s -X POST "$sendMessageUrl" -d "chat_id=$chatId" -d "text=App test. Hello from Bash script!")
  echo "Send Message Response: $response"
}

# Function to fetch updates
fetch_updates() {
  echo "Fetching updates from the bot..."
  response=$(curl -s -X POST "$getUpdatesUrl" \
    -d '{"allowed_updates":["message", "channel_post", "edited_message", "edited_channel_post"]}' \
    -H "Content-Type: application/json")
  echo "Raw Response: $response"
}

# Function to reset webhook
reset_webhook() {
  echo "Resetting webhook to ensure long polling works..."
  response=$(curl -s "$deleteWebhookUrl")
  echo "Delete Webhook Response: $response"
}

# Function to fetch chat info
fetch_chat_info() {
  echo "Fetching chat info..."
  response=$(curl -s "$getChatUrl?chat_id=$chatId")
  echo "Chat Info: $response"
}

# Main script execution
echo "=== Telegram Bot Debugging Script ==="

# Step 1: Reset webhook
reset_webhook

# Step 2: Fetch chat info
fetch_chat_info

# Step 3: Send a test message
send_message

# Step 4: Fetch updates
fetch_updates

echo "=== Script Execution Completed ==="
