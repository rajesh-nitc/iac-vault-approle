## Iac for vault approle with terraform and gitlab as trusted entities

order
1. vault-node
2. manual unseal
3. vault-bastion
    1. vault-provisioner
    2. app1-provisioner
4. gitlab-node
    1. app1-iac

trusted entities
1. terraform
2. gitlab