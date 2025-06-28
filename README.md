# PlanetaryAnnihilationDedicated
Dedicated Server Setup for Planetary Annihilation

I wanted to use docker, as all the images were depreciated by now. However there are challenges to making this 100% automated and available on the hub.
Namely, steamcmd will not work anonymously. You must login and persist that login.

# What is Planetary Annihilation?
Planetary Annihilation Titans is a standalone expansion of the original Planetary Annihilation, a real-time strategy game. It was released on August 18, 2015, and adds 21 new units to the game, including five Titan-class units. It also adds multi-level terrain, a bounty mode, and an improved tutorial1. The game allows players to command armies with numbers in the thousands across multiple planets on land, sea, air, and even in orbit. It also features epic multiplayer, where up to ten friends can play in massive free-for-all and team-based matches.

This Docker image contains the dedicated server of the game.

>  [PA Titans]([Title](https://store.steampowered.com/app/386070/Planetary_Annihilation_TITANS/))

# How to use this image
## Hosting a simple game server

**Initial one-time setup**

As of now, you can't download the PA Titans dedicated server using `+login anonymous`. You need to cache your Steam credentials first.

### Quick Setup (Recommended)

Use the provided setup script to automate credential caching:

```console
$ ./setup-credentials.sh
```

This script will:
1. Create the required Docker volume
2. Prompt for your Steam credentials
3. Cache them securely in the volume
4. Provide next steps

### Manual Setup (Alternative)

If you prefer to do the setup manually:

### Step 1: Create the Steam credentials volume

If you're using docker-compose (recommended), create the volume with the docker-compose prefix:

```console
$ docker volume create docker_steamcmd_login_volume
```

Or if you're using plain Docker commands:

```console
$ docker volume create steamcmd_login_volume
```

### Step 2: Cache your Steam credentials

**Important:** You need a Steam account that owns PA Titans. You can use your main account or create a dedicated one.

Replace `[STEAMUSER]` and `[ACCOUNTPASSWORD]` with your actual Steam credentials:

```console
$ docker run -it --rm \
    -v "docker_steamcmd_login_volume:/home/steam/Steam" \
    ghcr.io/obiwantoby/pa-dedicated-server:latest \
    bash /home/steam/steamcmd/steamcmd.sh +login [STEAMUSER] [ACCOUNTPASSWORD] +quit
```

If Steam Guard is enabled (recommended), you'll be prompted for your authentication code. This step will permanently save your login session in the volume.

### Step 3: Configure and run the server

1. Clone or download this repository
2. Either:
   - **Option A:** Copy `.env.example` to `.env` and edit the values:
     ```console
     $ cp .env.example .env
     $ nano .env  # or use your preferred editor
     ```
   - **Option B:** Edit the `docker-compose.yml` file directly and replace the placeholder values

3. Create the data directory and set permissions:
```console
$ mkdir -p ./pa-data
$ chmod 755 ./pa-data
```

4. Start the server:
```console
$ docker-compose up -d
```

**Running with plain Docker (alternative to docker-compose)**

If you prefer to use plain Docker commands instead of docker-compose:
```console
$ mkdir -p $(pwd)/pa-data
$ chmod 755 $(pwd)/pa-data
$ docker run -d --net=host \
    -v $(pwd)/pa-data:/home/steam/PlanetaryAnnihilation-dedicated/ \
    -v "steamcmd_login_volume:/home/steam/Steam" \
    --name=pa-dedicated \
    -e STEAMUSER=[STEAMUSER] \
    -e PA_SERVERNAME="My PA Server" \
    -e PA_PW="changeme" \
    ghcr.io/obiwantoby/pa-dedicated-server:latest
```

Replace `[STEAMUSER]` with your Steam username (same as used in the credential caching step).

## Troubleshooting

### "Steam login failed" error
If you see a "Steam login failed" error, your cached credentials may have expired. Re-run Step 2 to refresh them.

### Server not starting
1. Check the logs: `docker-compose logs pa` or `docker logs pa-dedicated`
2. Ensure the `pa-data` directory has correct permissions
3. Verify your Steam account owns PA Titans
4. Make sure the required ports are available (default: 27015)

### Updating the server
The container automatically updates the game on startup. To force an update, restart the container:
```console
$ docker-compose restart pa
```

**Note:** While `chmod 777` works, it's more secure to use `chmod 755` and ensure proper ownership. The container runs as an unprivileged user for security.
# Credits

This repository is based on [https://github.com/CM2Walki/CS2/](https://github.com/CM2Walki/CS2/) .<br/>
This repository is inspired by [https://github.com/XanderXAJ/docker-planetary-annihilation-server/ ](https://github.com/XanderXAJ/docker-planetary-annihilation-server)

**The container will automatically update the game on startup, so if there is a game update just restart the container.**
