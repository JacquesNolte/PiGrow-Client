#!/bin/bash
set -e

# Your server's local network IP address
SERVER_IP="192.168.0.105" 
REGISTRY_TAG="$SERVER_IP:5001/pi-grow-client:latest"
BUILDER_NAME="mybuilder"
CONFIG_FILE="./buildkitd.toml"

echo "📝 Creating physical BuildKit configuration file on your drive..."
# Write a strict TOML file that forces Buildx to use HTTP for your server IP
cat <<EOF > $CONFIG_FILE
[registry."$SERVER_IP:5001"]
  http = true
  insecure = true
EOF

echo "📦 Clearing and re-initializing the Docker Buildx instance..."
# Forcefully clear old builder states
if docker buildx inspect $BUILDER_NAME >/dev/null 2>&1; then
  docker buildx rm $BUILDER_NAME
fi

# Create the builder referencing the actual TOML file on disk
docker buildx create --name $BUILDER_NAME \
  --config $CONFIG_FILE \
  --use --bootstrap

echo "🚀 Cross-compiling ARM64 image for the Raspberry Pi..."
docker buildx build \
  --no-cache \
  --platform linux/arm64 \
  -t $REGISTRY_TAG \
  --push .

echo "│"
echo "✅ Success! Image built and pushed safely over HTTP to: $REGISTRY_TAG"

# Clean up the configuration file afterwards
rm -f $CONFIG_FILE
