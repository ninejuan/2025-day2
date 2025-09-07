import json
import boto3
import re
import os
from urllib.parse import unquote_plus

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    
    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        object_key = unquote_plus(record['s3']['object']['key'])
        
        if not object_key.startswith('incoming/'):
            continue
        
        try:
            response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
            file_content = response['Body'].read().decode('utf-8')
            
            masked_content = mask_sensitive_data(file_content)
            
            masked_key = object_key.replace('incoming/', 'masked/', 1)
            
            s3_client.put_object(
                Bucket=bucket_name,
                Key=masked_key,
                Body=masked_content.encode('utf-8'),
                ContentType='text/plain'
            )
            
            print(f"Successfully masked and uploaded: {object_key} -> {masked_key}")
            
        except Exception as e:
            print(f"Error processing {object_key}: {str(e)}")
            raise e
    
    return {
        'statusCode': 200,
        'body': json.dumps('Successfully processed files')
    }

def mask_sensitive_data(content):
    
    patterns = {
        'uuids': {
            'pattern': r'\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b',
            'mask_func': mask_uuid
        },
        
        'credit_cards': {
            'pattern': r'\b\d{4}-\d{4}-\d{4}-\d{4}\b',
            'mask_func': mask_credit_card
        },
        
        'ssns': {
            'pattern': r'\b\d{3}-\d{2}-\d{4}\b',
            'mask_func': mask_ssn
        },
        
        'phones': {
            'pattern': r'\b010-\d{4}-\d{4}\b',
            'mask_func': mask_phone
        },
        
        'emails': {
            'pattern': r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b',
            'mask_func': mask_email
        },
        
        'names': {
            'pattern': r'\b(?:Mrs?\.\s+|Ms\.\s+)?[A-Z][a-z]+(?:\s+[A-Z][a-z]+)+\b',
            'mask_func': mask_name
        }
    }
    
    masked_content = content
    
    for data_type, config in patterns.items():
        pattern = config['pattern']
        mask_func = config['mask_func']
        
        matches = re.finditer(pattern, masked_content, re.IGNORECASE)
        for match in reversed(list(matches)):
            original = match.group()
            masked = mask_func(original)
            start, end = match.span()
            masked_content = masked_content[:start] + masked + masked_content[end:]
    
    return masked_content

def mask_name(name):
    parts = name.split()
    if len(parts) <= 1:
        return name
    return f"{parts[0]} {'*' * 5}"

def mask_email(email):
    username, domain = email.split('@')
    if len(username) == 0:
        return email
    return f"{username[0]}{'*' * 9}@{domain}"

def mask_phone(phone):
    parts = phone.split('-')
    if len(parts) != 3:
        return phone
    return f"{parts[0]}-{parts[1]}-{'*' * 4}"

def mask_ssn(ssn):
    parts = ssn.split('-')
    if len(parts) != 3:
        return ssn
    return f"{parts[0]}-{parts[1]}-{'*' * 4}"

def mask_credit_card(card):
    parts = card.split('-')
    if len(parts) != 4:
        return card
    return f"{parts[0]}-{parts[1]}-{parts[2]}-{'*' * 4}"

def mask_uuid(uuid_str):
    if len(uuid_str) < 24:
        return uuid_str
    return f"{uuid_str[:24]}{'*' * 12}"
