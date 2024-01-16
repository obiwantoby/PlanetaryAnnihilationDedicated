FROM debian

# PA Dependency
RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y

# Copy the startup script to the container
ADD /scripts/ /opt/scripts/
# Make the script executable
RUN chmod +x /usr/local/bin/start.sh

# Set the script as the entry point
ENTRYPOINT ["/opt/scripts/start.sh"]
