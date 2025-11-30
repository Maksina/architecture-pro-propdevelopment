#!/bin/bash
set -e

for f in ../secure-manifests/*.yaml; do
  echo "Применяю $f"
  kubectl apply -f "$f"
done

kubectl wait --for=condition=Ready pod -n audit-zone --timeout=60s --all

kubectl get pods -n audit-zone

read -p "Нажмите Enter для завершения..."