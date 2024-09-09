# Deploying multiple applications across multiple clusters

In Argo CD, an `ApplicationSet` is a resource that allows you to define and manage multiple applications with similar characteristics, such as source and destination Git repositories, and deployment configurations.

Think of an `ApplicationSet` like a "factory" that generates multiple instances of similar applications based on its configuration. Each instance is still a separate Application resource in the cluster, but they share the same properties defined within the `ApplicationSet`.



# Clusters

First, let's deploy a couple of single node clusters in Azure to accomodate our testing.: 

```bash
RESOURCE_GROUP="mygroup"
CLUSTER1_NAME="mycluster-aks-01"
CLUSTER2_NAME="mycluster-aks-02"
OWNER="brandon.newell@veeam.com"
EXPIREBY="2024-08-30"
ACTIVITY="Test"
VERSION="1.29.5"

# Create CLUSTER1 in eastus
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER1_NAME \
    --location eastus \
    --kubernetes-version $VERSION \
    --node-count 1 \
    --generate-ssh-keys \
    --node-vm-size Standard_B4ms \
    --network-plugin azure \
    --max-pods 100 \
    --tags owner=$OWNER expireby=$EXPIREBY activity="$ACTIVITY"

az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER1_NAME --overwrite-existing
#az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER1_NAME --overwrite-existing --file $HOME/.kube/contexts/${CLUSTER1_NAME}.yaml

# Create CLUSTER2 in centralus
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER2_NAME \
    --location centralus \
    --kubernetes-version $VERSION \
    --node-count 1 \
    --generate-ssh-keys \
    --node-vm-size Standard_B4ms \
    --network-plugin azure \
    --max-pods 100 \
    --tags owner=$OWNER expireby=$EXPIREBY activity="$ACTIVITY"

az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER2_NAME --overwrite-existing
#az aks get-credentials --resource-group $RESOURCE_GROUP --name $CLUSTER2_NAME --overwrite-existing --file $HOME/.kube/contexts/${CLUSTER2_NAME}.yaml

# UPDATE cluster
az aks update -n $CLUSTER1_NAME -g $RESOURCE_GROUP --enable-disk-driver --enable-file-driver --enable-blob-driver --enable-snapshot-controller
az aks update -n $CLUSTER2_NAME -g $RESOURCE_GROUP --enable-disk-driver --enable-file-driver --enable-blob-driver --enable-snapshot-controller
# The above command enabled disk, file and blob. If you don't need any, you can remove it.
```

# ArgoCD
This will install ArgoCD and provide the password and external IP for accessing ArgoCD WebUI.  **Be sure to change the password!**

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
argocd admin initial-password -n argocd
kubectl get svc argocd-server -n argocd
```
## Install ArgoCD CLI [#](#install-argocd-cli)

https://argo-cd.readthedocs.io/en/stable/cli_installation/#installation

# ArgoCD App of App(Sets)
## Bootstrapping ArgoCD

```bash
argocd app create apps \
    --dest-namespace argocd \
    --dest-server https://kubernetes.default.svc \
    --repo https://github.com/fullaware/argocd.git \
    --path appsets  
argocd app sync apps  
```

* OIDC Auth 
* Ingress
* External Secrets - Azure Key Vault
* Creating Location Profiles
* Kasten DR policy
* certmanager Letsencrypt
