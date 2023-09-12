ssh-keygen -t rsa -N "" -f capstone1-key

terraform apply -target=aws_instance.capstone1-ops-server


ssh -i "capstone1-key" -A ec2-user@34.221.223.252

ssh -i "/tmp/capstone1-key" -A ec2-user@10.10.4.131

sudo mount -t efs -o tls fs-033953774d8e98034:/ data
__________________________________
Step1 : 
terraform apply -target=aws_efs_mount_target.capstone1-efs-mount-target

Step2:
    after step1 excution get the EFS arn and DNS Name
Step3:
    terraform apply
Step4: login to Ops sever in Public vpc
    ssh -i "capstone1-key" -A ec2-user@54.191.26.16

    ssh -i "capstone1-key" -A ec2-user@10.10.4.160
step5 :
 copy the intial initialAdminPassword

 step6 :
 create 4 jenkins agents ec2 with java installation

 step7: 
 manualy configre the agents in the master