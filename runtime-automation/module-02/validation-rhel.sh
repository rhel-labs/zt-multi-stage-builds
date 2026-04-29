#!/bin/sh
echo "Validating module-02" >> /tmp/progress.log

if ! runuser -u rhel -- podman image exists localhost/rhhi-demo:v1 2>/dev/null; then
    echo "FAIL: Image localhost/rhhi-demo:v1 not found" >> /tmp/progress.log
    echo "HINT: Did you complete Step 3 to build the rhhi-demo:v1 image?" >> /tmp/progress.log
    exit 1
fi

echo "PASS: Image localhost/rhhi-demo:v1 exists" >> /tmp/progress.log
exit 0
