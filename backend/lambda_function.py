import json
import boto3
import os
import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE_NAME'])

def lambda_handler(event, context):
    try:
        #parse the event
        body = json.loads(event.get('body','{}'))
        email = body.get('email')
        name = body.get('name')
        query = body.get('query')


        if not email or not query:
            return {
                'statusCode' : 400,
                'headers' : {
                    'Content-Type' : 'application/json',
                    'Access-Control-Allow-Origin' : '*'
                },
                'body' : json.dumps({'error': 'Email and message are required'})
            }
        timestamp = datetime.datetime.utcnow().isoformat()
        item = {
            'email': email,
            'name': name,
            'query': query,
            'timestamp': timestamp
        }
        table.put_item(Item=item)
        return {
            'statusCode' : 200,
            'headers' : {
                'Content-Type' : 'application/json',
                'Access-Control-Allow-Origin' : '*'
            },
            'body': json.dumps(item)
        }
    except Exception as e:
        print(e)
        return {
            'statusCode' : 500,
            'headers' : {
                'Content-Type' : 'application/json',
                'Access-Control-Allow-Origin' : '*'
            },
            'body' : json.dumps({'error': str(e)})
        }

        