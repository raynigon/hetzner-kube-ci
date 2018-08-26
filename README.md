# hetzner-kube-ci
A Simple Docker Image containg the hetzner-kube tool. 

Can be used for CI Builds like in Travis or Gitlab to setup Clusters dynamically

## Gitlab Example

```yml
variables:
  CLUSTER_NAME: "<ENTER_YOUR_CLUSTER_NAME>"
# Repository Defined Variables  
  SSH_KEY_NAME: id_rsa

stages:
  - validate
  - build
  - configure
  - install

test-configuration:
  image: python:latest
  stage: validate
  script:
    # Ensure all variables were set
    - python ci/check_variables.py
    # Check that the SSH Key exists
    - test -e $SSH_KEY_NAME
    - test -e $SSH_KEY_NAME.pub
  only:
  - web

build-cluster:
  image: raynigon/hetzner-kube:latest
  stage: build
  script:
    - hetzner-kube context add $CLUSTER_NAME | $HETZNER_API_TOKEN
    - hetzner-kube ssh-key add --name $CLUSTER_NAME --private-key-path $SSH_KEY_NAME --public-key-path SSH_KEY_NAME.pub
  artifacts:
    paths:
    - kubeconfig.yml
  only:
  - web

install-openebs:
  image: lachlanevenson/k8s-kubectl:latest
  stage: configure
  before_script:
    - mv kubeconfig.yml ~/.kube/config
  script:
    - kubectl apply -f https://raw.githubusercontent.com/openebs/openebs/master/k8s/openebs-operator.yaml
    - kubectl apply -f https://raw.githubusercontent.com/openebs/openebs/master/k8s/openebs-storageclasses.yaml
  only:
  - web

install-helm-tiller:
  image: lachlanevenson/k8s-kubectl:latest
  stage: configure
  before_script:
    - mv kubeconfig.yml ~/.kube/config
    - curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
  script:
    - cat tiller-config.yml | kubectl apply -f -'
    - helm init --service-account tiller
  only:
  - web

install-ingress:
  image: lachlanevenson/k8s-kubectl:latest
  stage: install
  before_script:
    - mv kubeconfig.yml ~/.kube/config
    - curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
  script:
    - helm install --name ingress --set rbac.create=true,controller.kind=DaemonSet,controller.service.type=ClusterIP
  only:
  - web
```
