import json
import os
import boto3

sqs = boto3.client('sqs')

def lambda_handler(event, context):
    for item in event["Records"]:
        body=json.loads(item["body"])
        os.system("echo 'SQSFILE' >> " + os.environ["EFS_PATH"] + "/" + body["id"] + "-" + body["file"])
        print("file is created - " + os.environ["EFS_PATH"] + "/" + body["id"] + "-" + body["file"])
        
        delete_message(item["receiptHandle"])

    return {
        'message' : 'OK'
        }

def delete_message(receiptHandle):
    delete= sqs.delete_message(QueueUrl=os.environ["QUEUE_URL"], ReceiptHandle=receiptHandle) 
    print('message is deleted - ' + str(delete))