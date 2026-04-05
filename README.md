# PA Titans Dedicated Server - Docker with jemalloc

Docker deployment for Planetary Annihilation: Titans with **80%+ CPU reduction** through jemalloc memory allocator.

**Performance:**
- Vanilla PA server: **259% → 52% CPU** (80% reduction)
- BOLT-optimized: **259% → 20% CPU** (92% reduction, additional 8-12% from BOLT)

Works with **both vanilla and BOLT-optimized** PA server binaries.

## Prerequisites

**You must provide:**

1. **PA server binary** (choose one):
   - **Option A (Easy):** Vanilla `server` from PA Titans Steam install
   - **Option B (Best):** BOLT-optimized `server_bolt3` (see [rec.md](../rec.md))

2. **PA Titans game files**
   - Install PA Titans via Steam
   - Copy game files to a dedicated directory  
   - Create symlinks: `host/` and `media/` pointing to PA data

3. **ICU data file**
   - File: `icudtl.dat` (203 MB, required by V8 JavaScript engine)
   - Location: PA game install directory
   - Must be in same directory as server binary

## Quick Start

**Step 1: Copy and customize configuration**

```bash
# Copy example compose file
cp docker-compose.example.yml docker-compose.yml

# Edit paths for YOUR environment
vim docker-compose.yml
# Change lines 18 and 21:
#   /path/to/your/bolt3/directory -> your actual path
#   /path/to/your/pa-data -> your PA data location
```

**Step 2: Verify your directory structure**

```bash
# Your binary directory should contain:
$ ls -la /your/path/to/samples/
server_bolt3          # 40 MB BOLT3-optimized binary
icudtl.dat           # 203 MB V8 ICU data
host -> /data/pa-data/host    # Symlink to PA data
media -> /data/pa-data/media  # Symlink to PA data
```

**Step 3: Build and start**

```bash
# Local testing:
docker compose build
docker compose up -d

# Remote deployment:
vim deploy.sh    # Edit REMOTE_USER, REMOTE_HOST, REMOTE_PATH  
./deploy.sh
```

Server will be listening on port `20545` UDP with full optimizations active.

## What's Included

| File | Purpose |
|------|---------|
| `Dockerfile` | Debian Trixie + jemalloc 5.3.0 + PA dependencies |
| `docker-compose.yml` | Health checks, resource limits, volume mounts |
| `entrypoint.sh` | Startup script with optimization verification |
| `deploy.sh` | Automated deployment to remote server |

## Architecture

```
┌─────────────────────────────────────────────┐
│  Docker Container (pa-optimized)            │
│  ┌───────────────────────────────────────┐  │
│  │ jemalloc 5.3.0 (LD_PRELOAD)           │  │
│  │ └─ 80%+ CPU reduction                 │  │
│  └───────────────────────────────────────┘  │
│  ┌───────────────────────────────────────┐  │
│  │ BOLT3-optimized binary (40 MB)        │  │
│  │ └─ 8-12% additional CPU reduction     │  │
│  └───────────────────────────────────────┘  │
│                                             │
│  Result: 259% → 20% CPU (92% reduction)    │
└─────────────────────────────────────────────┘
```

## Volumes

```yaml
volumes:
  # Mount directory with BOLT3 binary + PA data symlinks
  - /home/brandon/samples:/opt/pa/bin:ro
  
  # Mount PA game data for symlink resolution
  - /data/pa-data:/data/pa-data:ro
  
  # Persistent logs
  - ./logs:/opt/pa/logs
```

**⚠️ Customize these paths** for your environment in `docker-compose.yml`.

## Health Checks

Container includes automatic health monitoring:

```yaml
healthcheck:
  test: ["CMD", "pgrep", "-f", "server_bolt3"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

Check status: `docker inspect pa-optimized --format='{{.State.Health.Status}}'`

## Deployment Script

`deploy.sh` automates 5-step deployment:

1. ✅ Sync Docker files to remote server
2. ✅ Build image on remote (avoids image transfer)
3. ✅ Stop existing server gracefully
4. ✅ Start optimized container with health checks
5. ✅ Display logs and health status

**Usage:**
```bash
./deploy.sh
# Deployment complete in ~2 minutes
```

## Monitoring

```bash
# Real-time stats
docker stats pa-optimized

# Follow logs
docker logs -f pa-optimized

# Verify jemalloc loaded
docker exec pa-optimized cat /proc/1/maps | grep jemalloc

# Check CPU usage (should be ~20% with AI players)
docker stats pa-optimized --no-stream
```

## Expected Performance

| Metric | Without Optimization | With BOLT3 + jemalloc |
|--------|---------------------|----------------------|
| CPU Usage | 259% (2.6 cores) | 20% (0.2 cores) |
| Memory | ~3.2 GB | ~2.6 GB |
| Status | Multithreaded stress | Optimized stable |

## Troubleshooting

**Container restarts immediately:**
```bash
docker logs pa-optimized --tail 50
# Check for missing dependencies or path issues
```

**jemalloc not loading:**
```bash
docker exec pa-optimized cat /proc/1/maps | grep jemalloc
# Should show: /usr/local/lib/libjemalloc.so.2
```

**Port conflicts:**
```bash
# Check if port 20545 is already in use
ss -tulpn | grep 20545
```

## Why Debian Trixie?

- **GLIBC 2.38 required:** BOLT3 binary was compiled with GLIBC 2.38
- **Package compatibility:** Uses `libcurl3t64-gnutls` (time64 transition)
- **Modern dependencies:** GCC 14, SDL 2.32, Mesa 25.0

See [DOCKER_BASE_IMAGE_RESEARCH.md](../DOCKER_BASE_IMAGE_RESEARCH.md) for detailed analysis.

## Related Documentation

- [OPTIMIZATION_SUCCESS_STORY.md](../OPTIMIZATION_SUCCESS_STORY.md) - How we achieved 92% CPU reduction
- [rec.md](../rec.md) - Optimization roadmap and techniques
- [DOCKER_BASE_IMAGE_RESEARCH.md](../DOCKER_BASE_IMAGE_RESEARCH.md) - Base image selection rationale
- [MIGRATION_GUIDE.md](../MIGRATION_GUIDE.md) - Package compatibility guide

## License

See main project LICENSE.
