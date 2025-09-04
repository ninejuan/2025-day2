resource "aws_cloudwatch_dashboard" "wsi_dashboard" {
  dashboard_name = "${var.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "LoadBalancer", var.alb_full_name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "ap-southeast-1"
          title   = "wsi-success"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "LoadBalancer", var.alb_full_name],
            [".", "HTTPCode_Target_5XX_Count", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "ap-southeast-1"
          title   = "wsi-fail"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_full_name]
          ]
          view    = "gauge"
          region  = "ap-southeast-1"
          title   = "wsi-sli"
          period  = 300
          stat    = "Average"
          yAxis = {
            left = {
              min = 0
              max = 2
            }
          }
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_full_name, { "stat": "p90" }],
            [".", ".", ".", ".", { "stat": "p95" }],
            [".", ".", ".", ".", { "stat": "p99" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "ap-southeast-1"
          title   = "wsi-p90-p95-p99"
          period  = 300
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
| parse @message /(?<timestamp>\S+ \S+) (?<src_ip>\S+) (?<dst_ip>\S+) (?<method>\S+) (?<path>\S+) (?<status>\S+) (?<send_size>\S+) (?<recv_size>\S+) (?<duration>\S+)/
| stats count() as successCount by bin(5m)
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
