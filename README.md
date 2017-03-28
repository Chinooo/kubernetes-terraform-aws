# kubernetes-terraform-aws

## Prerequisites
* Install [Terraform][1]
* AWS credentials and a pem file

## Usage

1. Update the `terraform.tfvars` file with your AWS credentials:

    ```
    access_key = my_AWS_access_key
    secret_key = my_AWS_secret_key
    ssh_key_name = name_of_my_PEM_file_for_AWS
    ```
2. Move your pem file to the root of the project
3. Execute terraform
    ```
    $ terraform apply
    ```

__Useful commands__
`terraform validate`
`terraform plan`
`terraform graph | dot -Tpng > graph.png`
`watch kubectl get pods -n devops`

## TODO
* Use packer
* Create our EFS
* Use vault
* Apply best practices
* HA cluster

## Inspiration
* [kubernetes-coreos-terraform][2]

[1]: https://www.terraform.io/
[2]: https://github.com/bakins/kubernetes-coreos-terraform
