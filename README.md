# Kubernetes-TF-Hardway

Following the instructions from Kelsey Hightower's but using
Terraform to provision infrasturcture instead.

This is based on Azure translated version from [here](https://github.com/ivanfioravanti/kubernetes-the-hard-way-on-azure/blob/master/docs/03-compute-resources.md)
since I only have access to Azure.

## Prerequisites
1. *ssh keypair* - I couldn't find a good way for terraform to detect
if the key pair exists or not.  I currently hardcode terraform to
look for the public key at ~/.ssh/id_rsa.pub
