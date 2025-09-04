resource "aws_wafv2_web_acl" "xxe_waf" {
  name  = "xxe-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  custom_response_body {
    key          = "forbidden_error"
    content      = "403 Forbidden error"
    content_type = "TEXT_PLAIN"
  }

  rule {
    name     = "XXEProtectionRule"
    priority = 1

    statement {
      or_statement {
        # DOCTYPE
        statement {
          byte_match_statement {
            search_string         = "<!DOCTYPE"
            field_to_match {
              body {
                oversize_handling = "MATCH"
              }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            positional_constraint = "CONTAINS"
          }
        }

        # ENTITY
        statement {
          byte_match_statement {
            search_string         = "<!ENTITY"
            field_to_match {
              body {
                oversize_handling = "MATCH"
              }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            positional_constraint = "CONTAINS"
          }
        }

        # SYSTEM keyword
        statement {
          byte_match_statement {
            search_string         = "SYSTEM"
            field_to_match {
              body {
                oversize_handling = "MATCH"
              }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            positional_constraint = "CONTAINS"
          }
        }

        # PUBLIC keyword
        statement {
          byte_match_statement {
            search_string         = "PUBLIC"
            field_to_match {
              body {
                oversize_handling = "MATCH"
              }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            positional_constraint = "CONTAINS"
          }
        }

        # file://
        statement {
          byte_match_statement {
            search_string         = "file://"
            field_to_match {
              body {
                oversize_handling = "MATCH"
              }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            positional_constraint = "CONTAINS"
          }
        }

        # AWS 메타데이터
        statement {
          byte_match_statement {
            search_string         = "169.254.169.254"
            field_to_match {
              body {
                oversize_handling = "MATCH"
              }
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
            positional_constraint = "CONTAINS"
          }
        }

        # Billion Laughs 패턴 (lol1, lol2, ...)
        statement {
          byte_match_statement {
            search_string         = "lol"
            field_to_match {
              body {
                oversize_handling = "MATCH"
              }
            }
            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
            positional_constraint = "CONTAINS"
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "XXEProtectionRule"
      sampled_requests_enabled   = true
    }

    action {
      block {
        custom_response {
          response_code = 403
          custom_response_body_key = "forbidden_error"
        }
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "XXEWAF"
    sampled_requests_enabled   = true
  }

  tags = merge(var.common_tags, {
    Name = "xxe-waf"
  })
}

resource "aws_wafv2_web_acl_association" "xxe_waf_association" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.xxe_waf.arn
}
