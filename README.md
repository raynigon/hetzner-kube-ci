# hetzner-kube-ci
A Simple Docker Image containg the hetzner-kube tool. 

Can be used for CI Builds like in Travis or Gitlab to setup Clusters dynamically

## Gitlab Example

```yml
build-cluster:
  image: raynigon/hetzner-kube:latest
  script:
    - // Save SSH Key to ~/.ssh/id_resa 
    - hetzner-kube context add $CLUSTER_NAME | $HETZNER_API_TOKEN
    - hetzner-kube ssh-key add --name $CLUSTER_NAME
    - hetzner-kube cluster create --name $CLUSTER_NAME --ssh-key $SSH_KEY_NAME
    - hetzner-kube cluster kubeconfig --name $CLUSTER_NAME
  artifacts:
    paths:
    - kubeconfig.yml

install-openebs:
  image: lachlanevenson/k8s-kubectl:latest
  script:
    - kubectl apply -f https://raw.githubusercontent.com/openebs/openebs/master/k8s/openebs-operator.yaml
    - kubectl apply -f https://raw.githubusercontent.com/openebs/openebs/master/k8s/openebs-storageclasses.yaml

install-helm-tiller:
  image: lachlanevenson/k8s-kubectl:latest
  before_script:
    - curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
  script:
    - cat tiller-config.yml | kubectl apply -f -'
    - helm init --service-account tiller

install-ingress:
  image: lachlanevenson/k8s-kubectl:latest
  before_script:
    - curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
  script:
    - helm install --name ingress --set rbac.create=true,controller.kind=DaemonSet,controller.service.type=ClusterIP
```
