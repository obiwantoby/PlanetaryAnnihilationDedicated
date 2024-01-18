###########################################################
# Dockerfile that builds a PA:Titans Gameserver
###########################################################
FROM cm2network/steamcmd:root as build_stage

LABEL maintainer="brandon@clinger.dev"

ENV STEAMAPPID 386070
ENV STEAMAPP PlanetaryAnnihilation
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated"
ENV STEAMUSER define

COPY scripts/start.sh /start.sh

RUN set -x \
	# Install, update & upgrade packages
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		wget=1.21-1+deb11u1 \
		ca-certificates=20210119 \
		lib32z1=1:1.2.11.dfsg-2+deb11u2 \
	&& mkdir -p "${STEAMAPPDIR}" \
	# Add entry script
	&& chmod +x "/start.sh" \
	&& chown -R "${USER}:${USER}" "/start.sh" "${STEAMAPPDIR}" \
	# Clean up
	&& rm -rf /var/lib/apt/lists/* 
	


# Copy the startup script to the container


ENV PA_SERVERNAME="New \"${STEAMAPP}\" Server" \
    PA_PORT=27015 \
    PA_MAXPLAYERS=10 \
    PA_PW="changeme"

USER ${USER}

WORKDIR ${HOMEDIR}

# Set the script as the entry point
CMD ["bash", "/entry.sh"]
