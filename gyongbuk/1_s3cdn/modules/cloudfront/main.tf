resource "aws_cloudfront_function" "main" {
  name    = "skills-cf-function"
  runtime = "cloudfront-js-1.0"
  comment = "CloudFront function for country and user-agent filtering"
  publish = true
  code    = file("${path.module}/function.js")
}

resource "aws_cloudfront_origin_request_policy" "main" {
  name    = "skills-origin-request-policy"
  comment = "Origin request policy for MRAP"

  cookies_config {
    cookie_behavior = "none"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["CloudFront-Viewer-Country", "CloudFront-Viewer-Country-Region"]
    }
  }

  query_strings_config {
    query_string_behavior = "none"
  }
}

resource "aws_cloudfront_cache_policy" "main" {
  name    = "skills-cache-policy"
  comment = "Cache policy for static content"

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip  = true

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["CloudFront-Viewer-Country"]
      }
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_distribution" "main" {
  ordered_cache_behavior {
    path_pattern             = "/us/*"
    target_origin_id         = "S3-US"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
    cache_policy_id          = aws_cloudfront_cache_policy.main.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.main.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.main.id
  }

  ordered_cache_behavior {
    path_pattern             = "/kr/*"
    target_origin_id         = "S3-KR"
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
    cache_policy_id          = aws_cloudfront_cache_policy.main.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.main.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.main.id
  }
  origin {
    domain_name = var.kr_bucket_domain
    origin_id   = "S3-KR"

    origin_access_control_id = aws_cloudfront_origin_access_control.main.id

    s3_origin_config { origin_access_identity = "" }
  }

  origin {
    domain_name = var.us_bucket_domain
    origin_id   = "S3-US"

    origin_access_control_id = aws_cloudfront_origin_access_control.main.id

    s3_origin_config { origin_access_identity = "" }
  }

  # Dummy MRAP origin (not used by behaviors) to expose MRAP URL in Origins list
  origin {
    domain_name = var.mrap_domain
    origin_id   = "MRAP-DUMMY"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Skills Global Distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-KR"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    cache_policy_id            = aws_cloudfront_cache_policy.main.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.main.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.main.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.main.arn
    }
  }

  price_class = "PriceClass_All"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.tags, {
    Name = "skills-global-distribution"
  })
}

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "skills-oac"
  description                       = "OAC for S3 MRAP"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_response_headers_policy" "main" {
  name    = "skills-response-headers-policy"
  comment = "Response headers policy for security"

  security_headers_config {
    content_type_options {
      override = false
    }
    frame_options {
      frame_option = "DENY"
      override     = false
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = false
    }
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = false
    }
  }
}
