FROM cm2network/steamcmd:root

LABEL maintainer="your-email@example.com"
LABEL description="Planetary Annihilation: Titans Dedicated Server with FerrisNet Performance Hooks"

# Install required dependencies
RUN apt-get update && apt-get install -y \
    lib32gcc-s1 \
    lib32stdc++6 \
    libc6-i386 \
    libsdl2-2.0-0 \
    libstdc++6 \
    libgl1 \
    libgl1-mesa-glx \
    libglu1-mesa \
    libcurl3-gnutls \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV STEAMAPPID=386070
ENV STEAMAPP=pa
ENV STEAMAPPDIR="${HOMEDIR}/${STEAMAPP}-dedicated"
ENV DLURL=https://media.steampowered.com
ENV ENABLE_FERRISNET=false

# Server configuration environment variables with defaults
ENV PA_SERVERNAME="My PA Titans Server" \
    PA_PW="changeme" \
    PA_PORT=27015 \
    PA_MAXPLAYERS=10

# Create necessary directories
RUN mkdir -p "${STEAMAPPDIR}" \
    && mkdir -p /opt/ferrisnet \
    && chown -R "${USER}:${USER}" "${STEAMAPPDIR}" \
    && chown -R "${USER}:${USER}" /opt/ferrisnet

# Switch to non-root user
USER ${USER}

# Copy the start script
COPY --chown=${USER}:${USER} scripts/start.sh "${HOMEDIR}/start.sh"

# Make the start script executable
RUN chmod +x "${HOMEDIR}/start.sh"

# Set working directory
WORKDIR ${HOMEDIR}

# Health check - verify the server process is running
HEALTHCHECK --interval=60s --timeout=10s --start-period=120s --retries=3 \
    CMD pgrep -f "server.*--headless" || exit 1

# PA Titans uses these ports:
# 27015 - Game port (UDP)
# 20545-20555 - Additional game ports (UDP)
EXPOSE 27015/udp 20545-20555/udp

# Volume for server data
VOLUME ["${STEAMAPPDIR}"]

# Start the server
ENTRYPOINT ["bash", "start.sh"]
