#!/bin/sh
echo "Solving module-02: building rhhi-demo:v1" >> /tmp/progress.log

runuser -l rhel << 'RHEL_EOF'
podman build -t rhhi-demo:v1 -f /home/rhel/sample-app/Containerfile /home/rhel/sample-app
podman images rhhi-demo
RHEL_EOF

echo "Build complete" >> /tmp/progress.log
