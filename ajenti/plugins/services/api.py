from ajenti.api import *
from ajenti.util import cache_value


@plugin
class ServiceMultiplexor (object):
    def init(self):
        self.managers = ServiceManager.get_all()

    @cache_value(1)
    def get_all(self):
        r = []
        for mgr in self.managers:
            r += mgr.get_all()
        return r

    def get_one(self, name):
        for s in self.get_all():
            if s.name == name:
                return s


@interface
class ServiceManager (object):
    def get_all(self):
        return []


class Service (object):
    source = 'unknown'

    def __init__(self):
        self.name = None
        self.running = False

    @property
    def icon(self):
        return 'play' if self.running else None

    def start(self):
        pass

    def stop(self):
        pass

    def restart(self):
        pass

    def command(self, cmd):
        pass
