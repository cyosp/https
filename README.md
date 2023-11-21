# https

https reverse proxy

## Podman instructions

### Build
```bash
podman build . -f Containerfile -t https
```

### Run
#### Dry run
```bash
podman run \
  -d \
  -p 8080:80 \
  -e "DH_LENGTH=4096" \
  -e "KEY_TYPE=rsa" \
  -e "KEY_VALUE=4096" \
  -e "DRY_RUN=true" \
  -e "EXAMPLE1_FROM_HOST=ex.amp.le" \
  -e "EXAMPLE1_AND_PATH=/path1" \
  -e "EXAMPLE1_TO=192.168.0.1" \
  -e "EXAMPLE2_FROM_HOST=ex.amp.le" \
  -e "EXAMPLE2_AND_PATH=/path2" \
  -e "EXAMPLE2_TO=192.168.0.1" \
  -e "EXAMPLE3_FROM_HOST=ex3.amp.le" \
  -e "EXAMPLE3_TO=192.168.0.3" \
  -e "EXAMPLE4_FROM_HOST=ex4.amp.le" \
  -e "EXAMPLE4_AND_PATH=/path4" \
  -e "EXAMPLE4_BASIC_AUTH_USERNAME_AND_PASSWORD=login:password" \
  -e "EXAMPLE4_TO=192.168.0.4" \
  -v $(pwd)/demo/volume/certs:/etc/letsencrypt/live \
  -v $(pwd)/demo/volume/conf:/conf \
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
