# Docker Machine NFS

## Requirements

* [Docker Machine](https://docs.docker.com/machine/) 0.5.0+

## Mac OS X 10.9+

Activates [NFS](https://en.wikipedia.org/wiki/Network_File_System) for an
existing boot2docker box created through
[Docker Machine](https://docs.docker.com/machine/).

:warning: There can be an issue with the NFS under Mac OS X High Sierra (see issue [#79](https://github.com/adlogix/docker-machine-nfs/issues/79) for more info) :warning:

## Windows 10 with WSL

* [Install WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
* [Install VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Setup Docker-machine for WSL](https://www.paraesthesia.com/archive/2018/09/20/docker-on-wsl-with-virtualbox-and-docker-machine/)
* [Install haneWIN NFS server](https://hanewin.net/nfs-e.htm)
* [Install `docker-machine-nfs`](#standalone)
* Mount drives under root (e.g. `/c`) - [Can be configured in `/etc/wsl.conf` - `automount`](https://devblogs.microsoft.com/commandline/automatically-configuring-wsl/)
* Tested with these attributes: `docker-machine-nfs MACHINE-NAME --shared-folder=/c/Users/ --mount-opts="rw,vers=3,tcp,nolock,noacl,async"`

## Install

### Standalone

```sh
curl -s https://raw.githubusercontent.com/adlogix/docker-machine-nfs/master/docker-machine-nfs.sh |
  sudo tee /usr/local/bin/docker-machine-nfs > /dev/null && \
  sudo chmod +x /usr/local/bin/docker-machine-nfs
```

### [Homebrew](http://brew.sh/)

```sh
brew install docker-machine-nfs
```


## Supports

* Virtualbox
* Parallels
* VMware Fusion
* VMware Vsphere
* xhyve

## Usage

* Create `docker-machine` as usual
* Run `docker-machine-nfs`

```sh


                       ##         .
                 ## ## ##        ==               _   _ _____ ____
              ## ## ## ## ##    ===              | \ | |  ___/ ___|
          /"""""""""""""""""\___/ ===            |  \| | |_  \___ \
     ~~~ {~~ ~~~~ ~~~ ~~~~ ~~~ ~ /  ===- ~~~     | |\  |  _|  ___) |
          \______ o           __/                |_| \_|_|   |____/
            \    \         __/
             \____\_______/


Usage: $ docker-machine-nfs <machine-name> [options]

Options:

  -f, --force               Force reconfiguration of nfs
  -n, --nfs-config          NFS configuration to use in /etc/exports. (default to '-alldirs -mapall=\$(id -u):\$(id -g)')
  -s, --shared-folder,...   Folder to share (default to /Users)
  -m, --mount-opts          NFS mount options (default to 'noacl,async')

Examples:

  $ docker-machine-nfs test

    > Configure the /Users folder with NFS

  $ docker-machine-nfs test --shared-folder=/Users --shared-folder=/var/www

    > Configures the /Users and /var/www folder with NFS

  $ docker-machine-nfs test --shared-folder=/var/www --nfs-config="-alldirs -maproot=0"

    > Configure the /var/www folder with NFS and the options '-alldirs -maproot=0'

  $ docker-machine-nfs test --mount-opts="noacl,async,nolock,nfsvers=3,udp,noatime,actimeo=1"

    > Configure the /User folder with NFS and specific mount options.

  $ docker-machine-nfs test --ip 192.168.1.12

    > docker-machine will connect to your host machine via this address

```

## Troubleshooting

- **Failed to mount on WSL**
```
Allow following exe's in "Windows Firewall" or any other firewall software used
   Directory -- c:/Program Files/nfsd
   -  pmapd.exe
   -  nfssrv.exe
   -  nfsd.exe
```

## Credits

* Heavily inspired by @[mattes](https://github.com/mattes) ruby version
[boot2docker-nfs.rb](https://gist.github.com/mattes/4d7f435d759ca2581347).
* @[DzeryCZ](https://github.com/DzeryCZ) added support for Windows with WSL