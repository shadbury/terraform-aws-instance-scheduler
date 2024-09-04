variable "schedules" {
  description = "A list of schedules to create. Each schedule defines a time-based rule for starting and stopping instances. The properties include the schedule's name, description, timezone, enforcement rules, maintenance windows, and the periods during which instances should run or stop."
  type = list(object({
    name                   = string            # The name used to identify the schedule. This must be unique across the stack.
    description            = string            # A brief description of what the schedule is intended to do, such as '9-5 office hours' or 'weekend shutdown'.
    timezone               = string            # The IANA timezone identifier that the schedule will use, e.g., 'America/New_York'.
    enforced               = bool              # Whether to enforce the schedule, ensuring that instances cannot be manually started outside of the defined periods.
    hibernate              = bool              # Whether to hibernate Amazon EC2 instances when they are stopped by the schedule.
    retain_running         = bool              # Whether to prevent the solution from stopping an instance at the end of a running period if it was manually started beforehand.
    stop_new_instances     = bool              # Whether to stop an instance the first time it is tagged if it is running outside of the defined running period.
    use_maintenance_window = bool              # Whether to use AWS Systems Manager maintenance windows as additional running periods for the schedule.
    ssm_maintenance_window = string            # The name of the SSM maintenance window that should be used as an additional running period, if applicable.
    periods = list(object({
      description  = string                    # A brief description of the period, e.g., '9am-5pm on weekdays' or 'weekend shutdown'.
      begin_time   = string                    # The time in HH:MM format when the period begins, e.g., '09:00'.
      end_time     = string                    # The time in HH:MM format when the period ends, e.g., '17:00'.
      instance_type = string                   # The instance type to be used during this period, e.g., 't2.micro'.
      month_days   = string                    # A comma-delimited list or hyphenated range of days of the month, e.g., '1-3' or '15W' for the nearest weekday to the 15th.
      months       = string                    # A comma-delimited list or hyphenated range of months during which the period is active, e.g., 'jan, feb, mar' or '1-3'.
      weekdays     = string                    # A comma-delimited list or hyphenated range of weekdays, e.g., 'mon-fri' or 'sat-sun'.
    }))
  }))
}

variable "tag_name" {
  description = "The tag key that Instance Scheduler reads to determine the schedule for a resource. The value of the tag with this key on a resource specifies the name of the schedule. Example: If the tag key is 'Schedule' and the value is 'office-hours', the resource will follow the 'office-hours' schedule."
  type        = string
}

variable "scheduler_frequency" {
  description = "The interval, in minutes, between scheduler executions. This controls how often the scheduler evaluates the periods and schedules to determine the desired state (running or stopped) for each instance."
  type        = number
  default     = 5
}

variable "default_timezone" {
  description = "The default IANA time zone identifier used by schedules that do not specify a time zone. This affects how time-based periods are interpreted, ensuring that they align with the local time for the specified region."
  type        = string
  default     = "UTC"
}

variable "scheduling_active" {
  description = "Indicates whether scheduling is active for all services managed by Instance Scheduler. Set to 'Yes' to enable scheduling, allowing the scheduler to start and stop instances based on defined schedules."
  type        = string
  default     = "Yes"
}

variable "schedule_ec2" {
  description = "Enable or disable scheduling for Amazon EC2 instances. When enabled, the scheduler can start or stop EC2 instances according to the defined schedules."
  type        = string
  default     = "Enabled"
}

variable "schedule_rds" {
  description = "Enable or disable scheduling for individual Amazon RDS instances (not clusters). When enabled, the scheduler can start or stop RDS instances according to the defined schedules."
  type        = string
  default     = "Enabled"
}

variable "enable_rds_cluster_scheduling" {
  description = "Enable or disable scheduling for Amazon RDS clusters, including multi-AZ and Aurora clusters. When enabled, the scheduler can start or stop RDS clusters according to the defined schedules."
  type        = string
  default     = "Enabled"
}

variable "schedule_neptune" {
  description = "Enable or disable scheduling for Amazon Neptune clusters. When enabled, the scheduler can start or stop Neptune clusters according to the defined schedules."
  type        = string
  default     = "Enabled"
}

variable "schedule_docdb" {
  description = "Enable or disable scheduling for Amazon DocumentDB (with MongoDB compatibility) clusters. When enabled, the scheduler can start or stop DocumentDB clusters according to the defined schedules."
  type        = string
  default     = "Enabled"
}

variable "schedule_asgs" {
  description = "Enable or disable scheduling for Auto Scaling Groups (ASGs). When enabled, the scheduler can adjust the min, max, and desired capacities of ASGs based on the defined schedules, effectively scaling in and out according to the time of day."
  type        = string
  default     = "Enabled"
}

variable "started_tags" {
  description = "A comma-separated list of tag keys and values that are set on instances when they are started by the scheduler. This can be used to track which instances were started by the scheduler and when."
  type        = string
  default     = "InstanceScheduler-LastAction=Started By {scheduler} {year}-{month}-{day} {hour}:{minute} {timezone}"
}

variable "stopped_tags" {
  description = "A comma-separated list of tag keys and values that are set on instances when they are stopped by the scheduler. This can be used to track which instances were stopped by the scheduler and when."
  type        = string
  default     = "InstanceScheduler-LastAction=Stopped By {scheduler} {year}-{month}-{day} {hour}:{minute} {timezone}"
}

variable "enable_ssm_maintenance_windows" {
  description = "Allow schedules to specify an AWS Systems Manager maintenance window name. The scheduler will ensure that the instance is running during this maintenance window, allowing for regular patching or other maintenance activities."
  type        = string
  default     = "No"
}

variable "kms_key_arns" {
  description = "A list of KMS key ARNs to which Instance Scheduler will be granted kms:CreateGrant permissions. This allows the scheduler to start EC2 instances with attached encrypted EBS volumes. If left empty, the scheduler will not manage encrypted EBS volumes."
  type        = list(string)
  default     = []
}

variable "create_rds_snapshot" {
  description = "Indicates whether to create snapshots of RDS instances before stopping them. This helps ensure that data is backed up before an instance is stopped."
  type        = string
  default     = "No"
}

variable "asg_scheduled_tag_key" {
  description = "The key for the tag that Instance Scheduler will add to scheduled Auto Scaling Groups (ASGs). This tag identifies which ASGs are being managed by the scheduler and tracks their scheduling configuration."
  type        = string
  default     = "scheduled"
}

variable "asg_rule_prefix" {
  description = "The prefix used when naming Scheduled Scaling actions for Auto Scaling Groups managed by Instance Scheduler. This helps identify and distinguish actions created by the scheduler."
  type        = string
  default     = "is-"
}

variable "using_aws_organizations" {
  description = "Indicates whether AWS Organizations is used to manage spoke stack registration. When enabled, the scheduler can automatically manage cross-account scheduling roles within an organization."
  type        = string
  default     = "No"
}

variable "namespace" {
  description = "A unique identifier for the deployment, used to differentiate between multiple deployments of the Instance Scheduler within the same AWS account."
  type        = string
  default     = "default"
}

variable "principals" {
  description = "A list of AWS account IDs that are allowed to use the Instance Scheduler. This is used when AWS Organizations is not enabled."
  type        = list(string)
  default     = []
}

variable "regions" {
  description = "A list of AWS regions where resources should be scheduled. This allows the scheduler to manage instances across multiple regions."
  type        = list(string)
  default     = []
}

variable "schedule_lambda_account" {
  description = "Indicates whether to enable scheduling in the current AWS account. This must be set to 'Yes' for the scheduler to manage resources in this account."
  type        = string
  default     = "Yes"
}

variable "log_retention_days" {
  description = "The retention period, in days, for logs generated by the Instance Scheduler. This determines how long logs are kept in Amazon CloudWatch Logs before being automatically deleted."
  type        = number
  default     = 30
}

variable "trace" {
  description = "Enables or disables debug-level logging in CloudWatch Logs. When enabled, additional detailed logs will be generated, which can be useful for troubleshooting."
  type        = string
  default     = "No"
}

variable "ops_monitoring" {
  description = "Deploys operational metrics and an Operational Insights Dashboard to Amazon CloudWatch. This provides visibility into the performance and impact of the Instance Scheduler, including cost savings and instance management metrics."
  type        = string
  default     = "Enabled"
}

variable "memory_size" {
  description = "The memory size, in MB, allocated to the Lambda function that schedules EC2 and RDS resources. Adjusting this value can help prevent memory-related issues or timeouts during execution."
  type        = number
  default     = 128
}

variable "asg_memory_size" {
  description = "The memory size, in MB, allocated to the Lambda function that schedules Auto Scaling Groups (ASGs). Adjusting this value can help prevent memory-related issues or timeouts during execution."
  type        = number
  default     = 128
}

variable "orchestrator_memory_size" {
  description = "The memory size, in MB, allocated to the Lambda functions that coordinate multi-account, multi-region scheduling for the other scheduling Lambdas. Adjusting this value can help prevent memory-related issues or timeouts during execution."
  type        = number
  default     = 128
}

variable "ddb_deletion_protection" {
  description = "Enables or disables deletion protection for DynamoDB tables used by the solution. When enabled, the tables are retained when the stack is deleted, preventing accidental data loss."
  type        = string
  default     = "Enabled"
}
