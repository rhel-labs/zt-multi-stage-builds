#!/bin/sh
echo "Validating module-01" >> /tmp/progress.log

if [ ! -f /home/rhel/sample-app/Containerfile ]; then
    echo "FAIL: ~/sample-app/Containerfile not found"
    echo "HINT: The setup may not have completed. Check /tmp/progress.log for details."
    exit 1
fi

if [ ! -f /home/rhel/sample-app/mvnw ]; then
    echo "FAIL: ~/sample-app/mvnw not found"
    echo "HINT: The Quarkus project scaffold may be incomplete. Check /tmp/progress.log for details."
    exit 1
fi

echo "PASS: sample-app directory contains Containerfile and mvnw"
exit 0
