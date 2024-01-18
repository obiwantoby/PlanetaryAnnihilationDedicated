# PlanetaryAnnihilationDedicated
Dedicated Server Setup for PA

I wanted to use docker, as all the images were depreciated by now. However there are two challenges to making this 100% automated and available on the hub.

1. Steamcmd will not work anonymously. You must login and persist that login.
2. The PA Server requires a few dependencies from base images ffmpeg libsm6 libxext6.


$ docker run -it --rm \
    -v "steamcmd_login_volume:/home/steam/Steam" \
    cm2network/steamcmd \
    bash /home/steam/steamcmd/steamcmd.sh +login [STEAMUSER] [ACCOUNTPASSWORD] +quit



--- Archive ---

Sample Dockerfile could look like 

FROM ....

RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y

....

What I am doing now is 

docker run -it -v /data/pa/:/data steamcmd/steamcmd:latest +login <YOURUSER> +force_install_dir /data +app_update 386070 +quit

Then running the server on the host via 

./server --port 20545 \
--headless \
--allow-lan \
--mt-enabled \
--max-players 32 \
--max-spectators 5 \
--spectators 5 \
--server-password "xxxxx" \
--empty-timeout 5 \
--replay-filename "UTCTIMESTAMP" \
--replay-timeout 180 \
--gameover-timeout 360 \
--server-name "name" \
--game-mode "PAExpansion1:config" \
--output-dir $OUTPUT
