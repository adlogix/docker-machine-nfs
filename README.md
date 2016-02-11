# Docker Machine NFS

Activates [NFS](https://en.wikipedia.org/wiki/Network_File_System) for an
existing boot2docker box created through
[Docker Machine](https://docs.docker.com/machine/).

## Requirements

* Mac OS X 10.9+
* [Docker Machine](https://docs.docker.com/machine/) 0.5.0+

## Install

```sh
curl -s https://raw.githubusercontent.com/adlogix/docker-machine-nfs/master/docker-machine-nfs.sh |
  sudo tee /usr/local/bin/docker-machine-nfs > /dev/null && \
  sudo chmod +x /usr/local/bin/docker-machine-nfs
```

## Supports

* Virtualbox
* Paralells
* VMware Fusion
* xhyve

## Usage

```sh


                       ##         .
                 ## ## ##        ==               _   _ _____ ____
              ## ## ## ## ##    ===              | \ | |  ___/ ___|
          /"""""""""""""""""\___/ ===            |  \| | |_  \___ \
     ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~     | |\  |  _|  ___) |
          \______ o           __/                |_| \_|_|   |____/
            \    \         __/
             \____\_______/


Usage: ./docker-machine-nfs.sh <machine-name> [options]

Options:

  -f, --force               Force reconfiguration of nfs
  -n, --nfs-config          NFS configuration to use in /etc/exports. (default to '-alldirs -mapall=$(id -u):$(id -g)')
  -s, --shared-folder,...   Folder to share (default to /Users)

Examples:

  $ docker-machine-nfs test

    > Configure the /Users folder with NFS

  $ docker-machine-nfs test --shared-folder=/Users --shared-folder=/var/www

    > Configures the /Users and /var/www folder with NFS

  $ docker-machine-nfs test --shared-folder=/var/www --nfs-config="-alldirs -maproot=0"

    > Configure the /var/www folder with NFS and the options '-alldirs -maproot=0'
```

## Credits

Heavily inspired by @[mattes](https://github.com/mattes) ruby version
[boot2docker-nfs.rb](https://gist.github.com/mattes/4d7f435d759ca2581347).
