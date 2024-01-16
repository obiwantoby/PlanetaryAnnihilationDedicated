FROM debian

ENV DATA_DIR="/serverdata"
ENV STEAMCMD_DIR="${DATA_DIR}/steamcmd"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"

ENV GAME_PORT=27015
ENV VALIDATE=""
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV USERNAME=""
ENV PASSWRD=""
ENV GUARD=""
ENV DATA_PERM=770

# PA Dependency
RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y

# Copy the startup script to the container
ADD /scripts/ /opt/scripts/
# Make the script executable
RUN chmod +x /usr/local/bin/start.sh

# Set the script as the entry point
ENTRYPOINT ["/opt/scripts/start.sh"]
