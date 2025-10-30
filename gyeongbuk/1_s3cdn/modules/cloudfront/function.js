function handler(event) {
    var request = event.request;
    var headers = request.headers;
    
    var country = headers['cloudfront-viewer-country'] ? 
        headers['cloudfront-viewer-country'].value : '';
    
    var userAgent = headers['user-agent'] ? 
        headers['user-agent'].value.toLowerCase() : '';
    
    var allowedCountries = ['KR', 'US'];
    if (country && !allowedCountries.includes(country)) {
        return {
            statusCode: 403,
            statusDescription: 'Forbidden',
            body: {
                encoding: 'text',
                data: 'Access denied: unsupported country'
            }
        };
    }

    if (request.uri && (request.uri.startsWith('/kr/') || request.uri.startsWith('/us/'))) {
        request.uri = request.uri.replace(/^\/(kr|us)\//, '/');
        return request;
    }
    
    var blockedPatterns = ['bot', 'crawler', 'spider'];
    for (var i = 0; i < blockedPatterns.length; i++) {
        if (userAgent.includes(blockedPatterns[i])) {
            return {
                statusCode: 403,
                statusDescription: 'Forbidden',
                body: {
                    encoding: 'text',
                    data: 'Request blocked due to suspicious User-Agent'
                }
            };
        }
    }
    
    if (request.uri === '/' || request.uri === '/index.html') {
        if (country === 'US') {
            return {
                statusCode: 302,
                statusDescription: 'Found',
                headers: { location: { value: '/us/index.html' } }
            };
        } else if (country === 'KR') {
            return {
                statusCode: 302,
                statusDescription: 'Found',
                headers: { location: { value: '/kr/index.html' } }
            };
        } else {
            return {
                statusCode: 403,
                statusDescription: 'Forbidden',
                body: { encoding: 'text', data: 'Access denied: unsupported country' }
            };
        }
    }

    return request;
}
