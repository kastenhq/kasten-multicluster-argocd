# Deploying multiple applications across multiple clusters

In Argo CD, an `ApplicationSet` is a resource that allows you to define and manage multiple applications with similar characteristics, such as source and destination Git repositories, and deployment configurations.

An `ApplicationSet` serves as a template for creating multiple related applications. It defines the common properties, such as Git repository URLs, application names, and deployment configurations, that are shared among the individual applications being managed by Argo CD.

Think of an `ApplicationSet` like a "factory" that generates multiple instances of similar applications based on its configuration. Each instance is still a separate Application resource in the cluster, but they share the same properties defined within the `ApplicationSet`.

By using an `ApplicationSet`, you can manage multiple related applications with similar configurations through a single resource definition, making it easier to maintain and scale your Argo CD setup.

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
argocd admin initial-password -n argocd
```