###########################################################
# Dockerfile that builds a PA:Titans Gameserver
###########################################################
FROM cm2network/steamcmd:latest as build_stage # Consider using 'latest' or a specific version like 'debian-11' if available for better stability

LABEL maintainer="brandon@clinger.dev"

ENV STEAMAPPID 386070
ENV STEAMAPP PlanetaryAnnihilation
ENV STEAMAPPDIR "${HOMEDIR}/${STEAMAPP}-dedicated"
ENV STEAMUSER define

COPY scripts/start.sh "${HOMEDIR}/start.sh"

RUN set -x \
    # Enable multi-architecture support if the base image doesn't already
    && dpkg --add-architecture i386 \
    && apt-get update \
    # Install essential 32-bit libraries for SteamCMD and libcurl4 (32-bit)
    && apt-get install -y --no-install-recommends --no-install-suggests \
        wget=1.21-1+deb11u1 \
        ca-certificates=20210119 \
        lib32z1 \
        libcurl4-gnutls-dev:i386 \
        libc6:i386 \
        libstdc++6:i386 \
        libncurses5:i386 \
        libtcmalloc-minimal4:i386 \
    && mkdir -p "${STEAMAPPDIR}" \
    # Add entry script
    && chmod +x "${HOMEDIR}/start.sh" \
    && chown -R "${USER}:${USER}" "${HOMEDIR}/start.sh" "${STEAMAPPDIR}" \
    # Clean up
    && rm -rf /var/lib/apt/lists/*

ENV PA_SERVERNAME="New \"${STEAMAPP}\" Server" \
    PA_PORT=27015 \
    PA_MAXPLAYERS=10 \
    PA_PW="changeme"

USER ${USER}

WORKDIR ${HOMEDIR}

# Set the script as the entry point
CMD ["bash", "start.sh"]
