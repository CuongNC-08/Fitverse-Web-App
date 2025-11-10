## ALB HTTPS + DNS Configuration

Follow these steps to deploy the Application Load Balancer with HTTPS enabled while preserving HTTP as an alternate entry point.

1. **Provision/validate an ACM certificate**
   - Request the certificate in the same AWS region as the ALB (e.g., `ap-southeast-1`).
   - Include every hostname that should resolve to the ALB (e.g., `app.fitverse.com`, `www.fitverse.com`).
   - Wait for validation to complete and note the certificate ARN.
2. **Populate the Terraform variables**
   - `alb_enable_https_listener = true`
   - `alb_certificate_arn = "<your ACM certificate ARN>"`
   - Optional overrides:
     - `alb_https_ssl_policy` for a stricter TLS policy (defaults to `ELBSecurityPolicy-TLS-1-2-2017-01`).
     - `alb_http_redirect_to_https` (defaults to `true`) if you want HTTP traffic to keep forwarding instead of redirecting.
     - `alb_http_redirect_status_code` (`HTTP_301` by default) to switch between 301/302 redirects.
   - Place these values in `terraform-vars/common.auto.tfvars` or an environment-specific tfvars file so they are picked up automatically.
3. **Apply the Terraform stack**
   - The ALB module now creates:
     - An HTTPS listener on port 443 that forwards to the same target groups as HTTP.
     - An HTTP listener on port 80 that redirects to HTTPS when `alb_http_redirect_to_https` is true.
     - Listener rules attached to the HTTPS listener (and HTTP when redirects are disabled) so that path-based routing continues to function.
4. **Wire up public DNS**
   - Use the Terraform outputs `alb_dns_name` and `alb_zone_id` to create an AWS Route 53 alias (or similar record at your DNS provider) pointing each hostname at the ALB.
   - Alias records must stay in the same region; if you manage DNS elsewhere, create a CNAME to the ALB DNS name instead.

Once the alias records propagate, end users always receive HTTPS. Direct HTTP requests still succeed—they are simply redirected to HTTPS unless you explicitly disable that behavior.
