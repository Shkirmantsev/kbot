# kbot
Devops repository from scratch

## Description

functional Telegram bot with root command and settings. It will be able to process messages from users and respond to them

## Install pre-commit check

```bash
curl https://raw.githubusercontent.com/Shkirmantsev/kbot/develop/install-local-hooks.sh | sh

```

### Enable pre-commit check
```bash
git config --global --bool hooks.gitleaks true
```


## Deploy (depends on shell)

Currently supports only local cluster, without (Volt or other security tools). Image is pulled from gcr.io registry by default

### Steps:

in shell:

#### Prepare environment
```bash
gcloud auth login
```

```bash
gcloud config set project shkirmantsev
```

```bash
export TF_VAR_GITHUB_OWNER=<owner>
```

## In Google Cloud Shell, clone reposytory (use SSH or token), then:

```bash
read -s TELE_TOKEN
```

```bash
export TELE_TOKEN=$TELE_TOKEN
```

```bash
export TF_VAR_TELE_TOKEN=$TELE_TOKEN
```

```bash
read -s GITHUB_TOKEN
```

```bash
export GITHUB_TOKEN=$GITHUB_TOKEN
```

```bash
export TF_VAR_GITHUB_TOKEN=$GITHUB_TOKEN
```

######## if cloud shell ############

```shell
PROJECT_ID=shkirmantsev
```

```shell
SA_EMAIL="github-authentication-by-gcr@shkirmantsev.iam.gserviceaccount.com"
```

``` shell
mkdir secrets
```

```shell
gcloud iam service-accounts keys create ./secrets/gcr-token.json \
  --iam-account $SA_EMAIL \
  --project $PROJECT_ID
```

```shell
export GCR_JSON_TOKEN="$(cat ./secrets/gcr-token.json)"
```
```shell
export TF_VAR_GCR_JSON_TOKEN=$GCR_JSON_TOKEN
```
------

### Remove "gke-workload-identity" and "kms" modules from main.tf from in cloned project.

### Deploy terraform.


```bash
terraform init
```

```bash
terraform validate
```

```bash
terraform apply
```

```bash
gcloud container clusters get-credentials main --zone us-central1-c --project shkirmantsev
```

#### Create namespace with declarative approach:

With previous steps the https://github.com/< owner >/kbot-flux-gitops-config flux system repository will be created

1) add in kbot-flux-gitops-config repo -> clusters -> demo -> ns.yaml:
```yaml
apiVersion: v1
kind: Namespace
metadata:
    name: demo
```

2) add in kbot-flux-gitops-config repo -> clusters -> demo -> kbot-gr.yaml (source repository, after commit wait 2 min):
```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: kbot
  namespace: demo
spec:
  interval: 1m0s
  ref:
    branch: main
  url: https://github.com/shkirmantsev/kbot
```

3) Pass secrets to demo namespace (For your email and json. in next releases will be automatically and declarative):

```shell
kubectl create secret docker-registry regcred -n demo \
--docker-server=gcr.io \
--docker-username=_json_key \
--docker-password=$GCR_JSON_TOKEN \
--docker-email=shkirmntsev@gmail.com
```

(Optional, if not use kms and wmi):
```shell
kubectl create secret generic kbot --from-literal=token=${TELE_TOKEN} --namespace=demo
```

4) add in kbot-flux-gitops-config repo -> clusters -> demo -> kbot-hr.yaml (helm releases):
```yaml
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: kbot
  namespace: demo
spec:
  chart:
    spec:
      chart: ./helm
      reconcileStrategy: ChartVersion
      sourceRef:
        kind: GitRepository
        name: kbot
  interval: 1m0s
```

5) Pass GCR credentials to deploy:

```shell
kubectl patch deployment kbot  -n demo --type='json' -p='[{"op": "add", "path": "/spec/template/spec/imagePullSecrets", "value":[{"name": "regcred"}]}]'
```

6) Add back the "gke-workload-identity" and "kms" modules in main file (see original "main.tf")
7) Add in kbot-flux-gitops-config repo -> clusters/flux-system/sa-patch.yaml:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kustomize-controller
  namespace: flux-system
  annotations:
    iam.gke.io/gcp-service-account: kustomize-controller@shkirmantsev.iam.gserviceaccount.com
```
8) Add in kbot-flux-gitops-config repo -> clusters/flux-system/sops-patch.yaml:
  
```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: flux-system
  namespace: flux-system
spec:
  interval: 10m0s
  path: ./clusters
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  decryption:
    provider: sops
```

9) Add in kbot-flux-gitops-config repo -> clusters/flux-system/kustomization.yaml:
  
```yaml
apiVersion: kustomize.config.k8s.io/v1
kind: Kustomization
resources:
- gotk-components.yaml
- gotk-sync.yaml
patches:
- path: sops-patch.yaml
  target: 
    kind: Kustomization
- path: sa-patch.yaml
  target:
    kind: ServiceAccount
    name: kustomize-controller
```



```bash
terraform init
```

```bash
terraform validate
```

```bash
terraform apply
```

10) Install sops

``` bash
wget https://github.com/getsops/sops/releases/download/v3.7.3/sops-v3.7.3.linux.amd64
chmod +x sops-v3.7.3.linux.amd64
mv sops-v3.7.3.linux.amd64 sops
```

11) Create secret ("secret-enc.yaml") and copy to file in flux "kbot-flux-gitops-config" Repository clusters/demo/secret-enc.yaml

```shell
kubectl create secret generic kbot --from-literal=token=$TELE_TOKEN --namespace=demo --dry-run=client -o yaml > secret.yaml
```

```yaml
./sops --encrypt --gcp-kms projects/shkirmantsev/locations/global/keyRings/sops-flux/cryptoKeys/sops-key-flux secret.yaml > secret-enc.yaml
```



If pods were not started correctly, then remove they (flux will recreate pods automatically)

```shell
kubectl get pods -n demo
```

Check pod:
```shell
kubectl describe pod kbot-7d7496b48d-cgxlp -n demo
```

Remove broken pod:
```shell
kubectl delete pod kbot-7d7496b48d-p9nkx -n demo
```


## Reference in Telegram

https://t.me/shkirmantsev_bot

### Examples of commands:
- ```/start```
- ```/stop```
- ```/start hello```

## Clean Resources(in shell):

```shell
terraform destroy
```