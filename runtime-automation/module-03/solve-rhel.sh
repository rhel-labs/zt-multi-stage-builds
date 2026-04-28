#!/bin/sh
echo "Solving module-03: run, test, and verify rhhi-demo:v1" >> /tmp/progress.log

runuser -l rhel << 'RHEL_EOF'
podman run -d --rm --name demo -p 8080:8080 rhhi-demo:v1
sleep 5
curl -s http://localhost:8080/ | jq
curl -s http://localhost:8080/health | jq
podman logs demo
podman stop demo
podman images registry.access.redhat.com/hi/openjdk
podman images rhhi-demo
RHEL_EOF

echo "Module-03 solve complete" >> /tmp/progress.log
