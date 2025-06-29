###########################################################
# Dockerfile that builds a PA:Titans Gameserver
###########################################################
# Consider using 'latest' or a specific version like 'debian-11' if available for better stability
FROM cm2network/steamcmd:latest AS build_stage

LABEL maintainer="brandon@clinger.dev"

ENV STEAMAPPID=386070
ENV STEAMAPP=PlanetaryAnnihilation
ENV STEAMAPPDIR="${HOMEDIR}/${STEAMAPP}-dedicated"
ENV STEAMUSER=""
ENV STEAMCMDDIR="${HOMEDIR}/steamcmd"

# Switch to root to install packages
USER root

RUN set -x \
    # Enable multi-architecture support if the base image doesn't already
    && dpkg --add-architecture i386 \
    && apt-get update \
    # Install essential 32-bit libraries for SteamCMD and libcurl4 (32-bit)
    # Also install OpenGL libraries required by PA server
    && apt-get install -y --no-install-recommends --no-install-suggests \
        wget \
        ca-certificates \
        lib32z1 \
        libcurl4-gnutls-dev:i386 \
        libc6:i386 \
        libstdc++6:i386 \
        libncurses5:i386 \
        libtcmalloc-minimal4:i386 \
        libgl1-mesa-glx \
        libgl1-mesa-dri \
        libgl1:i386 \
        libglx0:i386 \
        libxrandr2:i386 \
        libxss1:i386 \
        libgconf-2-4:i386 \
    # Clean up
    && rm -rf /var/lib/apt/lists/*

# Copy the start script and set up directories
COPY scripts/start.sh "${HOMEDIR}/start.sh"
RUN mkdir -p "${STEAMAPPDIR}" \
    # Add entry script
    && chmod +x "${HOMEDIR}/start.sh" \
    && chown -R "${USER}:${USER}" "${HOMEDIR}/start.sh" "${STEAMAPPDIR}"

USER ${USER}

WORKDIR ${HOMEDIR}

# Set the script as the entry point
CMD ["bash", "start.sh"]
