argocd app create apps \
    --dest-namespace argocd \
    --dest-server https://kubernetes.default.svc \
    --repo https://github.com/kastenhq/kasten-multicluster-argocd.git \
    --path apps  
argocd app sync apps  
