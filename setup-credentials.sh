#!/bin/bash

# Setup script for caching Steam credentials for PA Titans dedicated server
# This script automates the initial credential caching process

set -e

echo "===================================================="
echo "PA Titans Dedicated Server - Credential Setup"
echo "===================================================="
echo

# Check if docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker first."
    exit 1
fi

# Check if we're in a directory with docker-compose.yml
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found in current directory."
    echo "Please run this script from the PA dedicated server directory."
    exit 1
fi

echo "This script will help you cache your Steam credentials for the PA Titans dedicated server."
echo "You need a Steam account that owns Planetary Annihilation: Titans."
echo


# Prompt for Steam username
read -p "Enter your Steam username: " STEAM_USERNAME

if [ -z "$STEAM_USERNAME" ]; then
    echo "❌ Error: Steam username cannot be empty."
    exit 1
fi

# Prompt for Steam password (hidden input)
echo -n "Enter your Steam password: "
read -s STEAM_PASSWORD
echo
echo

if [ -z "$STEAM_PASSWORD" ]; then
    echo "❌ Error: Steam password cannot be empty."
    exit 1
fi

echo "Creating Steam credentials volume..."
docker volume create docker_steamcmd_login_volume >/dev/null 2>&1 || {
    echo "⚠️  Volume already exists, continuing..."
}

echo "Caching Steam credentials..."
echo "Note: If you have Steam Guard enabled, you'll be prompted for your authentication code."
echo

# Run the credential caching command
docker run -it --rm \
    -v "docker_steamcmd_login_volume:/home/steam/Steam" \
    ghcr.io/obiwantoby/pa-dedicated-server:latest \
    bash /home/steam/steamcmd/steamcmd.sh +login "$STEAM_USERNAME" "$STEAM_PASSWORD" +quit

if [ $? -eq 0 ]; then
    echo
    echo "✅ Steam credentials cached successfully!"

    # Create .env file if it doesn't exist
    if [ ! -f ".env" ]; then
        echo "Creating .env file..."
        cp .env.example .env

        # Update the STEAMUSER in .env
        if command -v sed >/dev/null 2>&1; then
            sed -i.bak "s/your_steam_username_here/$STEAM_USERNAME/" .env && rm .env.bak
            echo "✅ Updated .env file with your Steam username"
        else
            echo "⚠️  Please manually edit .env file and set STEAMUSER=$STEAM_USERNAME"
        fi
    else
        echo "⚠️  .env file already exists. Please manually update STEAMUSER if needed."
    fi

    echo
    echo "Next steps:"
    echo "1. Review and edit .env file to configure your server settings"
    echo "2. Run: docker compose up -d"
    echo
    echo "Your credentials are now cached and the server should start without prompting for passwords."
else
    echo
    echo "❌ Error: Failed to cache Steam credentials."
    echo "Please check your username and password and try again."
    exit 1
fi
