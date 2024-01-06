protocolHttp: true
service:
  type: NodePort
  # Dashboard service port
  externalPort: 80
  annotations: {
    alb.ingress.kubernetes.io/healthcheck-path: "/dashboard/"
  }
serviceAccount:
  create: true
  name: ${service_account_name}

extraArgs:
  - --enable-insecure-login
#   - --enable-skip-login
#   - --system-banner="Welcome to Kubernetes"