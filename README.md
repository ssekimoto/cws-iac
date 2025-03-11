## Terraform で Cloud Workstations を作成するメモ
実行には、権限付与が必要
Infrastracture Manager に SA を付与するか、

```shell
gcloud auth application-default login
```
を実行

*実行前の初期化*
```shell
terraform init
```
*リソースの確認*
```shell
terraform plan
```
*実行*
```shell
terraform apply
```

