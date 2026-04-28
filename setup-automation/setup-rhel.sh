#!/bin/bash
USER=rhel

echo "Adding wheel" > /root/post-run.log
usermod -aG wheel rhel

echo "Starting setup for zt-multi-stage-builds" > /tmp/progress.log

chmod 666 /tmp/progress.log

# Fetch setup files from this lab's repo
TMPDIR=/tmp/lab-setup-$$
git clone --single-branch --branch ${GIT_BRANCH:-main} --no-checkout \
  --depth=1 --filter=tree:0 ${GIT_REPO} $TMPDIR
git -C $TMPDIR sparse-checkout set --no-cone /setup-files
git -C $TMPDIR checkout
SETUP_FILES=$TMPDIR/setup-files

# Install Java
dnf install -y java-21-openjdk-devel
echo "Java installed" >> /tmp/progress.log

# Install quarkus CLI via jbang as rhel user
cat > /tmp/quarkus-install.sh <<'QEOF'
curl -Ls https://sh.jbang.dev | bash -s - trust add https://repo1.maven.org/maven2/io/quarkus/quarkus-cli/
curl -Ls https://sh.jbang.dev | bash -s - app install --fresh --force quarkus@quarkusio
if ! grep -q '.jbang/bin' ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$HOME/.jbang/bin:$PATH"' >> ~/.bashrc
fi
QEOF
chmod +x /tmp/quarkus-install.sh
su -l rhel -c /tmp/quarkus-install.sh
echo "Quarkus CLI installed" >> /tmp/progress.log

# Scaffold Quarkus project as rhel user
su -l rhel -c "~/.jbang/bin/quarkus create app com.example:sample-app \
  --extension='rest,rest-jackson' --no-code 2>/dev/null || \
  /home/rhel/.jbang/bin/quarkus create app com.example:sample-app \
  --extension='rest,rest-jackson' --no-code"
echo "Quarkus project scaffolded" >> /tmp/progress.log

# Copy custom application files
mkdir -p /home/rhel/sample-app/src/main/java/com/example
cp $SETUP_FILES/quarkus/GreetingResource.java \
  /home/rhel/sample-app/src/main/java/com/example/
cp $SETUP_FILES/quarkus/application.properties \
  /home/rhel/sample-app/src/main/resources/
cp $SETUP_FILES/quarkus/Containerfile /home/rhel/sample-app/
cp $SETUP_FILES/quarkus/.dockerignore /home/rhel/sample-app/
chmod a+x /home/rhel/sample-app/mvnw
chmod -R a+rX /home/rhel/sample-app/.mvn/ /home/rhel/sample-app/src/
chmod a+r /home/rhel/sample-app/pom.xml
echo "Application files configured" >> /tmp/progress.log

# Pull builder and runtime images into rhel's rootless store
su -l rhel -c "podman pull registry.access.redhat.com/hi/openjdk:21-builder"
su -l rhel -c "podman pull registry.access.redhat.com/hi/openjdk:21-runtime"
echo "Images pulled" >> /tmp/progress.log

# Pre-warm Maven cache inside builder container (critical for fast participant builds)
su -l rhel -c "podman run --rm --net=host \
  -v /home/rhel/sample-app:/build:Z -w /build \
  registry.access.redhat.com/hi/openjdk:21-builder \
  ./mvnw dependency:resolve -q"
echo "Maven cache warmed" >> /tmp/progress.log

rm -rf $TMPDIR /tmp/quarkus-install.sh
chown -R rhel:rhel /home/rhel

echo "Setup complete" >> /tmp/progress.log
