#!/bin/sh
echo "Validating module-03" >> /tmp/progress.log

if ! runuser -u rhel -- podman image exists localhost/rhhi-demo:v1; then
    echo "FAIL: Image localhost/rhhi-demo:v1 not found" >> /tmp/progress.log
    echo "HINT: Complete module-02 first - run 'podman build -t rhhi-demo:v1 -f ~/sample-app/Containerfile ~/sample-app'" >> /tmp/progress.log
    exit 1
fi

runuser -u rhel -- podman run -d --rm --name demo-validate -p 8081:8080 rhhi-demo:v1

sleep 5

RESPONSE=$(curl -s http://localhost:8081/)

runuser -u rhel -- podman stop demo-validate

if echo "$RESPONSE" | grep -q "Hello"; then
    echo "PASS: Container started and responded with expected greeting" >> /tmp/progress.log
    exit 0
else
    echo "FAIL: Container did not return expected greeting response" >> /tmp/progress.log
    echo "HINT: Check 'podman logs demo' to see if the application started correctly." >> /tmp/progress.log
    echo "Response received: $RESPONSE" >> /tmp/progress.log
    exit 1
fi
