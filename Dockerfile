###########################################################
# Dockerfile that builds a PA:Titans Gameserver
###########################################################
FROM cm2network/steamcmd:root as build_stage

LABEL maintainer="brandon@clinger.dev"

ENV STEAMAPPID 386070
ENV STEAMAPP PlanetaryAnnihilation
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated"

# Copy the startup script to the container
COPY scripts/entry.sh "${HOMEDIR}/entry.sh"
COPY scripts/server.sh "${STEAMAPPDIR}/server.sh"
RUN chmod +x "${HOMEDIR}/entry.sh"
RUN chmod +x "${STEAMAPPDIR}/server.sh"
# PA Dependency
RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y

# Set the script as the entry point
ENTRYPOINT ["${HOMEDIR}/entry.sh"]
