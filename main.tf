
provider "aws" {
  profile = "aonsw-dev"
  region  = "ap-southeast-2"
}

resource "aws_cloudformation_stack" "instance_scheduler" {
  name          = var.tag_name

  parameters = {
    TagName                     = var.tag_name
    SchedulerFrequency          = var.scheduler_frequency
    DefaultTimezone             = var.default_timezone
    SchedulingActive            = var.scheduling_active
    ScheduleEC2                 = var.schedule_ec2
    ScheduleRds                 = var.schedule_rds
    EnableRdsClusterScheduling  = var.enable_rds_cluster_scheduling
    ScheduleNeptune             = var.schedule_neptune
    ScheduleDocDb               = var.schedule_docdb
    ScheduleASGs                = var.schedule_asgs
    StartedTags                 = var.started_tags
    StoppedTags                 = var.stopped_tags
    EnableSSMMaintenanceWindows = var.enable_ssm_maintenance_windows
    KmsKeyArns                  = join(",", var.kms_key_arns)
    CreateRdsSnapshot           = var.create_rds_snapshot
    AsgScheduledTagKey          = var.asg_scheduled_tag_key
    AsgRulePrefix               = var.asg_rule_prefix
    UsingAWSOrganizations       = var.using_aws_organizations
    Namespace                   = var.namespace
    Principals                  = join(",", var.principals)
    Regions                     = join(",", var.regions)
    ScheduleLambdaAccount       = var.schedule_lambda_account
    LogRetentionDays            = var.log_retention_days
    Trace                       = var.trace
    OpsMonitoring               = var.ops_monitoring
    MemorySize                  = var.memory_size
    AsgMemorySize               = var.asg_memory_size
    OrchestratorMemorySize      = var.orchestrator_memory_size
    ddbDeletionProtection       = var.ddb_deletion_protection
  }

  template_url = "https://${aws_s3_bucket.cf_templates.bucket}.s3.amazonaws.com/${aws_s3_bucket_object.cf_template.key}"


  capabilities = ["CAPABILITY_NAMED_IAM"]
}

data "aws_cloudformation_stack" "instance_scheduler_output" {
  name = aws_cloudformation_stack.instance_scheduler.name
}

output "service_instance_schedule_service_token_arn" {
  value = data.aws_cloudformation_stack.instance_scheduler_output.outputs["ServiceInstanceScheduleServiceToken"]
}

resource "aws_cloudformation_stack" "instance_schedules" {
  for_each = { for sched in var.schedules : sched.name => sched }

  name = each.value.name

  template_body = jsonencode({
    AWSTemplateFormatVersion = "2010-09-09",
    Resources = {
      Schedule = {
        Type = "Custom::ServiceInstanceSchedule"
        Properties = merge(
          {
            ServiceToken         = data.aws_cloudformation_stack.instance_scheduler_output.outputs["ServiceInstanceScheduleServiceToken"]
            NoStackPrefix        = "False"
            Description          = each.value.description
            Timezone             = each.value.timezone
            Enforced             = each.value.enforced ? "True" : "False"
            Hibernate            = each.value.hibernate ? "True" : "False"
            RetainRunning        = each.value.retain_running ? "True" : "False"
            StopNewInstances     = each.value.stop_new_instances ? "True" : "False"
            UseMaintenanceWindow = each.value.use_maintenance_window ? "True" : "False"
          },
          each.value.ssm_maintenance_window != null ? { SsmMaintenanceWindow = each.value.ssm_maintenance_window } : {},
          {
            Periods = [
              for period in each.value.periods : merge(
                {
                  Description = period.description
                  BeginTime   = period.begin_time
                  EndTime     = period.end_time
                },
                period.instance_type != null ? { InstanceType = period.instance_type } : {},
                period.month_days != null ? { MonthDays = period.month_days } : {},
                period.months != null ? { Months = period.months } : {},
                period.weekdays != null ? { WeekDays = period.weekdays } : {}
              )
            ]
          }
        )
      }
    }
  })
}