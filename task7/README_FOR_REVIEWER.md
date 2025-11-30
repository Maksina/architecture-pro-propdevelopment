## Алгоритм

1.  Применение namespace:
```console
kubectl apply -f 01-create-namespace.yaml
```

2. Установка Gatekeeper
```console
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/release-3.14/deploy/gatekeeper.yaml
```

3. Загрузка ConstraintTemplates и Constraints
```console
kubectl apply -f gatekeeper/constraint-templates/
kubectl apply -f gatekeeper/constraints/
```

4. Запуск верификации
```console
cd verify
./verify-admission.sh  
./validate-security.sh 
```