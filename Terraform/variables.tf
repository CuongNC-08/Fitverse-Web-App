## Removed CloudFront/Wasabi related variables

variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# VPC Variables
variable "project_name" {
  description = "Name of the project for resource naming"
  type        = string
  default     = "projectname"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.3.0/24"
}

# ALB / Listener Settings
variable "alb_enable_https_listener" {
  description = "Enable the HTTPS listener (port 443) on the ALB."
  type        = bool
  default     = false
}

variable "alb_certificate_arn" {
  description = "ACM certificate ARN served by the HTTPS listener. Required when alb_enable_https_listener is true."
  type        = string
  default     = null

  validation {
    condition     = var.alb_enable_https_listener ? var.alb_certificate_arn != null && length(trim(var.alb_certificate_arn)) > 0 : true
    error_message = "alb_certificate_arn must be set when alb_enable_https_listener is true."
  }
}

variable "alb_https_ssl_policy" {
  description = "SSL policy enforced by the HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "alb_http_redirect_to_https" {
  description = "When true, HTTP requests are redirected to HTTPS once the HTTPS listener is enabled."
  type        = bool
  default     = true
}

variable "alb_http_redirect_status_code" {
  description = "Status code used by the HTTP->HTTPS redirect."
  type        = string
  default     = "HTTP_301"

  validation {
    condition     = contains(["HTTP_301", "HTTP_302"], var.alb_http_redirect_status_code)
    error_message = "alb_http_redirect_status_code must be HTTP_301 or HTTP_302."
  }
}

# EC2 Variables
variable "instance_type" {
  description = "EC2 instance type (free tier eligible: t2.micro)"
  type        = string
  default     = "t2.micro"
}

variable "associate_public_ip" {
  description = "Whether to associate an Elastic IP with the EC2 instance"
  type        = bool
  default     = true
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# ECS Global Variables
variable "enable_auto_scaling" {
  description = "Enable auto scaling for the ECS service"
  type        = bool
  default     = false
}

variable "enable_service_connect" {
  description = "Enable ECS Service Connect across services"
  type        = bool
  default     = false
}
variable "service_discovery_domain_suffix" {
  description = "Suffix used to build the private DNS namespace for service discovery (e.g. \"svc\" => <project>.svc)"
  type        = string
  default     = "svc"
}

# Service Definitions Variable
variable "services" {
  description = "Configuration for each microservice"
  type = map(object({
    # ALB Target Group attributes
    alb_target_group_port     = number
    alb_target_group_protocol = string
    alb_target_group_type     = string
    alb_health_check = object({
      enabled             = bool
      path                = string
      port                = string
      protocol            = string
      matcher             = string
      interval            = number
      timeout             = number
      healthy_threshold   = number
      unhealthy_threshold = number
    })

    # ALB Listener Rule attributes
    alb_listener_rule_priority = number
    alb_listener_rule_conditions = list(object({
      path_pattern = optional(object({
        values = list(string)
      }))
      # Add other condition types here if needed (e.g., host_header)
    }))
    ecs_service_connect_dns_name       = string # Optional custom DNS name for the service
    ecs_service_connect_discovery_name = string # Optional custom DNS name for the service
    ecs_service_connect_port_name      = string # Optional custom DNS name for the service
    # ECS Container attributes
    ecs_container_name_suffix          = string # e.g. "microservice" to form "project-key-suffix"
    ecs_container_image_repository_url = string
    ecs_container_image_tag            = string
    ecs_container_cpu                  = number
    ecs_container_memory               = number
    ecs_container_memory_reservation   = optional(number)
    ecs_container_essential            = bool
    ecs_container_port_mappings = list(object({
      container_port = number
      host_port      = optional(number, 0)
      protocol       = optional(string, "tcp")
      name           = optional(string)
      app_protocol   = optional(string)
    }))
    ecs_environment_variables = list(object({
      name  = string
      value = string
    }))
    ecs_container_health_check = optional(object({
      command     = list(string)
      interval    = number
      timeout     = number
      retries     = number
      startPeriod = number
    }))
    depends_on              = optional(list(string)) # Container names this depends on
    command                 = optional(list(string))
    ecs_task_cpu            = optional(number)
    ecs_task_memory         = optional(number)
    ecs_desired_count       = optional(number)
    ecs_assign_public_ip    = optional(bool)
    ecs_enable_auto_scaling = optional(bool)
  }))
  sensitive = true

}
