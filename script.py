import boto3
import os

def lambda_handler(event, context):
    # Initialize SES client
    ses_client = boto3.client('ses', region_name='us-west-2')
    
    # Path to the file you want to send
    file_path = '/path/to/your/file.txt'
    
    # Read the file content
    with open(file_path, 'rb') as file:
        file_content = file.read()
    
    # Send the email
    response = ses_client.send_raw_email(
        Source='vchironi@gmail.com',
        Destinations=['vchironi@gmail.com'],
        RawMessage={
            'Data': file_content
        }
    )
    
    return {
        'statusCode': 200,
        'body': 'Email sent successfully'
    }