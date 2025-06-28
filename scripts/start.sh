#!/bin/bash
mkdir -p "${STEAMAPPDIR}" || true

# Download Updates - Try anonymous first, fallback to credentials if needed
echo "Downloading Planetary Annihilation: Titans Dedicated Server..."

if [ -n "${STEAM_USERNAME}" ] && [ -n "${STEAM_PASSWORD}" ]; then
    echo "Using Steam credentials for download..."
    bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
				+login "${STEAM_USERNAME}" "${STEAM_PASSWORD}" \
				+app_update "${STEAMAPPID}" validate \
				+quit
else
    echo "Attempting anonymous download..."
    bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
				+login anonymous \
				+app_update "${STEAMAPPID}" validate \
				+quit
fi

# Check if download was successful
if [ ! -d "${STEAMAPPDIR}" ]; then
    echo "ERROR: Server download failed - directory does not exist"
    exit 1
fi

# Switch to server directory
cd "${STEAMAPPDIR}"

# Find the correct server executable
if [ -f "./PA" ]; then
    SERVER_EXEC="./PA"
elif [ -f "./bin_x64/PA" ]; then
    SERVER_EXEC="./bin_x64/PA"
elif [ -f "./server" ]; then
    SERVER_EXEC="./server"
else
    echo "ERROR: Could not find PA server executable"
    echo "Contents of ${STEAMAPPDIR}:"
    ls -la
    exit 1
fi

echo "Starting Planetary Annihilation: Titans server with executable: ${SERVER_EXEC}"

# Start Server
${SERVER_EXEC} --port "${PA_PORT}" \
--headless \
--allow-lan \
--mt-enabled \
--max-players "${PA_MAXPLAYERS}" \
--max-spectators 5 \
--community-servers-url auto \
--http \
--spectators 5 \
--server-password "${PA_PW}" \
--empty-timeout 5 \
--replay-filename "UTCTIMESTAMP" \
--replay-timeout 180 \
--gameover-timeout 360 \
--server-name "${PA_SERVERNAME}" \
--game-mode "PAExpansion1:config" \
--output-dir "${STEAMAPPDIR}/logs"
