k3d cluster create --no-lb --k3s-arg '--disable=local-storage,metrics-server,servicelb,traefik@server:0' --k3s-arg '--kube-apiserver-arg=feature-gates=EphemeralContainers=true@server:0'

linkerd install|k apply -f -

linkerd viz install|k apply -f -

k -n linkerd get cm linkerd-identity-trust-roots -ojson | jq '.data."ca-bundle.crt"' | tr -d '"' | sed 's/\\n/\n/g' | step certificate inspect

k -n linkerd get secrets linkerd-identity-issuer -ojson | jq '.data."crt.pem"' | tr -d '"' | base64 -d | step certificate inspect

k apply -f https://run.linkerd.io/emojivoto.yml

k -n emojivoto port-forward web-svc 8080:80

k debug node/k3d-k3s-default-server-0 -it --image nicolaka/netshoot

tcpdump -i any | grep GET

k -n emojivoto get deploy -oyaml | linkerd inject - | k apply -f -

linkerd viz tap -n emojivoto deploy/web

linkerd viz dashboard

k -n emojivoto get po web-xxx -oyaml|y

linkerd identity -n emojivoto web-xxx

# POLICY
# -------
k -n emojivoto logs -f vote-bot-xxx vote-bo

kubectl annotate ns emojivoto config.linkerd.io/default-inbound-policy=deny

k -n emojivoto delete po web-xxx

k -n emojivoto describe po web-xxx

k apply -f probes-policy.yml

linkerd authz -n emojivoto deploy

k apply -f app-policy.yml

k -n emojivoto rollout restart deploy

linkerd authz -n emojivoto deploy

curl -sL https://run.linkerd.io/emojivoto.yml \
  | sed 's/name: emojivoto/name: emojivoto-2/; s/namespace: emojivoto/namespace: emojivoto-2/' \
  | linkerd inject - \
  | kubectl apply -f -

linkerd viz authz -n emojivoto deployment/web

k -n emojivoto logs -f web-57f9bbf5fd-bmhhb -c linkerd-proxy

https://buoyant.io/2021/12/14/locking-down-network-traffic-between-kubernetes-namespaces/
