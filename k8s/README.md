# k8s

## Dev

### KVM

- `pacman -S qemu libvirt ebtables openbsd-netcat dnsmasq`
- `systemctl enable libvirtd.socket`
- `virsh -c qemu:///system`
- `virsh -c qemu:///session`

### Minikube

- `pacman -S minikube`
- `minikube start`
- `minikube status`
- `minikube dashboard`
- `minikube stop`
- `minikube delete`

### Helm

- `pacman -S helm`
- `helm repo add bitnami https://charts.bitnami.com/bitnami`
