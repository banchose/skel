from http.server import *

class Resp(BaseHTTPRequestHandler):
    def do_GET(self):
        self.wfile.write(b"""HTTP/1.1 200 OK
Content-Type: text/html
Location: localhost:8000

<html>
<head><title>Hello, world</title></head>
<body>Minimal page written in python</body>
</html>
""")


def run(server_class=HTTPServer, handler_class=BaseHTTPRequestHandler):
    server_address = ('', 8000)
    httpd = server_class(server_address, handler_class)
    httpd.serve_forever()

run(HTTPServer, Resp)
