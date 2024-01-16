# PlanetaryAnnihilationDedicated
Dedicated Server Setup for PA

https://github.com/ich777 had a a lot of work put into a dedicated server for PA, it has since been depreciated. A lot of these concepts are based off their work. 

I wanted to use docker, as all the images were depreciated by now. However there are two challenges to making this 100% automated and available on the hub.

1. Steamcmd will not work anonymously. You must login and persist that login.
2. The PA Server requires a few dependencies from base images ffmpeg libsm6 libxext6.

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
