import json
import logging
import boto3
from datetime import datetime as dt

logger = logging.getLogger('MyLogger')
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    s3_bucket_name, s3_object_name = get_object_path(event['Records'])
    logger.info('content checked')
    logger.info(f'content checked:{dt.now().isoformat()}')
    logger.info(f'Bucket is {s3_bucket_name}')
    logger.info(f'Object key is {s3_object_name}')
    # logger.info(f'Content checked: {s3.list_buckets()["Buckets"]} ')
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from scheduled Lambda!')
    }

def get_object_path(records):
    """Extracts bucket and object references from Records field of event."""
    return records[0]['s3']['bucket']['name'], \
        records[0]['s3']['object']['key']