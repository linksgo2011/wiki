---
title: AWS Certificate Manager
categories: aws
toc: true
---

official website: https://aws.amazon.com/certificate-manager/

AWS Certificate Manager is a service that lets you easily provision, manage, and deploy Secure Sockets Layer/Transport Layer Security (SSL/TLS) certificates for use with AWS services. SSL/TLS certificates are used to secure network communications and establish the identity of websites over the Internet. AWS Certificate Manager removes the time-consuming manual process of purchasing, uploading, and renewing SSL/TLS certificates. With AWS Certificate Manager, you can quickly request a certificate, deploy it on AWS resources such as Elastic Load Balancers, Amazon CloudFront distributions, and APIs on API Gateway, and let AWS Certificate Manager handle certificate renewals. SSL/TLS certificates provisioned through AWS Certificate Manager are free. You pay only for the AWS resources you create to run your application.

## Benefits ##

- Managed Certificate Renewal
- Centrally Manage Certificates on the AWS Cloud
- Get Certificates Easily
- Free for the Certificates

## Questions ##

- if support session stick answer:

## Options ##

ACM 支持从AWS上请求一个由Amazon的证书和自己上传的证书。

### 使用Amazon的证书

Pros

- 免费
- 支持自动续期
- 支持绝大多客户端
- 使用HTTPS协议,因此可以stick session
- 自动续期

Cons

- 需要validate domain的拥有者,因此不能在内网中使用
- 只能在ELB中使用不能在EC2中
- 数量受限

### 使用导入自有证书

Pros

- 可以使用自定义证书
- 数量不受限
- 可以在内网使用

Cons

- 需要自己管理续期问题
- 需要使用API更新证书

## 更新ELB证书的方法 ##

- 使用AWS API或者命令行
- 使用ansible的一些role来执行 http://docs.ansible.com/ansible/ec2_elb_lb_module.html#options