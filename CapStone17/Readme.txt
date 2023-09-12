install jenkins simple installation on default vpc

https://aws.plainenglish.io/how-to-install-jenkins-on-an-ec2-with-terraform-70aea24ac6d


https://aws.amazon.com/blogs/big-data/automating-aws-service-logs-table-creation-and-querying-them-with-amazon-athena/


create the VPC flow logs based on this article.
https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-s3.html#flow-logs-s3-create-flow-log

create S3 bucket

capstone17-servicelogs-bkt

arn:aws:s3:::capstone17-servicelogs-bkt/cp17-vpcflow-logs

cp17-vpcflow-logs

configure vpc for flow logs

download athena integration stack service log cloudofrmation yaml file
create coud formation stack and update with s3 bucket name

capstone17-servicelogs-athena

