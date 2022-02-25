FROM zenika/terraform-aws-cli:latest as BASE

COPY main.tf .
COPY .terraform.lock.hcl .

RUN terraform init
RUN rm main.tf .terraform.lock.hcl
