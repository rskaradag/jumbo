import logging
import os
import json
 
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/', methods=['GET'])
def get_files():
    return os.listdir("/mnt/efs") 

@app.route('/', methods=['DELETE'])
def delete_file():
    try:
        jsonData=json.loads(request.data)
        os.remove("/mnt/efs/" + jsonData["id"] + "-" + jsonData["file"]) 
        return jsonify(Operation="The file is deleted successfully - " + jsonData["id"] + "-" + jsonData["file"]), 204
    except:
        return jsonify(Operation="The file is not found or not exist - " + jsonData["id"] + "-" + jsonData["file"]), 400
   
 
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)