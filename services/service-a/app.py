from flask import Flask, request
import os
import requests

app = Flask(__name__)
SERVICE_B_URL = os.environ.get("SERVICE_B_URL", "http://service-b:5000")

@app.route("/")
def index():
    r = requests.get(f"{SERVICE_B_URL}/info")
    return {"service": "service-a", "downstream": r.json()}, 200

@app.route("/info")
def info():
    return {"service": "service-a", "message": "hello from service-a"}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
