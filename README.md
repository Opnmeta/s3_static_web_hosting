# S3 Static Web Hosting

## Overview
This rope host terraform code to create staic web hosting resouces with AWS CloudFront and S3. 

## TL;DR
1. Make sure you installed Terraform
2. AWS credential has been configured poperly 
2. You own a domain; a Route 53 zone has been created; Domain NS revords has records to CloudFront Zone
3. Update provider.tf 
4. Update vaules in config.yml
5. Terraform init, plan and apply 

```
cd TF
export TF_VAR_CONFIG=../config.yml
export TF_VAR_AWS_SHARED_CREDENTIALS_FILE=~/.aws/credentials
terraform init
terraform plan
terraform apply
```


## How to 
### Terraform installation 
Please read this page for terraform installation [Install Terraform](https://developer.hashicorp.com/terraform/install)

### AWS credential config 
Please read this page for AWS Credential config [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
[Configuration and credentials precedence](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#configure-precedence)

### Route 53 setup 
The terraform code will try to create DNS records for ACM certificate validation, this means you have to 
* Own a domain
* Manually create a new Route 53 zone 
* Change the Domain NS Records to Route 53 zone. 

### Update provider.tf
The Terraform code has AWS provider with AWS assume role for IAM user, you can update it with AK/SK or configuration files. 

Please be aware, due to feature of AWS CloudFront, the ACM (AWS certificate manager) cer has to be created in us-east-1 regaion, please do not delete provider "aws.use1"

### Update values in config.yml
there is config.yml files which contains all the configuable items for terraform code. please update this accordingly

### IAM users (Optional)
For static website setup, mostly you want a seperate secure user with limited permission to access your S3 bucket. this terraform code will also create a new IAM user called "s3_uploader" which is helpful for application like Publii.  if you do not want that, delete or rename the main_06_iam.tf file.

### AWS Budget (Optional)
The static web hosting normally create only for small projects and personally use only, we do not want a situation when you wake up one day and discover that a huge bill from AWS account due to unexpected event(DDoS attack). that why a "killwtich" is seup for using AWS bugets notify AWS SNS topic, which will trigger Lambda function to disable public facing service AWS cloudfront.  this is totally optional, not for a production use. 

The proper solution would be using an AWS WAF, But I'm try to minimized the cost ($6 per month for AWS WAF) for a very unlickely event of DDoS attack on small project.  

## Licenses
Apache License 2.0

## Contact 
[info@opnmate.com](mailto:info@opnmate.com)

