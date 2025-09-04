resource "aws_cloudwatch_dashboard" "wsi_dashboard" {
  dashboard_name = "${var.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "log"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          query   = "SOURCE '/ecs/${var.name_prefix}-app' | fields @timestamp, @message | filter @message like /GET/ | parse @message /(?<date>\\S+) (?<time>\\S+) (?<src_ip>\\S+) (?<dst_ip>\\S+) (?<method>\\S+) (?<path>\\S+) (?<status>\\S+) (?<bytes_sent>\\S+) (?<bytes_recv>\\S+) (?<duration>\\S+)/ | fields date, time, src_ip, dst_ip, method, path, status, duration | stats count(status >= 200 and status < 300) as successCount by bin(5m)"
          region  = "ap-southeast-1"
          title   = "wsi-success"
          view    = "timeSeries"
        }
      },
      {
        type   = "log"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          query   = "SOURCE '/ecs/${var.name_prefix}-app' | fields @timestamp, @message | filter @message like /GET/ | parse @message /(?<date>\\S+) (?<time>\\S+) (?<src_ip>\\S+) (?<dst_ip>\\S+) (?<method>\\S+) (?<path>\\S+) (?<status>\\S+) (?<bytes_sent>\\S+) (?<bytes_recv>\\S+) (?<duration>\\S+)/ | fields date, time, src_ip, dst_ip, method, path, status, duration | stats count(status >= 400) as failCount by bin(5m)"
          region  = "ap-southeast-1"
          title   = "wsi-fail"
          view    = "timeSeries"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          query   = "SOURCE '/ecs/${var.name_prefix}-app' | fields @timestamp, @message | filter @message like /GET/ | parse @message /(?<date>\\S+) (?<time>\\S+) (?<src_ip>\\S+) (?<dst_ip>\\S+) (?<method>\\S+) (?<path>\\S+) (?<status>\\S+) (?<bytes_sent>\\S+) (?<bytes_recv>\\S+) (?<duration>\\S+)/ | fields date, time, src_ip, dst_ip, method, path, status, duration | stats (count(status >= 200 and status < 300) * 100.0 / count()) as SLI by bin(5m)"
          region  = "ap-southeast-1"
          title   = "wsi-sli"
          view    = "gauge"
        }
      },
      {
        type   = "log"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          query   = "SOURCE '/ecs/${var.name_prefix}-app' | fields @timestamp, @message | filter @message like /GET/ | parse @message /(?<date>\\S+) (?<time>\\S+) (?<src_ip>\\S+) (?<dst_ip>\\S+) (?<method>\\S+) (?<path>\\S+) (?<status>\\S+) (?<bytes_sent>\\S+) (?<bytes_recv>\\S+) (?<duration>\\S+)/ | fields date, time, src_ip, dst_ip, method, path, status, duration | stats percentile(duration, 99) as p99_process_time, percentile(duration, 95) as p95_process_time, percentile(duration, 90) as p90_process_time by bin(5m)"
          region  = "ap-southeast-1"
          title   = "wsi-p90-p95-p99"
          view    = "timeSeries"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_query_definition" "wsi_query" {
  name = "wsi-query"

  log_group_names = [
    "/ecs/${var.name_prefix}-app"
  ]

  query_string = <<EOF
fields @timestamp, @message
| filter @message like /GET/
| parse @message /(?<date>\S+) (?<time>\S+) (?<src_ip>\S+) (?<dst_ip>\S+) (?<method>\S+) (?<path>\S+) (?<status>\S+) (?<bytes_sent>\S+) (?<bytes_recv>\S+) (?<duration>\S+)/
| fields date, time, src_ip, dst_ip, method, path, status, duration
EOF
}

resource "aws_cloudwatch_metric_alarm" "wsi_high_error_rate" {
  alarm_name          = "${var.name_prefix}-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "This metric monitors 5xx error rate"
  alarm_actions       = []

  dimensions = {
    LoadBalancer = var.alb_full_name
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-high-error-rate"
  })
}

resource "aws_cloudwatch_metric_alarm" "wsi_high_response_time" {
  alarm_name          = "${var.name_prefix}-high-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors response time"
  alarm_actions       = []

  dimensions = {
    LoadBalancer = var.alb_full_name
  }

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-high-response-time"
  })
}
