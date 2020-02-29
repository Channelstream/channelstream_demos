# Use an official Python runtime as a parent image
FROM node:13.8.0-buster-slim AS static
# why do I need python to install nodejs reqs? python 2 at that :/
RUN apt update; apt install python3 make build-essential -y

ENV PATH $PATH:env/bin
ENV PYTHON python3
COPY chat/frontend /opt/frontend
WORKDIR /opt/frontend
RUN yarn
RUN yarn build
COPY docker-entrypoint-static.sh /opt/docker-entrypoint-static.sh
# throw away the js container
# Use an official Python runtime as a parent image
FROM python:3.7.6-slim-stretch

# Set the working directory to /opt/application
WORKDIR /opt/application

# create application user
RUN useradd --create-home application

RUN chown -R application /opt/application
RUN mkdir /opt/rundir
RUN chown -R application /opt/rundir
RUN mkdir /opt/venv
RUN chown -R application /opt/venv
RUN mkdir /opt/rundir/static
RUN chown -R application /opt/rundir/static
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
COPY chat /opt/application

# copy pre-built js
COPY --from=static /opt/static /opt/application/static
# Make port 6543 available to the world outside this container
EXPOSE 6543
VOLUME /opt/rundir
ENTRYPOINT ["/opt/docker-entrypoint.sh"]
ENV CHANNELSTREAM_URL "http://127.0.0.1:8000"
ENV CHANNELSTREAM_WS_URL "http://127.0.0.1:8000/ws"
ENV CHANNELSTREAM_SECRET secret
ENV CHANNELSTREAM_ADMIN_SECRET admin_secret
# Run application when the container launches
CMD /opt/venv/bin/python app.py --channelstream-url=$CHANNELSTREAM_URL \
--channelstream-ws-url=$CHANNELSTREAM_WS_URL --channelstream-secret=$CHANNELSTREAM_SECRET \
--channelstream-admin-secret=$CHANNELSTREAM_ADMIN_SECRET
