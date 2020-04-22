import json
import requests
import flask
from flask import jsonify, request
from flask_cors import CORS
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
import re
from skimage import measure
import cv2 # OpenCV
import io
from io import BytesIO
import os
import base64

access_token = "EAAQLlj7F35QBAEJnmQzadKQGEbnEcPAmh25eQGfP8ZCnZA5sLOeLZClOreoBggkpZCZCM3D6mlA6RJC0VKr0YCiegd8EBdwoZBRzM2ZCbAyBlnce31VHMCVCg57n6ahw3oez48j9b4FzxKoudTUuvVSkGr4xNVCpK6M7Q7GwNxOPJo5ccVKbaJni6BW8kt75qIZD"
user_id = "17841401926936401"

def call_graph(qname):
    api_url = "https://graph.facebook.com/ig_hashtag_search?user_id={id}&access_token={token}&q={name}"
    url = api_url.format(id=user_id, token=access_token, name=qname)
    result = requests.get(url)

    data = json.loads(result.text)
    hashtag_id = data['data'][0]['id']

    api_url = "https://graph.facebook.com/{h_id}/top_media?user_id={id}&access_token={token}&limit=20&fields=media_type,media_url,like_count"
    url = api_url.format(h_id=hashtag_id, id=user_id, token=access_token)
    result = requests.get(url)

    data = json.loads(result.text)

    return data


def main(data, user_url):
    # binary2image
    img = Image.open(io.BytesIO(base64.b64decode(user_url)))
    user_img = img.resize((400, 400), Image.ANTIALIAS)
    original = user_img.convert('L')

    max = 0.0
    idx = 0
    # resize & get ssim
    for i in range(20): # 0 to 19
        if data['data'][i]['media_type'] != "IMAGE":
            continue
        img = resize(data['data'][i]['media_url'])
        img = img.resize((400, 400), Image.ANTIALIAS)
        target = img.convert('L')
        ssim = compare_images(target, original)

        if ssim == 1.0:
            continue;
        if max < ssim:
            max = ssim
            idx = i
        
    text = "You may get {result} likes!"
    res = text.format(result = int(max*int(data['data'][idx]['like_count'])))
    return res


def resize(url):
    img = Image.open(io.BytesIO(requests.get(url).content))
    before_x, before_y = img.size[0], img.size[1]

    x = int(round(float(400 / float(before_y) * float(before_x))))
    y = 400
    resize_img = img
    resize_img.thumbnail((x, y), Image.ANTIALIAS)
    return resize_img


def pil2cv(image):
    new_image = np.array(image, dtype=np.uint8)
    return new_image


def compare_images(imageA, imageB):
    m = mse(imageA, imageB)
    imageA = pil2cv(imageA)
    imageB = pil2cv(imageB)
    s = measure.compare_ssim(imageA, imageB)
    return s


def mse(imageA, imageB):
    imageA_f = np.asarray(imageA).astype("f")
    imageB_f = np.asarray(imageB).astype("f")
    err = np.sum((imageA_f - imageB_f) ** 2)
    err /= float(imageA.height * imageA.width)
    return err
