import logging
import os
 
from flask import Flask

app = Flask(__name__)


@app.route('/', methods=['GET'])
def upload_files():
    return os.listdir("/mnt/fs") 
 
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)