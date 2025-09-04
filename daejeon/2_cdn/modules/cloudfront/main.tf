resource "aws_cloudfront_function" "drm_function" {
  name    = var.function_name
  runtime = "cloudfront-js-2.0"
  comment = "DRM Token을 Query String에서 Header로 변환하는 CloudFront Function for Edge DRM"
  publish = true
  code    = file("${path.module}/function.js")

}

resource "aws_cloudfront_origin_access_identity" "drm_oai" {
  comment = "OAI for ${var.project_name} DRM bucket"
}

resource "aws_cloudfront_cache_policy" "drm_cache_policy" {
  name        = "${var.project_name}-drm-cache-policy"
  comment     = "Cache policy for DRM content with token-based caching for Edge DRM"
  default_ttl = 60
  max_ttl     = 60
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    query_strings_config {
      query_string_behavior = "all"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["X-DRM-Token"]
      }
    }

    cookies_config {
      cookie_behavior = "none"
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "drm_origin_request_policy" {
  name    = "${var.project_name}-drm-origin-request-policy"
  comment = "Origin request policy for DRM content"

  query_strings_config {
    query_string_behavior = "all"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["X-DRM-Token"]
    }
  }

  cookies_config {
    cookie_behavior = "none"
  }
}

resource "aws_cloudfront_response_headers_policy" "drm_response_headers_policy" {
  name    = "${var.project_name}-drm-response-headers-policy"
  comment = "Response headers policy for DRM content"

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
      preload                    = true
      override                   = false
    }
  }
}

resource "aws_cloudfront_distribution" "drm_distribution" {
  origin {
    domain_name = var.s3_bucket_domain_name
    origin_id   = "S3-${var.s3_bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.drm_oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for DRM-protected content"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.s3_bucket_name}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.drm_function.arn
    }

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = var.lambda_edge_arn
      include_body = false
    }

    cache_policy_id            = aws_cloudfront_cache_policy.drm_cache_policy.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.drm_origin_request_policy.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.drm_response_headers_policy.id
  }

  ordered_cache_behavior {
    path_pattern           = "media/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${var.s3_bucket_name}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.drm_function.arn
    }

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = var.lambda_edge_arn
      include_body = false
    }

    cache_policy_id            = aws_cloudfront_cache_policy.drm_cache_policy.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.drm_origin_request_policy.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.drm_response_headers_policy.id
  }

  custom_error_response {
    error_code         = 403
    response_code      = 403
    response_page_path = "/error/403.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/error/404.html"
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = var.distribution_name
  }
}
