# Planetary Annihilation Dedicated Server

Docker deployment for **Planetary Annihilation: Titans** with **jemalloc**, cutting dedicated-server CPU by **~80%** on a stock binary (up to **~92%** with a BOLT-optimized binary).

## Results

| Setup | Typical CPU | Notes |
|-------|-------------|--------|
| Stock PA server | ~259% (2.6 cores) | Baseline under load |
| + jemalloc | ~52% | This image (`LD_PRELOAD`) |
| + jemalloc + BOLT binary | ~20% | See optimization repo |

Works with a **vanilla** `server` binary or a **BOLT** build (`server_bolt3`).

## Prerequisites

You provide the game assets (not redistributed here):

1. **Server binary** — Steam PA Titans `server`, or BOLT-optimized binary from  
   [planetary-annihilation-optimization](https://github.com/obiwantoby/planetary-annihilation-optimization)
2. **Game data** — `host/` and `media/` (symlinks or mounts to your PA install)
3. **`icudtl.dat`** — V8 ICU data from the PA install (same dir as the binary)

## Quick start

```bash
cp docker-compose.example.yml docker-compose.yml
# Edit volume paths: binary dir + PA data
docker compose build
docker compose up -d
```

Default game port: **20545/UDP**.

Remote deploy helper: edit `deploy.sh` (`REMOTE_*`), then `./deploy.sh`.

## Layout

| File | Purpose |
|------|---------|
| `Dockerfile` | Debian + jemalloc + PA runtime deps |
| `docker-compose.example.yml` | Volumes, limits, healthcheck template |
| `entrypoint.sh` | Start + verify allocator preload |
| `deploy.sh` | Optional rsync/SSH deploy |
| `.env.example` | Env var template |

## Architecture

```text
Docker (pa-optimized)
  └── jemalloc via LD_PRELOAD   → ~80% CPU drop
  └── PA server binary          → optional BOLT for more savings
  └── host/ + media/ + icudtl.dat
```

## Related

- **Optimization guide / BOLT:** [planetary-annihilation-optimization](https://github.com/obiwantoby/planetary-annihilation-optimization)  
- **Challenge AI mod:** [SuperAI](https://github.com/obiwantoby/SuperAI)

## Notes

- Do not commit Steam credentials, real paths with secrets, or redistributed PA binaries.  
- Older experimental compose/Dockerfile variants live under `archive/`.
