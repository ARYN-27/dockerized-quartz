#!/bin/bash

DEFAULT_REPO="https://github.com/jackyzha0/quartz.git"
QUARTZ_DIR="/usr/src/app/quartz"
AUTO_REBUILD=${AUTO_REBUILD:-true}

handle_error() {
  echo "Error: $1"
  exit 1
}

# Check if the /etc/nginx directory is empty
if [ ! "$(ls -A /etc/nginx)" ]; then
    echo "/etc/nginx is empty. Copying default configuration..."
    cp -r /etc/nginx_default/* /etc/nginx/
else
    echo "/etc/nginx already contains configuration. Skipping copy..."
fi

# Check if the user provided a custom repo via an environment variable
if [ -z "$GIT_REPO" ]; then
  echo "No custom Quartz repository provided. Using default: $DEFAULT_REPO"
  REPO=$DEFAULT_REPO
else
  echo "Cloning custom Quartz repository: $GIT_REPO"
  REPO=$GIT_REPO
fi

git config --global --add safe.directory /usr/src/app/quartz

# Check if the quartz directory is already present and not empty
if [ -d "$QUARTZ_DIR" ] && [ "$(ls -A $QUARTZ_DIR)" ]; then
  echo "Quartz directory already exists. Skipping pull..."
else
  echo "Cloning the Quartz repository into $QUARTZ_DIR..."
  git clone $REPO $QUARTZ_DIR

  # Check if there's a custom branch to checkout
  if [ -n "$GIT_BRANCH" ]; then
    echo "Checking out custom branch: $GIT_BRANCH"
    cd $QUARTZ_DIR && git checkout $GIT_BRANCH
  fi
fi

# Install dependencies for Quartz
echo "Installing npm dependencies..."
cd $QUARTZ_DIR
npm install || handle_error "npm install failed. Check your Node.js version or package.json dependencies."

npm audit fix

/usr/src/app/scripts/build-quartz.sh

nginx -g 'daemon off;' &

# If AUTO_REBUILD is true, hand off to the watch-and-build script
if [ "$AUTO_REBUILD" = true ]; then
  echo "Auto rebuild is enabled. Starting watch-and-build script..."
  /usr/src/app/scripts/watch-and-build-quartz.sh
else
  echo "Auto rebuild is disabled."
fi

# Check if REBUILD_WEBHOOK_SECRET is set
if [ -n "$REBUILD_WEBHOOK_SECRET" ]; then
    echo "Starting webhook server..."
    cd /usr/src/app
    node server.js &
else
    echo "Skipping webhook server startup (REBUILD_WEBHOOK_SECRET is not set)."
fi

wait -n