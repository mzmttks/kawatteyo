import time
import tornado.ioloop
import tornado.web
import tornado.websocket
from tornado.ioloop import PeriodicCallback

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

        channels[chid].append(username)
        self.finish()


class StaticHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("index.html")

class SendWebSocket(tornado.websocket.WebSocketHandler):
    def open(self, username):
        self.i = 0
        print username
        print "aaa"
        
    def on_message(self, message):
        print message
        self.write_message(message)
    
    def on_close(self):
        print "WebSocket closed"

app = tornado.web.Application([
    (r"/", StaticHandler),
    (r"/channels/(.*)/socket", SendWebSocket),
    (r"/channels", ChannelHandler),
    (r"/channels/(.*)", ChannelHandler),
])

if __name__ == "__main__":
    parse_command_line()
    app.listen(options.port)
    tornado.ioloop.IOLoop.instance().start()