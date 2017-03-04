import os
# Don't populate ROUTING when running daphne.  It's not needed for daphne and
# in fact, we don't want daphne to try to load the application.
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'asgi_redis.RedisChannelLayer',
        'ROUTING':
            'proj.routing.channel_routing'
            if 'SECRET_KEY' in os.environ
            else [],
        'CONFIG': {
            'hosts': [(os.environ.get('REDIS_HOST', 'redis'), 6379)],
        },
    },
}

# These will get overridden in settings.py but are necessary for daphne to be
# able to start.  django.setup() requires that they be set.
DEBUG = False
LOGGING = {}
SECRET_KEY = 'secret'
