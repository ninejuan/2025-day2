function handler(event) {
    var request = event.request;
    var querystring = request.querystring;
    
    var drmToken = null;
    
    if (querystring.drm_token && querystring.drm_token.value) {
        drmToken = querystring.drm_token.value;
    } else if (querystring.token && querystring.token.value) {
        drmToken = querystring.token.value;
    }
    
    if (drmToken) {
        request.headers['x-drm-token'] = {
            value: drmToken
        };
    }
    
    return request;
}
