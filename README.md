# ops-server

## Turn swap off

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

```bash
./src/run.sh install
```

```bash
./src/run.sh remove
```