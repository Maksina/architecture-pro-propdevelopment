#!/bin/bash

set -e

CERT_DIR="k8s-users"
CLUSTER_NAME="minikube"

mkdir -p "$CERT_DIR"

create_user() {
  local username=$1
  echo "Создание пользователя: $username"

  openssl genrsa -out "$CERT_DIR/$username.key" 2048

  openssl req -new \
    -key "$CERT_DIR/$username.key" \
    -out "$CERT_DIR/$username.csr" \
    -subj "//CN=$username"

  openssl x509 -req \
    -in "$CERT_DIR/$username.csr" \
    -CA ~/.minikube/ca.crt \
    -CAkey ~/.minikube/ca.key \
    -CAcreateserial \
    -out "$CERT_DIR/$username.crt" \
    -days 365

  kubectl config set-credentials "$username" \
    --client-certificate="$CERT_DIR/$username.crt" \
    --client-key="$CERT_DIR/$username.key"

  kubectl config set-context "$username-context" \
    --cluster="$CLUSTER_NAME" \
    --user="$username"

  echo ">>> Готово: $username (контекст: $username-context)"
  echo
}

if [ ! -f ~/.minikube/ca.crt ] || [ ! -f ~/.minikube/ca.key ]; then
  echo "Minikube CA не найден. Запустите: minikube start"
  exit 1
fi

if ! kubectl cluster-info >/dev/null 2>&1; then
  echo "Kubectl не подключается к кластеру. Запустите Minikube."
  exit 1
fi

# Создаём трёх пользователей
create_user "admin-user"
create_user "devops-user"
create_user "viewer-user"
read -p "Нажмите Enter для завершения..."