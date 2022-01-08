output "gitlab_ip" {
  value = aws_instance.gitlab.public_ip
}

output "gitlab-runner_ip" {
  value = aws_instance.gitlab-runner.public_ip
}
