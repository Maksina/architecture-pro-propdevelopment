## Запуск и проверка

# Запуск Minikube
```console
minikube start --network-plugin=cni --cni=calico
```

# Запуск сервисов
```console
./run.sh
```

# Тестирование

1. front-end -> back-end-api (успешный кейс)
    ```console
    kubectl run debug-1 --image=alpine --labels role=front-end --rm -it -- sh
    wget -qO- --timeout=2 http://back-end-api-app
    ```

2. front-end -> admin-back-end-api (неуспешный кейс)
    ```console
    kubectl run debug-2 --image=alpine --labels role=front-end --rm -it -- sh
    wget -qO- --timeout=2 http://admin-back-end-api-app
    ```

3. admin-front-end -> admin-back-end-api (успешный кейс)
    ```console
    kubectl run debug-3 --image=alpine --labels role=admin-front-end --rm -it -- sh
    wget -qO- --timeout=2 http://admin-back-end-api-app
    ```

4. admin-front-end -> back-end-api (неуспешный кейс)
    ```console
    kubectl run debug-4 --image=alpine --labels role=admin-front-end --rm -it -- sh
    wget -qO- --timeout=2 http://back-end-api-app
    ```
