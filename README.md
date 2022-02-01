# React App Project with Terraform and GitLab
In this project a sample react app was deployed on AWS cloud by using ESC Fargate infrastructure. All infrastructure setup by using terraform.
- Seperate VPC and two subnets formed in different AZs for high availability.
- An application load balancer created for directing incoming request to AWS Fargate.
- ALB and ECS Service configured in seperate security groups and ECS service inbound rule allowed
  for the request that comes from ALB security group.
- ECS Fargate cluster created and ECS service provisioned in two AZs.
- Lastly, react app code deployed on ECS Fargate using GitLab.
![Skeleton](https://github.com/MiranaSGit/myReactApp/blob/main/Skeleton.png)

## Steps:
- Provision VPC, ECR and Gitlab instances using related terraform files under root directory. <br />
  * Replace your key-pair in the variable.tf file. <br />
  * Replace your gitlab-url in the gitlab.tf file. <br />
  * Replace your app-url in the alb.tf file under ecs-alb directory. <br />
- After gitlab instances provisioned, create root password on the gitlab server for gitlab login <br />
  * sudo gitlab-rake "gitlab:password:reset"
- Register runner instance to gitlab server: <br />
  * sudo gitlab-runner register
- Deploy the project using gitlab-ci.yml file. <br />

