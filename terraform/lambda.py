import json
import boto3

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('VisitorCount')

    res = table.update_item(
        Key={
            'Site': "Resume"
        },
        
        UpdateExpression="SET VisitorCount = if_not_exists(VisitorCount, :start) + :inc",

        ExpressionAttributeValues={
            ':inc': 1,
            ':start': 0,
        },
        ReturnValues="UPDATED_NEW"
    )
    visitor_count = res['Attributes']['VisitorCount']
    response_code = res['ResponseMetadata']['HTTPStatusCode']
    return {
        'statusCode': response_code,
        'body': json.dumps(f"Number of visitors: {visitor_count}")
    }
