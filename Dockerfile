# syntax=docker/dockerfile:1
# FROM hashicorp/terraform:1.0.2
FROM ubuntu:20.04

# install terraform
RUN apt update -y && \
    apt install wget -y && \
    wget https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_linux_amd64.zip && \
    apt install zip -y && \
    unzip terraform_1.0.0_linux_amd64.zip && \
    mv terraform /usr/local/bin/

# server-terraform files
COPY . /app

WORKDIR /app

CMD bash /app/start.sh