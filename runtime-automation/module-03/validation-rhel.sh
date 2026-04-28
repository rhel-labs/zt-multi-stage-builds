#!/bin/sh
echo "Validating module-03" >> /tmp/progress.log

# Ensure we have the image to test with
if ! podman image exists localhost/rhhi-demo:v1; then
    echo "FAIL: Image localhost/rhhi-demo:v1 not found"
    echo "HINT: Complete module-02 first - run 'podman build -t rhhi-demo:v1 -f ~/sample-app/Containerfile ~/sample-app'"
    exit 1
fi

# Start the container for validation
podman run -d --rm --name demo-validate -p 8081:8080 rhhi-demo:v1

# Wait for startup
sleep 5

# Test the greeting endpoint
RESPONSE=$(curl -s http://localhost:8081/)

# Stop validation container
podman stop demo-validate

# Check for expected content
if echo "$RESPONSE" | grep -q "Hello"; then
    echo "PASS: Container started and responded with expected greeting"
    exit 0
else
    echo "FAIL: Container did not return expected greeting response"
    echo "HINT: Check 'podman logs demo' to see if the application started correctly."
    echo "Response received: $RESPONSE"
    exit 1
fi
