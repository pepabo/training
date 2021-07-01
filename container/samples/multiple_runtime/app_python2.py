from BaseHTTPServer import HTTPServer
from BaseHTTPServer import BaseHTTPRequestHandler
import urlparse



class CallbackServer(BaseHTTPRequestHandler):
    def __init__(self, callback, *args):
        self.callback = callback
        BaseHTTPRequestHandler.__init__(self, *args)

    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        result = {'Hello world!': 'hahaha!'}.keys()
        self.wfile.write(result)
        return

    @classmethod
    def start(self, port, callback):
        def handler(*args):
            CallbackServer(callback, *args)
        server = HTTPServer(('', int(port)), handler)
        server.serve_forever()

def callback_method(query):
    return {'Hello world!': 'hahaha!'}.keys()

if __name__ == '__main__':
    port = 8800
    CallbackServer.start(port, callback_method)
