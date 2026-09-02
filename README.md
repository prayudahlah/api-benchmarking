# IPBD Kelompok 1 - API Benchmarking

<p align="center">
  Prayuda Afifan Handoyo | L0224008 | Kelas A<br>
  Lois Ryannareta | L0224006 | Kelas A<br> 
  Rambat Ungu Aryati | L0224010 | Kelas A<br> 
  Desain Aplikasi Big Data
</p>

Benchmarking API performance dengan multiple instance dan load balancing.

## Project Structure

```
.
├── api/            # FastAPI
├── file_gen/       # File generator
├── compose/        # Docker Compose configs
│   ├── compose.standalone.yaml   # Single instance
│   └── compose.distributed.yaml  # 3 replicas + nginx Load Balancer
└── proxy/
    └── nginx.conf  # Nginx load balancer config
```

## Docker Compose

### Standalone (single instance)

```bash
docker compose -f compose/compose.standalone.yaml up --build
```

API diakses dari `http://localhost:8000`

### Distributed (3 replicas + nginx load balancer)

```bash
docker compose -f compose/distributed.yaml up --build
```

API diakses dari `http://localhost:8000` via nginx round-robin.
