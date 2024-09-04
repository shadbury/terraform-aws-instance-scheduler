
# Instance Scheduler on AWS

## Summary

This Terraform module configures and deploys the Instance Scheduler on AWS, automating the start and stop operations for Amazon EC2 instances, RDS instances, Auto Scaling Groups (ASGs), Neptune, and DocumentDB clusters based on predefined schedules. The solution helps optimize resource usage and reduce operational costs by ensuring instances are only running when needed.

## Configuration Details

### EC2 Configuration

- **ScheduleEC2**: Manages the scheduling of EC2 instances. The module allows you to enable or disable EC2 scheduling as per your requirements.
- **EnableSSMMaintenanceWindows**: Integrates with AWS Systems Manager Maintenance Windows, allowing EC2 instances to run during specific maintenance periods.
- **KmsKeyArns**: Specifies the AWS KMS keys used for encrypting EC2 volumes. These keys must be provided if your EC2 instances use encrypted EBS volumes.
- **StartedTags** and **StoppedTags**: Define the tags that are applied to EC2 instances when they are started or stopped by the scheduler.

### RDS Configuration

- **ScheduleRds**: Controls the scheduling of individual RDS instances. This feature can be toggled on or off depending on your environment's needs.
- **EnableRdsClusterScheduling**: Enables the scheduling of RDS clusters, including Aurora clusters, allowing for more granular control over your database instances.
- **CreateRdsSnapshot**: Optionally creates a snapshot of your RDS instances before stopping them. This feature adds a layer of data protection by ensuring that a backup is taken before instances are shut down.

### ASG Configuration

- **ScheduleASGs**: Automates the scaling actions of Auto Scaling Groups based on defined schedules. This ensures that your ASG-managed instances are only active during required periods.
- **AsgScheduledTagKey**: Specifies the tag key that identifies which ASGs are managed by the scheduler.
- **AsgRulePrefix**: Sets a prefix for the rules that manage scaling actions within your Auto Scaling Groups.

### Neptune and DocumentDB Configuration

- **ScheduleNeptune**: Manages the scheduling of Amazon Neptune clusters. This feature can be toggled on or off.
- **ScheduleDocDB**: Manages the scheduling of Amazon DocumentDB clusters. This feature can be toggled on or off.

### Advanced Configurations

- **Namespace**: Defines the namespace used by the scheduler, useful for organizing schedules within AWS Organizations.
- **UsingAWSOrganizations**: Specifies whether the scheduler is integrated with AWS Organizations for cross-account scheduling.
- **ScheduleLambdaAccount**: Enables or disables scheduling for the account running the Lambda function used by the scheduler.
- **LogRetentionDays**: Specifies the number of days logs are retained in CloudWatch.
- **Trace**: Enables or disables detailed tracing for debugging purposes.
- **OpsMonitoring**: Enables or disables operational monitoring features.
- **MemorySize**: Configures the memory size for the scheduler's Lambda function.
- **ASGMemorySize**: Configures the memory size for the ASG scheduler's Lambda function.
- **OrchestratorMemorySize**: Configures the memory size for the orchestrator Lambda function.
- **DDBDeletionProtection**: Enables or disables deletion protection for the DynamoDB tables used by the scheduler.

## Example Usage

The following example demonstrates how to configure the Instance Scheduler using this module:

```hcl
module "instance_scheduler" {
  source = "../modules"

  tag_name                      = "Instance-Scheduler"
  scheduler_frequency           = 5
  default_timezone              = "Australia/Sydney"
  scheduling_active             = "Yes"
  schedule_ec2                  = "Enabled"
  schedule_rds                  = "Disabled"
  enable_rds_cluster_scheduling = "Disabled"
  schedule_neptune              = "Disabled"
  schedule_docdb                = "Disabled"
  schedule_asgs                 = "Disabled"
  kms_key_arns                  = ["arn:aws:kms:ap-southeast-2:123456789012:key/your-kms-key-id"]
  create_rds_snapshot           = "No"
  asg_scheduled_tag_key         = "scheduled"
  asg_rule_prefix               = "is-"
  started_tags                  = "InstanceScheduler-LastAction=Started By {scheduler} {year}-{month}-{day} {hour}:{minute} {timezone}"
  stopped_tags                  = "InstanceScheduler-LastAction=Stopped By {scheduler} {year}-{month}-{day} {hour}:{minute} {timezone}"
  enable_ssm_maintenance_windows = "Yes"
  namespace                     = "default"
  using_aws_organizations       = "No"
  schedule_lambda_account       = "Yes"
  log_retention_days            = 30
  trace                         = "No"
  ops_monitoring                = "Enabled"
  memory_size                   = 128
  asg_memory_size               = 128
  orchestrator_memory_size      = 128
  ddb_deletion_protection       = "Enabled"

  schedules = [
    {
      name                   = "AZ1"
      description            = "Schedule for AZ1"
      timezone               = "Australia/Sydney"
      enforced               = true
      hibernate              = false
      retain_running         = true
      stop_new_instances     = false
      use_maintenance_window = true
      ssm_maintenance_window = "your-ssm-maintenance-window"

      periods = [
        {
          description  = "Weekday office hours"
          begin_time   = "09:00"
          end_time     = "17:00"
          weekdays     = "Mon-Fri"
        }
      ]
    }
  ]
}
```

## Requirements

| Name          | Version |
|---------------|---------|
| Terraform     | >= 0.12 |
| AWS Provider  | >= 3.0  |

## Inputs

| Name                           | Description                                           | Type           | Default              | Required |
|--------------------------------|-------------------------------------------------------|----------------|----------------------|:--------:|
| scheduler_frequency            | Interval between scheduler executions (in minutes)    | `number`       | `5`                  |   yes    |
| default_timezone               | Default timezone for scheduling                       | `string`       | `"Australia/Sydney"` |   yes    |
| kms_key_arns                   | List of KMS Key ARNs for encrypted instances          | `list(string)` | `[]`                 |    no    |
| scheduling_active              | Global flag to enable/disable scheduling              | `string`       | `"Yes"`              |   yes    |
| asg_scheduled_tag_key          | Tag key for managing ASG schedules                    | `string`       | `"scheduled"`        |   yes    |
| started_tags                   | Tags to apply when EC2 instances are started          | `string`       | `"Started"`          |    no    |
| stopped_tags                   | Tags to apply when EC2 instances are stopped          | `string`       | `"Stopped"`          |    no    |
| enable_ssm_maintenance_windows | Enable SSM maintenance window integration             | `string`       | `"Yes"`              |    no    |
| namespace                      | Namespace for organizing schedules                    | `string`       | `"default"`          |    no    |
| using_aws_organizations        | Enable AWS Organizations integration                  | `string`       | `"No"`               |    no    |
| schedule_lambda_account        | Schedule Lambda account                               | `string`       | `"Yes"`              |    no    |
| log_retention_days             | Log retention period in days                          | `number`       | `30`                 |    no    |
| trace                          | Enable detailed tracing                               | `string`       | `"No"`               |    no    |
| ops_monitoring                 | Enable operational monitoring                         | `string`       | `"Enabled"`          |    no    |
| memory_size                    | Memory size for the scheduler's Lambda function       | `number`       | `128`                |    no    |
| asg_memory_size                | Memory size for the ASG scheduler's Lambda function   | `number`       | `128`                |    no    |
| orchestrator_memory_size       | Memory size for the orchestrator Lambda function      | `number`       | `128`                |    no    |
| ddb_deletion_protection        | Enable DynamoDB deletion protection                   | `string`       | `"Enabled"`          |    no    |

