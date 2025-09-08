resource "aws_cloudwatch_log_group" "app" {
  name              = "/skills/app"
  retention_in_days = 7

  tags = {
    Name = "skills-app-logs"
  }
}
