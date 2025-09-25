#!/bin/bash
set -euo pipefail

if ! command -v kubectl &> /dev/null; then
  echo "Instalando kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
fi

if ! command -v kind &> /dev/null; then
  echo "Instalando kind..."
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind
fi

sudo usermod -aG docker $USER

if ! command -v docker &> /dev/null; then
  echo "Instalando Docker..."
  sudo yum install -y docker
  sudo systemctl start docker
  sudo systemctl enable docker
fi

if ! getent group docker > /dev/null; then
  echo "Criando grupo docker..."
  sudo groupadd docker
fi

echo "===> Verificando se o cluster local Kind já existe..."

if sudo kind get clusters | grep -q "^prod-finance$"; then
  echo "Cluster 'prod-finance' já existe. Pulando criação."
else
  echo "Criando cluster local com Kind..."
  sudo kind create cluster --name prod-finance --wait 60s --config kind-config.yaml
fi

mkdir -p $HOME/.kube
KUBECONFIG_FILE="$HOME/.kube/config-kind-prod-finance"
export KUBECONFIG="$KUBECONFIG_FILE"

kind get kubeconfig --name prod-finance > "$KUBECONFIG_FILE"

kubectl config use-context kind-prod-finance

echo \"===> Aplicando manifests do diretório K8s-manifests/...\"
kubectl apply -f K8s-manifests/ --validate=false

echo \"===> Aguardando rollout dos deployments...\"
for DEPLOY in mysql; do
  echo \"----> Validando $DEPLOY\"
  kubectl rollout status deployment/$DEPLOY --timeout=120s
done


echo \"✅ Deploy finalizado com sucesso!\"
