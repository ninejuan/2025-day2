resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "cpu-overload-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HighCPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "CPU 사용률이 80%를 초과하는 경우 경보"
  alarm_actions       = []

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-cpu-alarm"
  })
}
