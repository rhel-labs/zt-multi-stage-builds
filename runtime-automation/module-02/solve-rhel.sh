#!/bin/sh
echo "Solving module-02: building rhhi-demo:v1" >> /tmp/progress.log
podman build -t rhhi-demo:v1 -f /home/rhel/sample-app/Containerfile /home/rhel/sample-app
echo "Build complete" >> /tmp/progress.log
