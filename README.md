# banco-api

Este repositório contém os manifestos e scripts para provisionar o banco de dados MySQL utilizado pelos serviços da aplicação.

## Funcionalidade

Cria um banco MySQL 8.0 no Kubernetes, com três bancos separados para os serviços:
- `accounts_db`
- `transactions_db`
- `balance_db`

## Como usar

1. **Pré-requisitos:**
	- Cluster Kubernetes configurado
	- Kubectl instalado

2. **Crie o secret com credenciais do MySQL:**
	```bash
	kubectl apply -f K8s-manifests/mysql-secret.yaml
	```

3. **Aplique o manifesto do MySQL:**
	```bash
	kubectl apply -f K8s-manifests/mysql.yaml
	```

4. **Verifique se o banco está rodando:**
	```bash
	kubectl get pods -l app=mysql
	kubectl get svc mysql
	```

## Observações importantes

- O volume do MySQL está configurado como `emptyDir`, ou seja, os dados não são persistidos se o pod for reiniciado. Para produção, altere para um `PersistentVolumeClaim`.
- A senha root e de usuário está definida como `examplepassword` apenas para testes. Altere para uma senha forte em ambientes reais.
- Os serviços de aplicação devem usar o nome do serviço MySQL (`mysql`) para se conectar ao banco.

## Script de Deploy

O script `deploy_k8s.sh` automatiza a aplicação dos manifestos e valida o rollout dos serviços. Certifique-se de ajustar o nome do diretório dos manifestos se necessário.

## Licença

Consulte o arquivo LICENSE para mais detalhes.