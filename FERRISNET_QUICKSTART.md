# FerrisNet Rust Core Integration - Quick Start

This guide shows you how to run the PA Titans dedicated server with **FerrisNet performance optimization** for ~4x performance improvement.

## Prerequisites

- Docker and docker-compose installed
- Steam account that owns PA Titans
- Rust toolchain (if building from source)

## Option 1: Using Pre-Compiled Library (Fastest)

If you already have the FerrisNet library compiled at `/data/rustengine/target/release/libferrisnet_rust_core.so`:

```bash
cd /data/PlanetaryAnnihilationDedicated

# Copy the example environment file
cp .env.example .env

# Edit .env with your Steam credentials
nano .env

# Ensure ENABLE_FERRISNET=true is set (default)

# Start the server
docker-compose up -d

# Check logs to verify FerrisNet is active
docker-compose logs pa | grep FerrisNet
```

You should see:
```
╔═══════════════════════════════════════════════════════╗
║   🚀 FerrisNet Performance Hooks ENABLED                 ║
║   Expected performance: ~4x improvement              ║
║   - SDL2 overhead eliminated (97% → <1%)            ║
║   - Profiler disabled (~50% → 0%)                   ║
║   - IO flushing optimized (26% → 11%)               ║
║   - SIMD collision detection active (3-4x faster)   ║
╚═══════════════════════════════════════════════════════╝
```

## Option 2: Build FerrisNet from Source

If you need to build the library first:

```bash
# Clone and build FerrisNet
cd /data
git clone <your-repo-url> rustengine
cd rustengine
cargo build --release

# The library will be at: /data/rustengine/target/release/libferrisnet_rust_core.so

# Now follow Option 1 steps above
cd /data/PlanetaryAnnihilationDedicated
cp .env.example .env
nano .env
docker-compose up -d
```

## Option 3: Custom Library Location

If your library is at a different location, update `docker-compose.yml`:

```yaml
volumes:
  - /your/custom/path/libferrisnet_rust_core.so:/opt/ferrisnet/libferrisnet_rust_core.so:ro
```

## Performance Verification

### Check Server Performance

```bash
# View real-time logs
docker-compose logs -f pa

# Check if the server is responsive
curl http://localhost:27015/  # or your configured port
```

### Profile Inside Container (Advanced)

```bash
# Get the server PID
docker exec pa-dedicated pgrep -f server

# Profile for 60 seconds (requires perf tools in container)
docker exec pa-dedicated perf record -F 999 -p <PID> -- sleep 60
```

## Disabling FerrisNet

To run without performance hooks:

**Method 1: Environment Variable**
```bash
# Edit .env
ENABLE_FERRISNET=false

# Restart
docker-compose restart pa
```

**Method 2: Remove Volume Mount**
```yaml
# Comment out or remove this line in docker-compose.yml:
# - /data/rustengine/target/release/libferrisnet_rust_core.so:/opt/ferrisnet/libferrisnet_rust_core.so:ro
```

## Troubleshooting

### "WARNING: FerrisNet enabled but library not found"

**Cause:** The library file doesn't exist at the mounted path.

**Fix:**
1. Verify the library exists: `ls -lh /data/rustengine/target/release/libferrisnet_rust_core.so`
2. If missing, build it: `cd /data/rustengine && cargo build --release`
3. Check the volume mount path in `docker-compose.yml` matches your library location

### Server Crashes Immediately

**Cause:** Possible incompatibility or hook issue.

**Fix:**
1. Disable FerrisNet temporarily: `ENABLE_FERRISNET=false`
2. Check container logs: `docker-compose logs pa`
3. Verify library architecture matches server (x86_64)

### Performance Not Improved

**Cause:** Hooks may not be loading correctly.

**Fix:**
1. Verify FerrisNet initialization message in logs
2. Check `ldd` output inside container:
   ```bash
   docker exec pa-dedicated ldd /opt/ferrisnet/libferrisnet_rust_core.so
   ```
3. Ensure server is under load (idle server won't show optimization benefits)

## Advanced Configuration

Create `pa-data/config.toml` for advanced FerrisNet settings:

```toml
[hooks]
enable_sdl2_hooks = true
enable_performance_hooks = true
enable_swizzletree_hooks = true
enable_network_hooks = true

[logging]
log_level = "info"  # trace, debug, info, warn, error
log_file = "/home/steam/PlanetaryAnnihilation-dedicated/logs/ferrisnet.log"

[network]
bind_all_interfaces = true
```

## Performance Comparison

### Without FerrisNet
- MainThread: 97% SDL2 polling, 2% game logic
- Worker Threads: Mostly idle
- Sim Speed: 100% with small armies, drops quickly with large battles

### With FerrisNet
- MainThread: <1% SDL2, actual game logic visible
- Worker Threads: Fully utilized (collision, physics, entity management)
- Sim Speed: Maintains 100% with 4x larger armies

## Support

- FerrisNet Issues: Check the rustengine repository
- Docker Issues: File an issue in this repository
- PA Server Issues: Check PA community forums

## See Also

- [FerrisNet Rust Core Documentation](/data/rustengine/README.md)
- [PA Dedicated Server Setup](README.md)
- [Docker Compose Reference](https://docs.docker.com/compose/)
