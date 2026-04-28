#!/bin/sh
echo "Solving module-03: run, test, and verify rhhi-demo:v1" >> /tmp/progress.log

# Start the container
podman run -d --rm --name demo -p 8080:8080 rhhi-demo:v1

# Wait briefly for startup
sleep 5

# Test the greeting endpoint
curl -s http://localhost:8080/ | jq

# Test the health endpoint
curl -s http://localhost:8080/health | jq

# View container logs
podman logs demo

# Stop the container (--rm removes it automatically)
podman stop demo

# Compare image sizes
podman images registry.access.redhat.com/hi/openjdk
podman images rhhi-demo

echo "Module-03 solve complete" >> /tmp/progress.log
