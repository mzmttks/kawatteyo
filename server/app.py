import time
import tornado.ioloop
import tornado.web
import tornado.websocket
from tornado.ioloop import PeriodicCallback
import pprint

from tornado.options import define, options, parse_command_line
import uuid

define("port", default=8080, help="run on the given port", type=int)

channels = {}

class ChannelHandler(tornado.web.RequestHandler):
    @tornado.web.asynchronous
    def get(self):
        channelid = str(uuid.uuid1())
        channels[channelid] = []
        self.write(channelid)
        self.finish()

    @tornado.web.asynchronous
    def post(self, chid):
        username = self.get_body_argument("username", None)
        print chid
        print username
        if username is None:
            self.set_status(400)
            self.finish("username is not given")
            return
        if not chid in channels:
            self.set_status(400)
            self.finish("Channel ID is not found")
            return
        if username in channels[chid]:
            self.set_status(400)
            self.finish("username already exists")
            return

        pprint.pprint(channels)
        self.finish()


class StaticHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("index.html")


class SendWebSocket(tornado.websocket.WebSocketHandler):
    def open(self, chid=None, user=None):
        self.chid = chid
        self.user = user
        if chid not in channels:
            return
        if user in [c[0] for c in channels[chid]]:
            return
        if self not in channels[chid]:
            channels[chid].append([user, self])
        print "[open]"
        pprint.pprint(channels)
        
    def on_message(self, message):
        for con in channels[self.chid]:
            try:
                print "on_message", con[1]
                con[1].write_message(message)
            except:
                channels[self.chid].remove([self.user, con])
    
    def on_connection_close(self):
        if self in [c[1] for c in channels[self.chid]]:
            channels[self.chid].remove([self.user, self])
            self.close()

app = tornado.web.Application([
    (r"/", StaticHandler),
    (r"/channels/(.*)/(.*)/socket", SendWebSocket),
    (r"/channels/(.*)", ChannelHandler),
    (r"/socket.io/", SendWebSocket),
    (r"/channels", ChannelHandler),
])

if __name__ == "__main__":
    parse_command_line()
    app.listen(options.port)
    tornado.ioloop.IOLoop.instance().start()
