# ops-server

## Turn swap off

```bash
sudo swapoff -a 
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo reboot
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