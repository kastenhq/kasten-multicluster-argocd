argocd app create apps \
    --dest-namespace argocd \
    --dest-server https://kubernetes.default.svc \
    --repo https://github.com/fullaware/argocd.git \
    --path apps  
argocd app sync apps  