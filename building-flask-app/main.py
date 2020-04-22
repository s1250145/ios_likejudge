import pyApp # pyApp.py

import json
import requests

from flask import jsonify, request, Flask
from flask_cors import CORS

myapp = Flask(__name__)
CORS(myapp)

@myapp.route("/graph", methods=['GET'])
def api_get():
    # quel string
    # url=<image_url>&q=<hashtag name>
    user_img_url = request.args.get('url') #binary data from swift
    name = request.args.get('q')

    graph_api_result = pyApp.call_graph(name)
    res = pyApp.main(graph_api_result, user_img_url)

    # return highest ssim rate
    return jsonify(res)


@myapp.route("/graph/getLike", methods=['POST'])
def my_api():
    user_img_url = request.json['url']
    name = request.json['q']

    graph_api_result = pyApp.call_graph(name)
    res = pyApp.main(graph_api_result, user_img_url)

    return res


# For test
@myapp.route("/")
def open():
    return "Hello, My Flask APP!"


if __name__ == "__main__":
    myapp.run(host='127.0.0.1', port=8080, debug=True) # run server
