cd gke-iac

cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars and set your project_id and CIDRs

terraform plan
terraform apply



$(terraform output -raw gcloud_connect)
# or:
gcloud container clusters get-credentials $(terraform output -raw cluster_name) \
  --region $(terraform output -raw region) \
  --project $(terraform output -raw project_id 2>/dev/null || echo "<your-project-id>")
