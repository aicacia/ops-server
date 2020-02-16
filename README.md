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

## setup envrc

```bash
cp .envrc.example .envrc
# change any necessary variables
# if direnv is installed
direnv allow
# if not
source .envrc
```

## Local

create a cluster

```bash
./src/install.sh
```

add/remove nodes in a cluster

```bash
./src/update.sh
```

delete a cluster

```bash
./src/remove.sh
```