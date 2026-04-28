#!/bin/sh
echo "Validating module-02" >> /tmp/progress.log

if ! podman image exists localhost/rhhi-demo:v1; then
    echo "FAIL: Image localhost/rhhi-demo:v1 not found"
    echo "HINT: Run 'podman build -t rhhi-demo:v1 -f ~/sample-app/Containerfile ~/sample-app' to build the image."
    exit 1
fi

echo "PASS: Image localhost/rhhi-demo:v1 exists"
exit 0
