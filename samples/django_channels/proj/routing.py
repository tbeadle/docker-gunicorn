from channels.routing import route

channel_routing = [
    route('websocket.receive', 'app.consumers.websocket_receive'),
]
