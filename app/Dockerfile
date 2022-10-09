# Python image to use
FROM alpine:latest
 

RUN apk add py3-pip
RUN pip3 install flask

# Set the working directory to /app
WORKDIR /app
 
# Copy the requirements file used for dependencies
COPY requirements.txt .
 
# Install the needed packages specified in requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt
 
# Copy rest of the working directory contents into the container at /app
COPY . .

EXPOSE 80

CMD ["--host=0.0.0.0", "--port=80"]

# Run app.py when the container launches
ENTRYPOINT ["python3", "main.py"]