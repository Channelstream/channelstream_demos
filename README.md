# Demos

This repository provides demonstrative applications on how to connect with the server
and send information to clients.

All demos assume you have Channelstream running with default secrets and ports.

You have a simple notification demo built on flask:

    cd notification/
    
    YOUR_PYTHON_ENV/bin/pip install -r requirements.txt
    YOUR_PYTHON_ENV/bin/flask run

Now you can open multiple browser windows to http://127.0.0.1:5000/ and test notifications.

There is also more complex chat application demo included, it showcases
multiple channel subscriptions, message edits and user state changing.

    YOUR_PYTHON_ENV/bin/pip install -r requirements.txt
    YOUR_PYTHON_ENV/bin/python chat/app.py

Open your browser and point it to following url:

    http://127.0.0.1:6543

# Using docker compose

    docker-compose up

    # for live reload
    USER_UID=`id -u` USER_GID=`id -g` docker-compose -f docker-compose.yml -f docker-compose.dev.yml up


# Using docker manually

    # start the main server
    docker run --rm -p 8000:8000 -e CHANNELSTREAM_ALLOW_POSTING_FROM=0.0.0.0 channelstream/channelstream:latest
    
    # build the demo
    docker build . -t channelstream_demo
    
    # start the demo
    docker run -ti --rm -p 6543:6543 -e CHANNELSTREAM_URL=http://172.17.0.2:8000 channelstream_demo

# Manual development with reload

    # start the main server
    docker run --rm -p 8000:8000 -e CHANNELSTREAM_ALLOW_POSTING_FROM=0.0.0.0 channelstream/channelstream:latest
    
    # build the image for landing page backend
    docker build . -t channelstream_demo
    
    # run the backend code with hot reload
    docker run -ti --rm -p 6543:6543 -e USER_UID=`id -u` -e USER_GID=`id -g` \
    -e CHANNELSTREAM_URL=http://172.17.0.2:8000 \
    --mount type=bind,source="$(pwd)"/chat,target=/opt/application \
    --mount type=bind,source="$(pwd)"/chat/static,target=/opt/application/static \
    channelstream_demo
    
    # build frontend code builder image
    docker build . -f Dockerfile.static -t channelstream_demo_statics
    
    # run the frontend code with hot reload
    docker run -ti --rm -e USER_UID=`id -u` -e USER_GID=`id -g` \
    -e FRONTEND_ASSSET_ROOT_DIR=/opt/application/static \
    --mount type=bind,source="$(pwd)"/chat,target=/opt/application \
    --mount type=bind,source="$(pwd)"/chat/static,target=/opt/application/static \
    channelstream_demo_statics
