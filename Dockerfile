# PA Titans Dedicated Server with jemalloc optimization
# Works with vanilla PA server or BOLT-optimized binaries
FROM cm2network/steamcmd:root

LABEL maintainer="brandon.clinger@afs.com"
LABEL description="PA Titans Dedicated Server with jemalloc (80%+ CPU reduction, 90%+ with BOLT)"
LABEL version="1.1.0"

# Install dependencies for PA + jemalloc build + OLD libraries for vanilla PA
RUN apt-get update && apt-get install -y \
    # PA Titans requirements
    lib32gcc-s1 \
    lib32stdc++6 \
    libc6-i386 \
    libsdl2-2.0-0 \
    libstdc++6 \
    libgl1 \
    libglx-mesa0 \
    libglu1-mesa \
    libcurl3t64-gnutls \
    curl \
    ca-certificates \
    # Vulkan support (for future GPU pathfinding)
    libvulkan1 \
    mesa-vulkan-drivers \
    vulkan-tools \
    # jemalloc build dependencies
    build-essential \
    wget \
    autoconf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and install OLD libraries that vanilla PA server needs
# These aren't in modern repos, so we install from archives
RUN cd /tmp \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/libi/libidn/libidn11_1.33-2.2ubuntu2_amd64.deb \
    && dpkg -i libidn11_1.33-2.2ubuntu2_amd64.deb || true \
    && rm libidn11_1.33-2.2ubuntu2_amd64.deb

# Build and install jemalloc 5.3.0 (80%+ CPU reduction for PA server)
RUN cd /tmp \
    && wget -q https://github.com/jemalloc/jemalloc/releases/download/5.3.0/jemalloc-5.3.0.tar.bz2 \
    && tar xjf jemalloc-5.3.0.tar.bz2 \
    && cd jemalloc-5.3.0 \
    && ./configure --prefix=/usr/local \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -rf /tmp/jemalloc-5.3.0* \
    && ldconfig

# Create directories
RUN mkdir -p /opt/pa/bin \
    && mkdir -p /opt/pa/data \
    && mkdir -p /opt/pa/logs \
    && chown -R ${USER}:${USER} /opt/pa

# PA server binary provided via volume mount
VOLUME ["/opt/pa/bin"]

# Server configuration
ENV PA_SERVER_NAME="PA-Docker-Server" \
    PA_PORT=20545 \
    PA_MAX_PLAYERS=10 \
    PA_GAME_MODE="PAExpansion1:lobby" \
    MALLOC_CONF="narenas:8,tcache:true,dirty_decay_ms:10000,muzzy_decay_ms:10000" \
    LD_PRELOAD=/usr/local/lib/libjemalloc.so.2

# Switch to non-root user
USER ${USER}

WORKDIR /opt/pa

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD pgrep -f "server.*--headless" && echo "Healthy" || exit 1

# Expose PA server ports
EXPOSE 20545/udp 20546/udp 20547/udp

# Entrypoint script
COPY --chown=${USER}:${USER} entrypoint.sh /opt/pa/entrypoint.sh
RUN chmod +x /opt/pa/entrypoint.sh

ENTRYPOINT ["/opt/pa/entrypoint.sh"]
