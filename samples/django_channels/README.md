# Example of using Django Channels

This project is an example of using
[Django Channels](https://channels.readthedocs.io/en/stable/) for handling
WebSocket connections.

## Building the images

To build the images used by this example, simply run:

```bash
docker-compose build
```

## Running the image

To see the example in action, just run:

```bash
docker-compose up -d
```

Then add the following entry to your `/etc/hosts` file:

```
127.0.0.1    channels-demo
```

and point your web browser at http://channels-demo.

Using browser dev tools, you should be able to see that, when the page is
loaded, it opens a WebSocket connection.  You can then type in the text box and
click on the button.  It will send the text over the WebSocket and one of the
Django workers will process it, responding with the text reversed.  That will
get displayed in the browser.

## How it works

There are a few things that are unique to this example.

 - An NGINX config template extends the default one to include configuration
   that causes requests to /ws/ (`USER_WS_PATH`) to be proxied to a daphne
   server, running in a different container.
 - A [daphne](https://github.com/django/daphne) container is used to run the
   interface server to handle WebSocket connections and feed them to the channel
   backend.
 - A supervisord config template extends the default one to add the management
   of a number of Django worker processes that will handle the messages coming
   in from the WebSockets.

With this architecture:

 - nginx will directly respond to any static files requests.
 - Any requests to /ws/ will be proxied through to daphne as WebSocket
   connections.  Daphne works with the channel backend to communicate with the
   workers.
 - Any other requests will be handled by gunicorn.
