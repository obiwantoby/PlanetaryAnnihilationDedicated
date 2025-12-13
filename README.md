# PlanetaryAnnihilationDedicated
Dedicated Server Setup for Planetary Annihilation with Optional  Performance Optimization

Docker-based dedicated server for PA Titans with **optional ~4x performance improvement** through Rust Core hooks.

**Quick Links:**
- [🚀 SkyNet Quick Start Guide](SKYNET_QUICKSTART.md) - Get started with performance optimization
- [Standard Setup](#how-to-use-this-image) - Basic server setup without optimization

## Why Docker?

All previous PA Titans Docker images have been deprecated. This setup provides a modern, maintained solution.

**Note:** SteamCMD requires authenticated login (anonymous download is not supported for PA Titans). You must cache your Steam credentials first.

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
    -v /data/rustengine/target/release/libskynet_rust_core.so:/opt/skynet/libskynet_rust_core.so:ro \
    --name=pa-dedicated \
    -e STEAMUSER=[STEAMUSER] \
    -e PA_SERVERNAME="My PA Server" \
    -e PA_PW="changeme" \
    -e ENABLE_SKYNET=true \
    ghcr.io/obiwantoby/pa-dedicated-server:latest
```

Replace `[STEAMUSER]` with your Steam username (same as used in the credential caching step).

## 🚀 SkyNet Performance Optimization (Optional but Recommended)

This server includes support for **SkyNet Rust Core**, a high-performance optimization library that provides **~4x performance improvement** through:

- **SDL2 overhead elimination**: 97% → <1% CPU
- **Profiler system disabled**: ~50% → 0% CPU
- **IO flushing optimized**: 26% → 11% CPU (net +15% gain)
- **SIMD collision detection**: 3-4x faster spatial queries
- **12 worker threads fully utilized** (previously idle)

### Enabling SkyNet Hooks

**Option 1: Using docker-compose (Recommended)**

The `docker-compose.yml` is already configured to use SkyNet hooks by default. The library is mounted from `/data/rustengine/target/release/libskynet_rust_core.so`.

To enable/disable:
```yaml
environment:
  - ENABLE_SKYNET=true  # Set to 'false' to disable
```

**Option 2: Build SkyNet from source**

If the pre-compiled library isn't available, you can build it:

```console
$ cd /data
$ git clone https://github.com/yourusername/skynet-rust-core.git rustengine
$ cd rustengine
$ cargo build --release
```

The compiled library will be at `/data/rustengine/target/release/libskynet_rust_core.so`.

**Option 3: Disable SkyNet**

To run without performance hooks:
```yaml
environment:
  - ENABLE_SKYNET=false
```

Or simply remove the volume mount for the library in `docker-compose.yml`.

### SkyNet Performance Impact

**Before Optimization:**
- MainThread: 97% SDL2 event loop, 2% game logic
- Worker Threads: Idle (0% utilization)

**After Optimization:**
- MainThread: <1% SDL2, ~25% time queries, ~11% IO, actual game logic visible
- Worker Threads: Active (collision detection, entity retirement, SIMD queries)

**Net Result:** Server can handle 4x more simulation load at the same CPU usage.

### Verification

Check the container logs to verify SkyNet is active:
```console
$ docker-compose logs pa | grep SkyNet
```

You should see:
```
╔═══════════════════════════════════════════════════════╗
║   🚀 SkyNet Performance Hooks ENABLED                 ║
║   Expected performance: ~4x improvement              ║
╚═══════════════════════════════════════════════════════╝
```

### Advanced Configuration

For advanced SkyNet configuration, create a `config.toml` in the `pa-data` directory:

```toml
[hooks]
enable_sdl2_hooks = true
enable_performance_hooks = true
enable_swizzletree_hooks = true
enable_network_hooks = true

[logging]
log_level = "info"
log_file = "/tmp/skynet_ai.log"
```

See the [SkyNet Rust Core documentation](https://github.com/yourusername/skynet-rust-core) for more details.

## Troubleshooting

### "Steam login failed" error
If you see a "Steam login failed" error, your cached credentials may have expired. Re-run Step 2 to refresh them.

### "Could not find PA server executable" error
If you see this error, it means the PA Titans files downloaded successfully but the server executable couldn't be located. This can happen if:

1. **The PA installation structure changed**: The updated script will now search in multiple locations and show you what files were downloaded
2. **Missing execute permissions**: The script will automatically try to fix this
3. **Incomplete download**: Check the logs for any download errors

To debug this issue:
1. Check the container logs: `docker-compose logs pa`
2. The logs will show the directory contents and search results
3. If you see the files but the script still fails, you may need to manually identify the correct executable

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
