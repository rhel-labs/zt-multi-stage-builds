#!/bin/sh
echo "Validating module-03" >> /tmp/progress.log

if ! runuser -u rhel -- podman image exists localhost/rhhi-demo:v1 2>/dev/null; then
    echo "FAIL: Image rhhi-demo:v1 not found" >> /tmp/progress.log
    echo "HINT: Complete module 2 first to build the rhhi-demo:v1 image" >> /tmp/progress.log
    exit 1
fi

runuser -u rhel -- podman run -d --rm --name demo-validate -p 8081:8080 rhhi-demo:v1 2>/dev/null
sleep 5

RESPONSE=$(curl -s http://localhost:8081/)
runuser -u rhel -- podman stop demo-validate 2>/dev/null

if echo "$RESPONSE" | grep -q "Hello"; then
    echo "PASS: Container started and responded with expected greeting" >> /tmp/progress.log
    exit 0
else
    echo "FAIL: Container did not return expected response" >> /tmp/progress.log
    echo "HINT: The container started but didn't return the expected greeting - is the application running correctly?" >> /tmp/progress.log
    exit 1
fi
