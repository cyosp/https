# https

https reverse proxy

## Podman instructions

### Build
```bash
podman build . -f Containerfile -t https
```

### Run
```bash
podman run \
  -d \
  --name https \
  https
```

### Checks
```bash
docker exec https service cron status
docker exec https service nginx status
```

### Logs
```bash
podman logs -f https
```
