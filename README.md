# Simple Golang based application managed by Terraform and Kubernetes.

Deployment contains Golang-app, Java, Prometheus and Postgresql and uses AWS ACM and Network Load Balancer.

Directories description:

`app` - Golang application opens a database connection, sleeps for a random time and exposes monitoring data (how many connections have been made since boot as 
`app_processed_pg_connections` metric) via a `/metrics` endpoint.

`modules` - Terraform modules.

Deployed application will be available as: https://domain/metrics and Prometheus: https://domain/monitoring where `domain` is variable from terraform.tfvars.

The Docker image can be rebuilt by (multi-stage building):

```
docker build --target builder -t alrf/go-web-app:latest . --network=host
```

```
docker build --target app -t alrf/go-web-app:latest . --network=host
```

```
docker push alrf/go-web-app:latest
```

## How to deploy

AWS ACM and Network Load Balancer are used.

Replace `CHANGE_ME` in terraform.tfvars file to proper values.

`terraform init`

`terraform apply -target=module.common`

`terraform apply`


## How to remove deployment

`terraform destroy`
