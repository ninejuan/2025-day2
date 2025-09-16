import json
import boto3
import os

def handler(event, context):
    """
    Lambda function to create CloudFront invalidation
    """
    try:
        distribution_id = os.environ['DISTRIBUTION_ID']
        
        cloudfront = boto3.client('cloudfront')
        
        path = event.get('path', '/*')
        
        response = cloudfront.create_invalidation(
            DistributionId=distribution_id,
            InvalidationBatch={
                'Paths': {
                    'Quantity': 1,
                    'Items': [path]
                },
                'CallerReference': f"lambda-invalidation-{context.aws_request_id}"
            }
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Invalidation created successfully',
                'invalidation_id': response['Invalidation']['Id'],
                'status': response['Invalidation']['Status']
            })
        }
        
    except Exception as e:
        print(f"Error creating invalidation: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': 'Failed to create invalidation',
                'message': str(e)
            })
        }
