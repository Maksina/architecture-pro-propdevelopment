#!/bin/bash

# Определяем директорию, где находится скрипт
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

AUDIT_LOG="$SCRIPT_DIR/audit.log"
OUTPUT_FILE="$SCRIPT_DIR/audit-extract.json"

# Проверяем наличие audit.log
if [[ ! -f "$AUDIT_LOG" ]]; then
    echo "Файл audit.log не найден в $SCRIPT_DIR" >&2
    exit 1
fi

# Очищаем выходной файл
> "$OUTPUT_FILE"

echo "Фильтрация audit.log из: $AUDIT_LOG"
echo "Отфильтрованные события будут записаны в: $OUTPUT_FILE"
echo ""

# 1. Доступ к секретам (get или list secrets)
echo "[+] Поиск: доступ к secrets (verb=get или list)"
jq -r 'select(.objectRef.resource == "secrets" and (.verb == "get" or .verb == "list"))' "$AUDIT_LOG" >> "$OUTPUT_FILE"

# 2. kubectl exec в чужие поды (create + subresource=exec)
echo "[+] Поиск: kubectl exec (subresource=exec)"
jq -r 'select(.verb == "create" and .objectRef.subresource == "exec")' "$AUDIT_LOG" >> "$OUTPUT_FILE"

# 3. Привилегированные поды (pods с privileged контейнерами)
echo "[+] Поиск: запуск привилегированных подов"
jq -r '
  select(
    .objectRef.resource == "pods" and
    (.requestObject.spec.containers | arrays | any(.securityContext?.privileged == true))
  )
' "$AUDIT_LOG" >> "$OUTPUT_FILE"

# 4. Упоминания audit-policy.yaml (изменение/удаление политики аудита)
echo "[+] Поиск: упоминания audit-policy"
grep -i 'audit-policy' "$AUDIT_LOG" >> "$OUTPUT_FILE"

# 5. Создание RoleBinding
echo "[+] Поиск: создание RoleBinding"
jq -r 'select(.objectRef.resource == "rolebindings" and .verb == "create")' "$AUDIT_LOG" >> "$OUTPUT_FILE"

echo ""
echo "Фильтрация завершена. Файл: $OUTPUT_FILE"
read -p "Нажмите Enter для завершения..."