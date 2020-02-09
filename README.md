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
