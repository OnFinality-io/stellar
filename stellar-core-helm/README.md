# Stellar-core chart

Helm charts for Stellar-Core

## Stellar Core

### Single node

```
./stellar install
```

### Full Validator
```
./stellar -f install
```

### Uninstall

```
./stellar uninstall
```

```
helm repo update
helm dependency update stellar-core
helm install \
  --namespace stellar-testnet \
  --name stellar-core \
  --values stellar-core.testnet.values.yaml \
  stellar-core
```


