# Use an official Python runtime as a parent image
FROM node:22-bookworm-slim AS static
# Vite/esbuild ship prebuilt binaries, so we no longer need python/make/gcc
# for native node-gyp builds. We still need gosu for the dev entrypoint
# that drops privileges to the `application` user.
RUN apt-get update && apt-get install -y \
    gosu \
 && rm -rf /var/lib/apt/lists/*
# we do not want node to run as id 1000
RUN groupmod -g 999 node && usermod -u 999 -g 999 node
RUN useradd --create-home application
USER application
COPY --chown=application chat /opt/application
WORKDIR /opt/frontend
ENV FRONTEND_ASSSET_ROOT_DIR /opt/application/static
RUN cd /opt/application/frontend; npm install
RUN cd /opt/application/frontend; npm run build
# throw away the js container
# Use an official Python runtime as a parent image
FROM python:3.13-slim-bookworm

RUN apt-get update && apt-get install -y \
    gosu \
 && rm -rf /var/lib/apt/lists/*

# Set the working directory to /opt/application
WORKDIR /opt/application

# create application user
RUN useradd --create-home application

RUN chown -R application /opt/application
RUN mkdir /opt/venv
RUN chown -R application /opt/venv

# Copy the current directory contents into the container at /opt/application
COPY chat/requirements.txt /tmp/requirements.txt

# change to non-root user

USER application

RUN python -m venv /opt/venv
# Install any needed packages specified in requirements.txt
RUN /opt/venv/bin/pip install --disable-pip-version-check --trusted-host pypi.python.org -r /tmp/requirements.txt --no-cache-dir
# make application scripts visible
ENV PATH $PATH:/opt/venv/bin
# Copy the current directory contents into the container at /opt/application
COPY docker-entrypoint.sh /opt/docker-entrypoint.sh
COPY --chown=application chat /opt/application
# Overlay the freshly built JS bundle on top of any stale committed assets
# in chat/static, so the image always serves the bundle from this build.
COPY --from=static --chown=application /opt/application/static /opt/application/static

# Make port 6543 available to the world outside this container
EXPOSE 6543
VOLUME /opt/rundir
USER root
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
# Run application when the container launches
ENV CHANNELSTREAM_URL "http://127.0.0.1:8000"
ENV CHANNELSTREAM_WS_URL "http://127.0.0.1:8000/ws"
ENV CHANNELSTREAM_SECRET secret
ENV CHANNELSTREAM_ADMIN_SECRET admin_secret
ENV DEMO_PORT 6543
CMD /opt/venv/bin/python app.py --channelstream-url=$CHANNELSTREAM_URL \
--channelstream-ws-url=$CHANNELSTREAM_WS_URL --channelstream-secret=$CHANNELSTREAM_SECRET \
--channelstream-admin-secret=$CHANNELSTREAM_ADMIN_SECRET --demo-port=$DEMO_PORT
