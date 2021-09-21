from http.server import HTTPServer, BaseHTTPRequestHandler


class CallbackHandler(BaseHTTPRequestHandler):
    def __init__(self, *args):
        BaseHTTPRequestHandler.__init__(self, *args)

    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        result = {'Hello world!': 'hahaha!'}.keys()
        self.wfile.write(str(list(result)).encode('utf-8'))
        return


host = '0.0.0.0'
port = 8800
server = HTTPServer((host, port), CallbackHandler)
server.serve_forever()
