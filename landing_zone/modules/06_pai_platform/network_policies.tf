# ============================================
# KUBERNETES NETWORK POLICIES FOR AI WORKLOADS
# Requirement: Pod-to-pod communication restricted
# Training pods can talk to parameter server but not inference pods
# ============================================

# Note: These are Kubernetes resources that would be applied to the ACK cluster
# via kubectl or a Helm chart. Shown as reference for your HLD.

resource "alicloud_cs_kubernetes_addon" "network_policy" {
  cluster_id = alicloud_cs_managed_kubernetes.gpu.id
  name       = "terway-network-policy"
  version    = "latest"
}

# The following is a YAML representation of the network policy
# In practice, apply via kubectl after cluster creation

locals {
  deny_training_to_inference_policy = <<YAML
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-training-to-inference
  namespace: ai-workloads
spec:
  podSelector:
    matchLabels:
      workload-type: training
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          workload-type: inference
    ports:
    - protocol: TCP
      port: 8080
YAML
}