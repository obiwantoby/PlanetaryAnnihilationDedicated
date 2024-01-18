###########################################################
# Dockerfile that builds a PA:Titans Gameserver
###########################################################
FROM cm2network/steamcmd:root as build_stage

LABEL maintainer="brandon@clinger.dev"

ENV STEAMAPPID 386070
ENV STEAMAPP PlanetaryAnnihilation
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated"
ENV STEAMUSER

# Copy the startup script to the container
COPY scripts/start.sh /start.sh
COPY scripts/start-server.sh "${STEAMAPPDIR}/server.sh"
RUN chmod +x "/start.sh"
RUN chmod +x "${STEAMAPPDIR}/server.sh"
# PA Dependency
RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y

ENV PA_SERVERNAME="New \"${STEAMAPP}\" Server" \
    PA_PORT=27015 \
    PA_MAXPLAYERS=10 \
    PA_PW="changeme"

# Set the script as the entry point
ENTRYPOINT ["/start.sh"]
