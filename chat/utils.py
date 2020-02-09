import json
import logging

import requests
from itsdangerous import TimestampSigner

log = logging.getLogger(__name__)


def ssl_rewriter(request, url):
    """
    rewrites server url based on http scheme
    :param request:
    :param url:
    :return:
    """
    environ = request.environ
    if (
        environ.get("HTTP_X_FORWARDED_PROTO") == "https"
        or environ.get("HTTP_X_FORWARDED_SSL") == "on"
    ):
        url = url.replace("http://", "https://").replace("ws://", "wss://")
    return url


def make_server_request(request, payload, endpoint, auth=None, method="post"):
    """
    makes a json request to channelstream server endpoint signing the request and sending the payload
    :param request:
    :param payload:
    :param endpoint:
    :param auth:
    :return:
    """
    channelstream_url = request.registry.settings["channelstream_url"]
    signer = TimestampSigner(request.registry.settings["secret"])
    sig_for_server = signer.sign("channelstream")
    secret_headers = {
        "x-channelstream-secret": sig_for_server,
        "Content-Type": "application/json",
    }
    url = "{url}{endpoint}".format(url=channelstream_url, endpoint=endpoint)
    response = getattr(requests, method)(
        url, data=json.dumps(payload), headers=secret_headers, auth=auth
    )
    if response.status_code >= 400:
        log.error(response.text)
    response.raise_for_status()
    return response


def send_welcome_message(request, username):
    """
    Sends a private message to specific channel to single user
    :param request:
    :param username:
    :return:
    """
    WELCOME_MESSAGE_TEXT = """
    This is a welcome message that you see upon creating connection/reconnection.
    Only you see it (it's not stored to history), and is only sent to your user.
    Open multiple tabs with this page to see real-time communication.

    <a href="https://github.com/Channelstream/channelstream/tree/master/demo/chat" target="_blank">See the source code for this application</a>
    """

    payload = {
        "type": "message",
        "user": "system",
        "channel": "pub_chan",
        "pm_users": [username],
        "no_history": True,
        "message": {"text": WELCOME_MESSAGE_TEXT},
    }
    make_server_request(request, [payload], "/message")
