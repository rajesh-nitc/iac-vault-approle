# Iac
Iac for vault approle with terraform and gitlab as trusted entities
## Order

1. vault-node
    1. unseal-manually
2. vault-bastion
    1. vault-provisioner
    2. app1-provisioner
    3. app1-iac

trusted entities
1. terraform
2. gitlab
