# Not managed by any built-in Renovate manager: see session/07 for how a
# custom datasource (endoflife.date) + regex manager keep this up to date.
variable "eks_cluster_version" {
  description = "Kubernetes version of the (imaginary) EKS cluster"
  type        = string
  # renovate: datasource=custom.endoflife depName=amazon-eks versioning=loose
  default = "1.29"
}
