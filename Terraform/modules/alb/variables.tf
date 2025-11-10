variable "project_name" {
  description = "Base name applied to ALB-related resources."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the ALB and target groups are created."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs used by the ALB."
  type        = list(string)
}

variable "target_groups_definition" {
  description = "List of target group configurations that should be created for the ALB."
  type = list(object({
    name_suffix = string
    port        = number
    protocol    = string
    target_type = string
    health_check = object({
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
  }))
  default = []
}

variable "default_listener_action" {
  description = "Definition of the default listener action for the ALB HTTP listener."
  type = object({
    type                = string
    target_group_suffix = optional(string)
    fixed_response = optional(object({
      content_type = string
      status_code  = string
      message_body = optional(string)
    }))
  })
}

variable "listener_rules_definition" {
  description = "List of listener rule configurations applied to the ALB HTTP listener."
  type = list(object({
    priority             = number
    target_group_suffix  = string
    conditions           = list(map(any))
  }))
  default = []
}

variable "enable_https_listener" {
  description = "Set to true to add an HTTPS listener on port 443."
  type        = bool
  default     = false
}

variable "https_listener_certificate_arn" {
  description = "ACM certificate ARN attached to the HTTPS listener. Required when enable_https_listener is true."
  type        = string
  default     = null

  validation {
    condition     = var.enable_https_listener ? var.https_listener_certificate_arn != null && length(trim(var.https_listener_certificate_arn)) > 0 : true
    error_message = "https_listener_certificate_arn must be supplied when enable_https_listener is true."
  }
}

variable "https_listener_ssl_policy" {
  description = "SSL policy enforced by the HTTPS listener."
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "http_redirect_to_https" {
  description = "When true, the HTTP listener (port 80) responds with a redirect to HTTPS once the HTTPS listener is enabled."
  type        = bool
  default     = true
}

variable "http_redirect_status_code" {
  description = "HTTP status code applied to the redirect action."
  type        = string
  default     = "HTTP_301"

  validation {
    condition     = contains(["HTTP_301", "HTTP_302"], var.http_redirect_status_code)
    error_message = "http_redirect_status_code must be HTTP_301 or HTTP_302."
  }
}
