#!/bin/bash
mkdir -p "${STEAMAPPDIR}" || true

# Download Updates

bash "${STEAMCMDDIR}/steamcmd.sh" +force_install_dir "${STEAMAPPDIR}" \
				+login "${STEAMUSER}" \
				+app_update "${STEAMAPPID}" \
				+quit
# Switch to server directory
cd "${STEAMAPPDIR}"

# Start Server
."${STEAMAPPDIR}"/server --port "${PA_PORT}" \
--headless \
--allow-lan \
--mt-enabled \
--max-players "${PA_MAXPLAYERS}" \
--max-spectators 5 \
--spectators 5 \
--server-password "${PA_PW}" \
--empty-timeout 5 \
--replay-filename "UTCTIMESTAMP" \
--replay-timeout 180 \
--gameover-timeout 360 \
--server-name "${PA_SERVERNAME}" \
--game-mode "PAExpansion1:config" \
