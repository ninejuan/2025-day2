import json

def lambda_handler(event, context):
    request = event['Records'][0]['cf']['request']
    headers = request['headers']
    
    drm_token = None
    if 'x-drm-token' in headers:
        drm_token = headers['x-drm-token'][0]['value']
    
    valid_token = "drm-cloud"
    
    if not drm_token:
        return {
            'status': '403',
            'statusDescription': 'Forbidden',
            'headers': {
                'content-type': [{'key': 'Content-Type', 'value': 'application/json'}],
                'cache-control': [{'key': 'Cache-Control', 'value': 'no-cache'}]
            },
            'body': json.dumps({
                'error': 'DRM Token Required',
                'message': 'Access denied. DRM token is required to access this content.'
            })
        }
    
    if drm_token != valid_token:
        return {
            'status': '403',
            'statusDescription': 'Forbidden',
            'headers': {
                'content-type': [{'key': 'Content-Type', 'value': 'application/json'}],
                'cache-control': [{'key': 'Cache-Control', 'value': 'no-cache'}]
            },
            'body': json.dumps({
                'error': 'Invalid DRM Token',
                'message': 'Access denied. Invalid DRM token provided.'
            })
        }
    
    return request
