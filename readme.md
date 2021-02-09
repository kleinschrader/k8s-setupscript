# Kubernetes setup scrips

This is just a simple script to setup k8s vms with ceph storage.

I mainly uploaded it because i keep wiping my drives and decided i might as well make it public.

The RAM usage has a rough target of 120GB (because thats how much my pc has) so you might need to adjust it.

I will write more detailed instructions later.

## Usage

```bash
  sudo ./createCluster.sh
  ansible-playbook -i inventory.ini setupK8S.yaml
```
