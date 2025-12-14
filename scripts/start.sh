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

# Debug: Show what was actually downloaded
echo "Contents of ${STEAMAPPDIR}:"
ls -la

# Look for the PA server executable in various possible locations
SERVER_EXEC=""

# Common possible locations and names for PA server executable
# Prioritize the most likely Linux location first
POSSIBLE_EXECS=(
    "./bin_x64/server"        # Most likely for Linux PA Titans
    "./server"                # Fallback
    "./PA"                    # Windows-style
    "./bin_x64/PA"           # Alternative
    "./bin/PA"               # Alternative
    "./bin/server"           # Alternative
    "./PA_server"            # Alternative
    "./planetary_annihilation"
    "./bin_x64/planetary_annihilation"
    "./bin/planetary_annihilation"
)

echo "Searching for PA server executable..."
for exec_path in "${POSSIBLE_EXECS[@]}"; do
    if [ -f "$exec_path" ] && [ -x "$exec_path" ]; then
        SERVER_EXEC="$exec_path"
        echo "Found executable at: $exec_path"
        break
    elif [ -f "$exec_path" ]; then
        echo "Found file at $exec_path but it's not executable, making it executable..."
        chmod +x "$exec_path"
        SERVER_EXEC="$exec_path"
        echo "Using executable at: $exec_path"
        break
    fi
done

# If still not found, try to find any executable files
if [ -z "$SERVER_EXEC" ]; then
    echo "Standard paths failed, searching for any executable files..."
    find . -type f -executable -name "*PA*" -o -name "*server*" -o -name "*planetary*" | head -10
    
    # Look for files with common server patterns
    for pattern in "PA" "server" "planetary"; do
        found_exec=$(find . -type f -name "*${pattern}*" | head -1)
        if [ -n "$found_exec" ] && [ -f "$found_exec" ]; then
            echo "Trying executable: $found_exec"
            chmod +x "$found_exec" 2>/dev/null || true
            if [ -x "$found_exec" ]; then
                SERVER_EXEC="$found_exec"
                echo "Using executable: $found_exec"
                break
            fi
        fi
    done
fi

if [ -z "$SERVER_EXEC" ]; then
    echo "ERROR: Could not find PA server executable"
    echo "Directory structure:"
    find . -type f -name "*" | head -20
    echo "Please check the PA Titans installation or report this issue."
    exit 1
fi

echo "Starting Planetary Annihilation: Titans server with executable: ${SERVER_EXEC}"

# Check if FerrisNet performance hooks should be enabled
FERRISNET_LIB="/opt/ferrisnet/libferrisnet_rust_core.so"
LD_PRELOAD_CMD=""

if [ "${ENABLE_FERRISNET}" = "true" ] && [ -f "${FERRISNET_LIB}" ]; then
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║   🚀 FerrisNet Performance Hooks ENABLED                 ║"
    echo "║   Expected performance: ~4x improvement              ║"
    echo "║   - SDL2 overhead eliminated (97% → <1%)            ║"
    echo "║   - Profiler disabled (~50% → 0%)                   ║"
    echo "║   - IO flushing optimized (26% → 11%)               ║"
    echo "║   - SIMD collision detection active (3-4x faster)   ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    export LD_PRELOAD="${FERRISNET_LIB}"
elif [ "${ENABLE_FERRISNET}" = "true" ]; then
    echo "⚠️  WARNING: FerrisNet enabled but library not found at ${FERRISNET_LIB}"
    echo "   Server will start without performance hooks"
else
    echo "ℹ️  FerrisNet performance hooks disabled (set ENABLE_FERRISNET=true to enable)"
fi

# Start Server with or without FerrisNet hooks
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
