# React App Project with Terraform
In this project a sample react app was deployed on AWS cloud by using ESC Fargate infrastructure. All infrastructure setup by using terraform.
- Seperate VPC and two subnets formed in different AZs for high availability.
- An application load balancer created for directing incoming request to AWS Fargate.
- ALB and ECS Service configured in seperate security groups and ECS service inbound rule allowed
  for the request that comes from ALB security group.
- ECS Fargate cluster created and ECS service provisioned in two AZs.
- Lastly, react app code deployed on ECS Fargate using GitLab.
![Skeleton](https://github.com/MiranaSGit/myReactApp/blob/main/Skeleton.png)

## Notes:
- Gitlab server root password: <br />
  sudo gitlab-rake "gitlab:password:reset"
- Register runner: <br />
  sudo gitlab-runner register
- Replace your key-pair in the variable.tf file.
- Replace your gitlab url in the gitlab.tf and userdata files.
