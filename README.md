## Iac for vault approle with terraform as a trusted entity

order
1. vault-node
2. manual unseal
3. vault-bastion
    1. vault-provisioner
    2. app1-provisioner
    3. app1-iac

trusted entity
1. terraform