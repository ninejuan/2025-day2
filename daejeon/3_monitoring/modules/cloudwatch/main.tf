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
          query   = "SOURCE '/ecs/${var.name_prefix}-app' | fields @timestamp, @message | filter @message like /GET/ | parse @message /(?<raw_date>\\S+) (?<raw_time>\\S+) (?<src_ip>\\S+) (?<dst_ip>\\S+) (?<method>\\S+) (?<path>\\S+) (?<status>\\S+) (?<bytes_sent>\\S+) (?<bytes_recv>\\S+) (?<duration>\\S+)/ | fields raw_date as req_date, raw_time as req_time, src_ip as sip, dst_ip as dip, method as m, path as pat, status as sta, duration as dur | stats count(*) as successCount by bin(5m)"
          region  = "ap-southeast-1"
          title   = "wsi-success"
          view    = "timeSeries"
          stacked = true
        }
      },
      {
        type   = "log"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          query   = "SOURCE '/ecs/${var.name_prefix}-app' | fields @timestamp, @message | filter @message like /GET/ | parse @message /(?<raw_date>\\S+) (?<raw_time>\\S+) (?<src_ip>\\S+) (?<dst_ip>\\S+) (?<method>\\S+) (?<path>\\S+) (?<status>\\S+) (?<bytes_sent>\\S+) (?<bytes_recv>\\S+) (?<duration>\\S+)/ | fields raw_date as req_date, raw_time as req_time, src_ip as sip, dst_ip as dip, method as m, path as pat, status as sta, duration as dur | filter sta >= 400 | stats count(*) as FailCount by bin(5m)"
          region  = "ap-southeast-1"
          title   = "wsi-fail"
          view    = "timeSeries"
          stacked = true
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
      [
        {
          expression = "100 * m2xx / total"
          label      = "SLI Success Rate"
          id         = "e1"
          region     = "ap-southeast-1"
        }
      ],
      [
        "AWS/ApplicationELB", "RequestCount", "LoadBalancer", "${var.alb_full_name}",
        {
          id     = "total"
          stat   = "Sum"
          region = "ap-southeast-1"
          visible = false
        }
      ],
      [
        ".", "HTTPCode_Target_2XX_Count", ".", ".",
        {
          id     = "m2xx"
          stat   = "Sum"
          region = "ap-southeast-1"
          visible = false
        }
      ]
    ]
    region  = "ap-southeast-1"
    title   = "wsi-SLI"
    view    = "gauge"
    setPeriodToTimeRange = true
    stacked = false
    yAxis = {
      left = {
        min = 0
        max = 100
      }
    }
    singleValueFullPrecision = false
    liveData = true
  }
}
,
      {
        type   = "log"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          query   = "SOURCE '/ecs/${var.name_prefix}-app' | fields @timestamp, @message | filter @message like /GET/ | parse @message /(?<raw_date>\\S+) (?<raw_time>\\S+) (?<src_ip>\\S+) (?<dst_ip>\\S+) (?<method>\\S+) (?<path>\\S+) (?<status>\\S+) (?<bytes_sent>\\S+) (?<bytes_recv>\\S+) (?<duration>\\S+)/ | fields raw_date as req_date, raw_time as req_time, src_ip as sip, dst_ip as dip, method as m, path as pat, status as sta, duration as dur | stats pct(dur, 99) as p99_process_time, pct(dur, 95) as p95_process_time, pct(dur, 90) as p90_process_time by bin(5m)"
          region  = "ap-southeast-1"
          title   = "p90-p95-p99"
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
| sort @timestamp desc
| limit 100
| parse @message /(?<raw_date>\S+) (?<raw_time>\S+) (?<src_ip>\S+) (?<dst_ip>\S+) (?<method>\S+) (?<path>\S+) (?<status>\S+) (?<bytes_sent>\S+) (?<bytes_recv>\S+) (?<duration>\S+)/
EOF
}

