# k8s

## Dev

### KVM

- `pacman -S qemu libvirt ebtables openbsd-netcat dnsmasq`
- `systemctl enable libvirtd.socket`
- `virsh -c qemu:///system`
- `virsh -c qemu:///session`
- `usermod -aG libvirt kevin`

### Minikube

- `pacman -S minikube`
- `minikube config set vm-driver kvm2`
- `minikube start`
- `minikube status`
- `minikube dashboard`
- `minikube stop`
- `minikube delete`

### Helm

- `pacman -S helm`
