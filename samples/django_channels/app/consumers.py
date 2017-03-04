def websocket_receive(message):
    message.reply_channel.send({
        'text': '{} reversed is {}'
        .format(message.content['text'],
                ''.join(reversed(message.content['text']))),
    })
