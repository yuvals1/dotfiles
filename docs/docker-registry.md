# Start the registry with CORS headers

```bash
docker run -d -p 5001:5000 --name registry \
 -e REGISTRY_HTTP_HEADERS_Access-Control-Allow-Origin='["http://localhost:8080"]' \
 -e REGISTRY_HTTP_HEADERS_Access-Control-Allow-Methods='["HEAD", "GET", "OPTIONS", "DELETE"]' \
 -e REGISTRY_HTTP_HEADERS_Access-Control-Allow-Headers='["Authorization", "Accept", "Cache-Control"]' \
 -e REGISTRY_HTTP_HEADERS_Access-Control-Max-Age='[1728000]' \
 -e REGISTRY_HTTP_HEADERS_Access-Control-Allow-Credentials='[true]' \
 -e REGISTRY_HTTP_HEADERS_Access-Control-Expose-Headers='["Docker-Content-Digest"]' \
 -e REGISTRY_STORAGE_DELETE_ENABLED=true \
 registry:2
```

# Start the UI container

```bash
docker run -d \
 -p 8080:80 \
 -e REGISTRY_URL=http://localhost:5001 \
 -e DELETE_IMAGES=true \
 -e REGISTRY_SECURE=false \
 joxit/docker-registry-ui:latest
```

# tag and push the images

```bash
❯ docker tag yuvaldev localhost:5001/yuvaldev:latest
docker push localhost:5001/yuvaldev:latest
```
