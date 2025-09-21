resource "aws_networkfirewall_firewall" "firewall" {
  name                = "${var.prefix}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.firewall_policy.arn
  vpc_id              = module.egress_vpc.vpc_id

  subnet_mapping {
    subnet_id = aws_subnet.firewall_subnet_a.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.firewall_subnet_b.id
  }

  delete_protection                 = false
  firewall_policy_change_protection = false
  subnet_change_protection          = false

  tags = {
    "Name" = "${var.prefix}-firewall"
  }

  depends_on = [aws_networkfirewall_firewall_policy.firewall_policy]
}

resource "aws_networkfirewall_firewall_policy" "firewall_policy" {
  name = "${var.prefix}-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateless_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.stateless_firewall_rule.arn
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateful_firewall_rule.arn
    }
  }

  tags = {
    "Name" = "${var.prefix}-firewall-policy"
  }

  depends_on = [
    aws_networkfirewall_rule_group.stateful_firewall_rule,
    aws_networkfirewall_rule_group.stateless_firewall_rule
  ]
}

resource "aws_networkfirewall_rule_group" "stateless_firewall_rule" {
  name     = "${var.prefix}-firewall-stateless"
  capacity = 10
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
    Name = "${var.prefix}-firewall-stateless"
  }
}

resource "aws_networkfirewall_rule_group" "stateful_firewall_rule" {
  name     = "${var.prefix}-firewall-stateful"
  capacity = 100
  type     = "STATEFUL"

  rule_group {
    rules_source {
      rules_string = file("${path.module}/suricata.rules")
    }
  }

  tags = {
    Name = "${var.prefix}-firewall-stateful"
  }
}

locals {
  firewall_endpoints_by_az = {
    for sync_state in aws_networkfirewall_firewall.firewall.firewall_status[0].sync_states :
    sync_state.availability_zone => sync_state.attachment[0].endpoint_id
  }
}