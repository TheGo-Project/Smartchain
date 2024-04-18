**`Deploying EVM Node on Kubernetes`**

**1.	Docker setup**

**�	Build Docker Image:**
docker build -t gsmc-node .

**Tag Docker Image:**
	docker tag gsmc-node gcr.io/health-hero-bot/gsmc-node:v3
 
**2.	Push Docker Images to Google Container Registry:**
	docker push gcr.io/health-hero-bot/gsmc-node:v3
	docker push gcr.io/health-hero-bot/gsmc

**3.	Create Kubernetes Cluster**
	gcloud container clusters create "mygeth-cluster" --zone "us-central1-a" --project "health-hero-bot"

	gcloud container clusters get-credentials mygeth-cluster --zone us-central1-a --project health-hero-bot
 
	**Apply Kubernetes Configurations:**
	kubectl apply -f geth-deployment.yaml
	kubectl apply -f geth-service.yaml

Kubernetes Management Commands:
kubectl get svc
kubectl get pods
kubectl exec -it geth-deployment-5fc8f78c99-lhtqj -- /bin/sh
kubectl delete pods -l app=geth

**3. Test Deployment of EVM (Ethereum Virtual Machine)**

	Geth attach http://34.42.161.152:8545
