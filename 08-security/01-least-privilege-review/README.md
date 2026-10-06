# Access review: IAM user terraform-lab

Review of the permissions of the IAM user that runs Terraform for [aws-lab](https://github.com/ish337/aws-lab). Prepared for the security review, the sources are the screenshots in [outputs/](outputs/).

## Sources

- IAM → Users → terraform-lab → Permissions (01.png): one policy, `AdministratorAccess`, attached directly.
- IAM → Users → terraform-lab → Last accessed (02.png): 455 services allowed, 7 used.
- Date: October 6, 2026, after the full lab run (apply, tests, destroy).

## Reference scope

The user only needs to create and delete the lab in us-east-1:

- the VPC with subnets, gateways, route tables, NACL, security groups and flow logs;
- two EC2 instances, a key pair and an Elastic IP;
- the S3 bucket `lab-files-*`;
- the IAM roles `lab-*` with their policies;
- the CloudWatch log group `/lab/vpc-flow-logs`;
- reading the public Ubuntu image parameter in SSM.

## Permissions by service

| Service | Used | In scope | What the user really needs |
|---|---|---|---|
| Amazon EC2 | yes | yes | VPC, subnets, gateways, NACL, security groups, instances, key pair, EIP, flow logs in us-east-1 |
| Amazon S3 | yes | yes | only the bucket `lab-files-*` |
| IAM | yes | partly | create and delete only the roles `lab-*`, PassRole for the flow logs role |
| CloudWatch Logs | yes | yes | only the log group `/lab/vpc-flow-logs` |
| Systems Manager | yes | yes | `ssm:GetParameter` on the Canonical Ubuntu parameter |
| STS | yes | yes | `GetCallerIdentity` and `AssumeRole` for the `lab-s3-*` roles |
| KMS | yes | yes | the default `aws/ebs` key for the encrypted disks |
| 448 other services | no | **no** | nothing |

## Outside the scope

- **448 services are allowed but never used**, e.g. billing, Organizations, Lambda, RDS. `AdministratorAccess` gives `*` on `*`.
- **IAM is full access.** The user can create other users and access keys and attach `AdministratorAccess` to them. A leaked key means the whole account is lost, not only the lab.
- **S3 is all buckets in the account**, the lab needs only `lab-files-*`.
- **EC2 is all regions**, the lab runs only in us-east-1.
- **The access key is long-lived**, it works until somebody deletes it.

## Suggestions for the security owner

- Replace `AdministratorAccess` with a policy that has only the services from the table, limited to us-east-1, `lab-files-*`, `role/lab-*` and `/lab/*`.
- Or keep the policy and add a permissions boundary with the same limits.
- Delete the access key after the lab, or use short-lived credentials with `aws login` or SSO.
