import os
import json
from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/', methods=['GET'])
def get_files():
    return os.listdir("/mnt/efs")

@app.route('/<string:id>/<string:filename>', methods=['GET'])
def get_file(id,filename):
    if os.path.isfile("/mnt/efs/" + id + "-" + filename):
        return jsonify(Operation="The file exists !"), 200
    else:
        return jsonify(Operation="The file is not exist !"), 400

@app.route('/', methods=['DELETE'])
def delete_file():
    try:
        json_data=json.loads(request.data)
        os.remove("/mnt/efs/" + json_data["id"] + "-" + json_data["file"])
        return jsonify(Operation="The file is deleted successfully ! - " +
                       json_data["id"] + "-" + json_data["file"]), 204
    except:
        return jsonify(Operation="The file is not found or not exist ? - " +
                       json_data["id"] + "-" + json_data["file"]), 400
        
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
