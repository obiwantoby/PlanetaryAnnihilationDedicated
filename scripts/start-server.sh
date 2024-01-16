#!/bin/bash
export LD_LIBRARY_PATH=/usr/lib
export XDG_RUNTIME_DIR=/serverdata/serverfiles

echo "---Preparing Server---"
chmod -R ${UID}:${GID} ${DATA_DIR}

echo "---Starting Server---"
if [ -z "${SERVER_PWD}" ]; then
	if [ "${GAME_STREAM}" == "stable" ]; then
		cd ${SERVER_DIR}/stable
		${SERVER_DIR}/stable/server --game-mode ${GAME_MODE} --server-name "${SERVER_NAME}" --mt-enabled --max-players ${MAX_PLAYERS} --headless --allow-lan --port ${GAME_PORT} ${GAME_PARAMS}
	fi
	if [ "${GAME_STREAM}" == "PTE" ]; then
		cd ${SERVER_DIR}/PTE
		${SERVER_DIR}/PTE/server --game-mode ${GAME_MODE} --server-name "${SERVER_NAME}" --mt-enabled --max-players ${MAX_PLAYERS} --headless --allow-lan --port ${GAME_PORT} ${GAME_PARAMS}
	fi
else
	if [ "${GAME_STREAM}" == "stable" ]; then
		cd ${SERVER_DIR}/stable
		${SERVER_DIR}/stable/server --game-mode ${GAME_MODE} --server-name "${SERVER_NAME}" --mt-enabled --max-players ${MAX_PLAYERS} --headless --allow-lan --port ${GAME_PORT} --server-password ${SERVER_PWD} ${GAME_PARAMS}
	fi
	if [ "${GAME_STREAM}" == "PTE" ]; then
		cd ${SERVER_DIR}/PTE
		${SERVER_DIR}/PTE/server --game-mode ${GAME_MODE} --server-name "${SERVER_NAME}" --mt-enabled --max-players ${MAX_PLAYERS} --headless --allow-lan --port ${GAME_PORT} --server-password ${SERVER_PWD} ${GAME_PARAMS}
	fi
fi
