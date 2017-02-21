# kubernetes-terraform-aws

## Prerequisites
* Install [Terraform][1]
* Create a `terraform.tfvars` file in the top-level directory of the repo with content like:

    ```
    ssh_key_name = name_of_my_key_pair_in_AWS
    access_key = my_AWS_access_key
    secret_key = my_AWS_secret_key
    ```
    This file is ignored by git.

## Dashboard
__Prerequisites__
* Install Python (2.7+)
* Install [Cachet][2] 

* Edit `updateStatus.py` file, lines 7-8

    ```
    ENDPOINT = 'http://test.com/api/v1'
    API_TOKEN = 'token_api'
    ```

__Usage__

1. To list an execution plan, run `terraform plan`
2. To apply the plan, run `python updateStatus.py`

## Inspiration
* [kubernetes-coreos-terraform][3]

[1]: https://www.terraform.io/
[2]: https://cachethq.io/
[3]: https://github.com/bakins/kubernetes-coreos-terraform
