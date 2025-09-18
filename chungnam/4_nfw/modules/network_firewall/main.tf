
resource "aws_networkfirewall_rule_group" "stateless_icmp_block" {
  capacity = 100
  name     = "${var.firewall_name}-stateless-icmp-block"
  type     = "STATELESS"

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [1]
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }

  tags = {
    Name = "${var.firewall_name}-stateless-icmp-block"
  }
}

resource "aws_networkfirewall_rule_group" "stateful_dns_block" {
  capacity = 1000
  name     = "${var.firewall_name}-stateful-dns-block"
  type     = "STATEFUL"

  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = var.home_net_cidrs
        }
      }
    }

    rules_source {
      rules_string = <<-EOT
        drop udp $HOME_NET any -> !$HOME_NET 53 (msg:"Block external DNS UDP"; sid:1; rev:1;)
        drop tcp $HOME_NET any -> !$HOME_NET 53 (msg:"Block external DNS TCP"; sid:2; rev:1;)
        
        drop tls $HOME_NET any -> !$HOME_NET 443 (tls.sni; content:"1.1.1.1"; msg:"Block DoH Cloudflare"; sid:3; rev:1;)
        drop tls $HOME_NET any -> !$HOME_NET 443 (tls.sni; content:"8.8.8.8"; msg:"Block DoH Google"; sid:4; rev:1;)
        drop tls $HOME_NET any -> !$HOME_NET 443 (tls.sni; content:"dns.quad9.net"; msg:"Block DoH Quad9"; sid:5; rev:1;)

        # 기본 HTTPS/HTTP 아웃바운드 허용 (위 drop 규칙에 매칭되지 않는 경우)
        pass tcp $HOME_NET any -> !$HOME_NET 443 (msg:"Allow HTTPS egress"; sid:1001; rev:1;)
        pass tcp $HOME_NET any -> !$HOME_NET 80 (msg:"Allow HTTP egress"; sid:1002; rev:1;)
      EOT
    }

    stateful_rule_options {
      rule_order = "STRICT_ORDER"
    }
  }

  tags = {
    Name = "${var.firewall_name}-stateful-dns-block"
  }
}

resource "aws_networkfirewall_firewall_policy" "this" {
  name = "${var.firewall_name}-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.stateless_icmp_block.arn
    }

    # 기본 동작: 엄격 모드에서 경고(통과). 유효한 값만 사용
    # stateful_default_actions = ["aws:alert_established"]
    stateful_default_actions = ["aws:alert_strict"]

    stateful_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.stateful_dns_block.arn
    }

    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }
  }

  tags = {
    Name = "${var.firewall_name}-policy"
  }
}

resource "aws_networkfirewall_firewall" "this" {
  name               = var.firewall_name
  firewall_policy_arn = aws_networkfirewall_firewall_policy.this.arn
  vpc_id             = var.vpc_id

  dynamic "subnet_mapping" {
    for_each = var.firewall_subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = {
    Name = var.firewall_name
  }
}

resource "aws_cloudwatch_log_group" "firewall_logs" {
  name              = "/aws/networkfirewall/${var.firewall_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.firewall_name}-logs"
  }
}

resource "aws_networkfirewall_logging_configuration" "this" {
  firewall_arn = aws_networkfirewall_firewall.this.arn

  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_logs.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }

    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_logs.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
  }
}
