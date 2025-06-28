#!/bin/bash
mkdir -p "${STEAMAPPDIR}" || true

# Download Updates - Use cached Steam credentials
echo "Downloading Planetary Annihilation: Titans Dedicated Server..."

# Check if we have a steamuser set (should be cached already)
if [ -z "${STEAMUSER}" ]; then
    echo "ERROR: STEAMUSER environment variable not set"
    echo "You must first cache your Steam credentials using the initial setup steps"
    exit 1
fi

# First try to use cached credentials with just the username
echo "Attempting to use cached Steam credentials for user: ${STEAMUSER}"
bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
			+login "${STEAMUSER}" \
			+app_update "${STEAMAPPID}" validate \
			+quit

# Check if the download succeeded
if [ $? -ne 0 ]; then
    echo "ERROR: Steam login failed. Your cached credentials may have expired."
    echo "Please re-run the initial setup to cache your Steam credentials:"
    echo "docker run -it --rm -v \"steamcmd_login_volume:/home/steam/Steam\" ghcr.io/obiwantoby/pa-dedicated-server:latest bash /home/steam/steamcmd/steamcmd.sh +login [STEAMUSER] [PASSWORD] +quit"
    exit 1
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
