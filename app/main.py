import logging
import os.path
 
from flask import Flask, render_template, request, redirect, flash
from werkzeug.utils import secure_filename

logging.basicConfig(format='%(asctime)s:%(levelname)s:%(filename)s:%(funcName)s:%(message)s',
                    datefmt='%Y-%m-%d %H:%M:%S',
                    level=logging.INFO)
 
 
app = Flask(__name__)
app.secret_key = "somesecretkey"
 
app.config['ALLOWED_EXTENSIONS'] = ['.jpg', '.png']
app.config['MAX_CONTENT_LENGTH'] = 1024 * 1024
 
UPLOAD_FOLDER = os.path.join(os.getcwd(), 'uploads')
 
 
@app.route('/', methods=['GET'])
def index():
    logging.info('Showing index page')
    return render_template('upload.html')
 
 
@app.route('/', methods=['POST'])
def upload_files():
    logging.info('Starting file upload')
 
    if 'file' not in request.files:
        flash('No file part')
        return redirect(request.url)
 
    file = request.files['file']
    # obtaining the name of the destination file
    filename = file.filename
    if filename == '':
        logging.info('Invalid file')
        flash('No file selected for uploading')
        return redirect(request.url)
    else:
        logging.info('Selected file is= [%s]', filename)
        file_ext = os.path.splitext(filename)[1]
        if file_ext in app.config['ALLOWED_EXTENSIONS']:
            secure_fname = secure_filename(filename)
            logging.info('Secure filename is= [%s]', secure_fname)
            file.save(os.path.join(UPLOAD_FOLDER, secure_fname))
            logging.info('Upload is successful')
            flash('File uploaded successfully')
            return redirect('/')
        else:
            logging.info('Invalid file extension')
            flash('Not allowed file type')
            return redirect(request.url)
 
 

@app.route('/download', methods=['GET'])
def download():
    return 'Download file'
 
 
def check_upload_dir():
    if not os.path.exists(UPLOAD_FOLDER):
        os.makedirs(UPLOAD_FOLDER, exist_ok=True)
 
 
if __name__ == '__main__':
    check_upload_dir()
 
    server_port = os.environ.get('PORT', '80')
    app.run(debug=False, port=server_port, host='0.0.0.0')