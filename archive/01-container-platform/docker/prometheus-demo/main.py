from flask import Flask
from prometheus_client import Counter, make_wsgi_app, start_http_server
from werkzeug.middleware.dispatcher import DispatcherMiddleware

app = Flask(__name__)

REQUESTS = Counter("car_requests", "Number of car requests")

app.wsgi_app = DispatcherMiddleware(app.wsgi_app, {
    '/metrics': make_wsgi_app()
})


@app.get("/")
def root():
    return "Welcome to the Car API"


@app.get("/cars")
def get_cars():
    REQUESTS.inc()
    return ["toyota", "honda", "mazda", "lexus"]


@app.get("/cars/<int:id>")
def get_car():
    REQUESTS.inc()
    return "Single car"


@app.post("/cars")
def create_cars():
    REQUESTS.inc()
    return "Create Car"


@app.patch("/cars/<int:id>")
def update_cars():
    REQUESTS.inc()
    return "Updating Car"


@app.delete("/cars/<int:id>")
def delete_cars():
    REQUESTS.inc()
    return "Deleting Car"


if __name__ == '__main__':
    start_http_server(8000)
    app.run(host="0.0.0.0", port=3000)
