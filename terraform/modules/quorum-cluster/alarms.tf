# ---------------------------------------------------------------------------------------------------------------------
# QUORUM PROCESS CRASHES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "too_many_quorum_crashes" {
  count = "${var.create_alarms ? 1 : 0}"

  alarm_name           = "${aws_sns_topic.too_many_quorum_crashes.name}"
  comparison_operator  = "GreaterThanOrEqualToThreshold"
  evaluation_periods   = "3"
  metric_name          = "QuorumNodeCrashes"
  namespace            = "Quorum"
  period               = "300"
  statistic            = "Sum"
  threshold            = "10"
  treat_missing_data   = "notBreaching"
  alarm_description    = "This alarm alerts us when large numbers of quorum processes are crashing at once."

  alarm_actions = ["${aws_sns_topic.too_many_quorum_crashes.arn}"]

  dimensions {
    NetworkId = "${var.network_id}"
  }
}

resource "aws_sns_topic" "too_many_quorum_crashes" {
  count = "${var.create_alarms ? 1 : 0}"

  name = "network-${var.network_id}-too-many-quorum-crashes"
}

# ---------------------------------------------------------------------------------------------------------------------
# QUORUM HARDWARE CRASHES
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "too_many_node_crashes" {
  count = "${var.create_alarms ? 1 : 0}"

  alarm_name           = "${aws_sns_topic.too_many_node_crashes.name}"
  comparison_operator  = "GreaterThanOrEqualToThreshold"
  evaluation_periods   = "3"
  metric_name          = "StatusCheckFailed"
  namespace            = "AWS/EC2"
  period               = "300"
  statistic            = "Sum"
  threshold            = "10"
  treat_missing_data   = "notBreaching"
  alarm_description    = "This alarm alerts us when large numbers of quorum nodes are crashing at once."

  alarm_actions = ["${aws_sns_topic.too_many_node_crashes.arn}"]

  dimensions {
    NetworkId = "${var.network_id}"
  }
}

resource "aws_sns_topic" "too_many_node_crashes" {
  count = "${var.create_alarms ? 1 : 0}"

  name = "network-${var.network_id}-too-many-node-crashes"
}

# ---------------------------------------------------------------------------------------------------------------------
# TOO MANY NODES BEHIND ON SYNC
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "too_many_nodes_behind" {
  count = "${var.create_alarms ? 1 : 0}"

  alarm_name           = "${aws_sns_topic.too_many_nodes_behind.name}"
  comparison_operator  = "GreaterThanOrEqualToThreshold"
  evaluation_periods   = "12"
  metric_name          = "LargeBlockSkew"
  namespace            = "Quorum"
  period               = "300"
  statistic            = "Sum"
  threshold            = "50"
  treat_missing_data   = "notBreaching"
  alarm_description    = "This alarm alerts us when large numbers of quorum nodes are behind the head of the chain."

  alarm_actions = ["${aws_sns_topic.too_many_nodes_behind.arn}"]

  dimensions {
    NetworkId = "${var.network_id}"
  }
}

resource "aws_sns_topic" "too_many_nodes_behind" {
  count = "${var.create_alarms ? 1 : 0}"

  name = "network-${var.network_id}-too-many-nodes-behind"
}

# ---------------------------------------------------------------------------------------------------------------------
# TOO MANY NODES WITHOUT PEERS
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "too_many_nodes_no_peers" {
  count = "${var.create_alarms ? 1 : 0}"

  alarm_name           = "${aws_sns_topic.too_many_nodes_no_peers.name}"
  comparison_operator  = "GreaterThanOrEqualToThreshold"
  evaluation_periods   = "6"
  metric_name          = "LargeBlockSkew"
  namespace            = "Quorum"
  period               = "300"
  statistic            = "Sum"
  threshold            = "5"
  treat_missing_data   = "notBreaching"
  alarm_description    = "This alarm alerts us when more than a few quorum nodes lose all their peers."

  alarm_actions = ["${aws_sns_topic.too_many_nodes_no_peers.arn}"]

  dimensions {
    NetworkId = "${var.network_id}"
  }
}

resource "aws_sns_topic" "too_many_nodes_no_peers" {
  count = "${var.create_alarms ? 1 : 0}"

  name = "network-${var.network_id}-too-many-nodes-no-peers"
}

# ---------------------------------------------------------------------------------------------------------------------
# BLOCK CREATION HALTED
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "block_creation_halted" {
  count = "${var.create_alarms ? 1 : 0}"

  alarm_name           = "${aws_sns_topic.block_creation_halted.name}"
  comparison_operator  = "GreaterThanOrEqualToThreshold"
  evaluation_periods   = "3"
  metric_name          = "BlockCreationHalted"
  namespace            = "Quorum"
  period               = "300"
  statistic            = "Sum"
  threshold            = "0.8"
  treat_missing_data   = "notBreaching"
  alarm_description    = "This alarm alerts us when it seems like new blocks are not being created."

  alarm_actions = ["${aws_sns_topic.block_creation_halted.arn}"]

  dimensions {
    NetworkId = "${var.network_id}"
  }
}

resource "aws_sns_topic" "block_creation_halted" {
  count = "${var.create_alarms ? 1 : 0}"

  name = "network-${var.network_id}-block-creation-halted"
}

# ---------------------------------------------------------------------------------------------------------------------
# LOW DISK SPACE
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "low_disk_space" {
  count = "${var.create_alarms ? 1 : 0}"

  alarm_name           = "${aws_sns_topic.low_disk_space.name}"
  comparison_operator  = "LessThanOrEqualToThreshold"
  evaluation_periods   = "3"
  metric_name          = "DiskSpaceRemaining"
  namespace            = "Quorum"
  period               = "300"
  statistic            = "Minimum"
  threshold            = "1500000"
  treat_missing_data   = "notBreaching"
  alarm_description    = "This alarm alerts us when a node is running short on disk space."

  alarm_actions = ["${aws_sns_topic.low_disk_space.arn}"]

  dimensions {
    NetworkId = "${var.network_id}"
  }
}

resource "aws_sns_topic" "low_disk_space" {
  count = "${var.create_alarms ? 1 : 0}"

  name = "network-${var.network_id}-low-disk-space"
}
