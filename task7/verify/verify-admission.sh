#!/bin/bash
set -e

# Пробуем создать небезопасные поды — ожидаем ошибку
for f in ../insecure-manifests/*.yaml; do
  echo "Применяю $f"
  if kubectl apply -f "$f" 2>&1 | grep -q "forbidden\|denied"; then
    echo "$f успешно заблокирован"
  else
    echo "$f НЕ был заблокирован — ОШИБКА"
    exit 1
  fi
done

echo "Все insecure манифесты заблокированы."

read -p "Нажмите Enter для завершения..."