def lambda_handler(event, context):
    print("Received event:", event)
    return {
        'statusCode': 200,
        'body': 'S3 event processed.'
    }