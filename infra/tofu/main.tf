# A data source READS from AWS; it never creates anything.
# This one asks "who am I?", same as `aws sts get-caller-identity`.
data "aws_caller_identity" "current" {}

# An output prints a value after plan/apply.
# Reference pattern: data.<type>.<name>.<attribute>
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
