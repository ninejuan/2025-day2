import json
import boto3
import logging
import os
from datetime import datetime
from decimal import Decimal

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    try:
        table_name = os.environ.get('TABLE_NAME', 'account-table')
        table = dynamodb.Table(table_name)
        
        logger.info(f"Processing event: {json.dumps(event)}")
        
        for record in event.get('Records', []):
            if record['eventName'] in ['INSERT', 'MODIFY']:
                handle_conflict_resolution(record, table)
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Conflict resolution completed successfully',
                'processed_records': len(event.get('Records', []))
            })
        }
        
    except Exception as e:
        logger.error(f"Error in conflict resolution: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Conflict resolution failed',
                'message': str(e)
            })
        }

def handle_conflict_resolution(record, table):

    try:
        new_image = record.get('dynamodb', {}).get('NewImage', {})
        old_image = record.get('dynamodb', {}).get('OldImage', {})
        
        if not new_image:
            logger.warning("No new image found in record")
            return
        
        account_id = new_image.get('account_id', {}).get('S')
        if not account_id:
            logger.warning("No account_id found in new image")
            return
        
        if is_conflict_situation(new_image, old_image):
            logger.info(f"Conflict detected for account {account_id}, applying resolution")
            resolve_conflict(account_id, new_image, old_image, table)
        else:
            logger.info(f"No conflict for account {account_id}")
            
    except Exception as e:
        logger.error(f"Error handling conflict resolution for record: {str(e)}")

def is_conflict_situation(new_image, old_image):

    if not old_image:
        return False
    
    new_balance = new_image.get('balance', {}).get('N')
    old_balance = old_image.get('balance', {}).get('N')
    new_timestamp = new_image.get('last_updated', {}).get('S')
    old_timestamp = old_image.get('last_updated', {}).get('S')
    
    if not all([new_balance, old_balance, new_timestamp, old_timestamp]):
        return False
    
    balance_changed = new_balance != old_balance
    timestamp_different = new_timestamp != old_timestamp
    
    return balance_changed and timestamp_different

def resolve_conflict(account_id, new_image, old_image, table):
    try:
        new_timestamp = new_image.get('last_updated', {}).get('S')
        old_timestamp = old_image.get('last_updated', {}).get('S')
        
        new_time = datetime.fromisoformat(new_timestamp.replace('Z', '+00:00'))
        old_time = datetime.fromisoformat(old_timestamp.replace('Z', '+00:00'))
        
        if new_time >= old_time:
            logger.info(f"Using new image for account {account_id} (newer timestamp)")
            final_image = new_image
        else:
            logger.info(f"Using old image for account {account_id} (newer timestamp)")
            final_image = old_image
        
        update_item_with_resolved_data(account_id, final_image, table)
        
    except Exception as e:
        logger.error(f"Error resolving conflict for account {account_id}: {str(e)}")

def update_item_with_resolved_data(account_id, image, table):
    try:
        balance = Decimal(image.get('balance', {}).get('N', '0'))
        currency = image.get('currency', {}).get('S', 'USD')
        last_updated = image.get('last_updated', {}).get('S', datetime.utcnow().isoformat() + 'Z')
        
        response = table.update_item(
            Key={'account_id': account_id},
            UpdateExpression='SET balance = :balance, currency = :currency, last_updated = :last_updated, conflict_resolved = :conflict_resolved',
            ExpressionAttributeValues={
                ':balance': balance,
                ':currency': currency,
                ':last_updated': last_updated,
                ':conflict_resolved': True
            },
            ReturnValues='UPDATED_NEW'
        )
        
        logger.info(f"Successfully updated account {account_id} with resolved data: {response}")
        
    except Exception as e:
        logger.error(f"Error updating item for account {account_id}: {str(e)}")

def get_latest_timestamp(image1, image2):
    timestamp1 = image1.get('last_updated', {}).get('S', '')
    timestamp2 = image2.get('last_updated', {}).get('S', '')
    
    if not timestamp1 and not timestamp2:
        return image1
    elif not timestamp1:
        return image2
    elif not timestamp2:
        return image1
    
    try:
        time1 = datetime.fromisoformat(timestamp1.replace('Z', '+00:00'))
        time2 = datetime.fromisoformat(timestamp2.replace('Z', '+00:00'))
        return image1 if time1 >= time2 else image2
    except:
        return image1
