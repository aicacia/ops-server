# ops-server

kubernetes cluster setup

## Turn swap off for non local installs

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo reboot
```

## Make sure each node has a unique hostname

```bash
echo "example_hostname" > /etc/hostname
hostname -F /etc/hostname
```

## Running

create a cluster

```bash
./install.sh
```

add/remove nodes in a cluster

```bash
./update.sh
```

delete a cluster

```bash
./remove.sh
```
