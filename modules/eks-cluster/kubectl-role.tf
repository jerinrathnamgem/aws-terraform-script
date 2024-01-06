################################# IAM ROLE FOR KUBECTL FOR CODEBUILD ##################################

resource "aws_iam_role" "kubectl_role" {
  count = 1

  name = "${var.name}-kubectl-role"

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "sts:AssumeRole"
          ]
          Effect = "Allow"
          Principal = {
            AWS = "arn:aws:iam::${var.account_id}:root"
          }
        }
      ]
    }
  )
}
resource "aws_iam_role_policy" "kubectl_policy" {
  count = 1

  name = "${var.name}-kubectl-policy"
  role = aws_iam_role.kubectl_role[0].id

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "eks:Describe*"
          ]
          Effect   = "Allow"
          Resource = "${aws_eks_cluster.cluster.arn}"
        }
      ]
    }
  )
}