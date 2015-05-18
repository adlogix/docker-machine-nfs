# Docker Machine NFS

Activates NFS for an existing boot2docker box created through Docker Machine. 

## Install

```sh
# Mac OS X
sudo curl -o /usr/local/bin/docker-machine-nfs https://raw.githubusercontent.com/adlogix/docker-machine-nfs/master/docker-machine-nfs.sh && \
sudo chmod +x /usr/local/bin/docker-machine-nfs 
```

## Usage

```sh
docker-machine-nfs <machine-name> [--force]
```

## Demo

![Docker Machine NFS](https://raw.githubusercontent.com/adlogix/docker-machine-nfs/master/readme_image.gif)
