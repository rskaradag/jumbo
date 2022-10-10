import json
import os
from botocore.session import Session
from botocore.config import Config

s = Session()
sqs = s.create_client('sqs', config=Config(connect_timeout=5, read_timeout=60, retries={'max_attempts': 2}))

def lambda_handler(event, context):
    print(event)
    #messages=sqs.receive_message(QueueUrl=os.environ["QUEUE_URL"],MaxNumberOfMessages=10, WaitTimeSeconds=20, MessageAttributeNames=['All'])
    #print(messages)
    for item in event["Records"]:
        body=json.loads(item["body"])
        os.system("echo 'SQSFILE' >> " + os.environ["EFS_PATH"] + "/" + body["id"] + "-" + body["file"])
        print("file is created - " + os.environ["EFS_PATH"] + "/" + body["id"] + "-" + body["file"])
         
        print(item["receiptHandle"])
        delete_message(item["receiptHandle"])

    return {
        'message' : 'OK'
        }

def delete_message(receiptHandle):
    print('delete_receipt - ' + str(receiptHandle))
    print(os.environ["QUEUE_URL"])
    delete= sqs.delete_message(QueueUrl=os.environ["QUEUE_URL"], ReceiptHandle=receiptHandle) 
    print('message is deleted - ' + str(delete))