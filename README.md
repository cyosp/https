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
  -p 8080:80 \
  -e "DH_LENGTH=4096" \
  -v $(pwd)/demo/volume/certs:/certs \
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
