# Day 100: Create and Configure Alarm Using CloudWatch Using Terraform

## Objective
The objective of this task is to implement automated monitoring for a cloud server. I provisioned an EC2 instance and configured a CloudWatch alarm to track its CPU performance. If the server's CPU usage stays at or above 90% for a continuous 5-minute window, the system is programmed to automatically send a notification to a specific SNS topic.

## 1. CloudWatch Monitoring

CloudWatch is a monitoring and observability service in AWS. To build an automated alert system, I used several specific concepts:

**Metrics and Statistics**
AWS services constantly produce data points. I targeted the `CPUUtilization` metric from the `AWS/EC2` namespace. By choosing the **Average** statistic, I told CloudWatch to calculate the mean usage over a specific time block rather than looking for a single spike.

**Evaluation Windows (Period and Evaluation Periods)**
An alarm needs to know how long to wait before getting worried. I set the **Period** to 300 seconds (5 minutes). By setting **Evaluation Periods** to 1, I instructed the alarm to trigger as soon as a single 5-minute window crosses the limit. This prevents false alarms from very brief bursts of activity while catching sustained high load.

**Thresholds and Comparisons**
The threshold is the "Red Line." I set this to **90**. Using the **GreaterThanOrEqualToThreshold** operator creates a clear boundary: as soon as the calculated average hits that number, the state of the alarm changes from "OK" to "ALARM."

**Alarm Actions (SNS Integration)**
Monitoring is only useful if someone is notified. I linked the alarm to an **SNS Topic** (Simple Notification Service). When the alarm triggers, it sends a digital "signal" to the topic, which then handles the delivery of the message to the end-users.

## 2. Developed the Terraform Manifest
I updated the `main.tf` file to define the server and the monitoring logic. I used a data resource to find the existing SNS topic so I could link the alarm to it.

```hcl
# main.tf

# Reference the existing SNS topic
resource "aws_sns_topic" "sns_topic" {
  name = "xfusion-sns-topic"
}

# Provision the EC2 instance
resource "aws_instance" "xfusion_ec2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  tags = {
    Name = "xfusion-ec2"
  }
}

# Create the CloudWatch alarm
resource "aws_cloudwatch_metric_alarm" "xfusion_alarm" {
  alarm_name          = "xfusion-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 90

  # Send notification to SNS when triggered
  alarm_actions = [
    aws_sns_topic.sns_topic.arn
  ]

  # Target this specific instance
  dimensions = {
    InstanceId = aws_instance.xfusion_ec2.id
  }
}
```

## 3. Configured Outputs
I created an `outputs.tf` file to display the specific names of the resources once the deployment was finished.

```hcl
# outputs.tf

output "KKE_instance_name" {
  value = aws_instance.xfusion_ec2.tags["Name"]
}

output "KKE_alarm_name" {
  value = aws_cloudwatch_metric_alarm.xfusion_alarm.alarm_name
}
```

## 4. Deployment Workflow
I ran the standard Terraform lifecycle to provision the monitoring stack in AWS.

```bash
# Prepare the workspace
terraform init

# Validate the code syntax
terraform validate

# Apply the configuration
terraform apply -auto-approve
```

## 5. Verification
I used the AWS CLI to confirm that the instance was running and that the CloudWatch alarm was active and monitoring the correct resource.

```bash
# Verify instance status
aws ec2 describe-instances --filters "Name=tag:Name,Values=xfusion-ec2"

# Verify alarm configuration and target InstanceId
aws cloudwatch describe-alarms --alarm-names xfusion-alarm
```

### Result
I verified that the `xfusion-ec2` instance was successfully launched. The `xfusion-alarm` is now active and correctly mapped to the instance ID. It shows a state of `INSUFFICIENT_DATA` initially as it begins its first 5-minute collection period. The automation is complete, ensuring the Nautilus team is notified of any high CPU events.

## Screenshot
![day-100-screenshot](day-100-screenshot.png)