# Docker Machine NFS

Activates [NFS](https://en.wikipedia.org/wiki/Network_File_System) for an
existing boot2docker box created through
[Docker Machine](https://docs.docker.com/machine/).

## Requirements

* Mac OS X 10.9+
* [Docker Machine](https://docs.docker.com/machine/) 0.5.0+

## Install

```sh
curl https://raw.githubusercontent.com/adlogix/docker-machine-nfs/master/docker-machine-nfs.sh |
  sudo tee /usr/local/bin/docker-machine-nfs > /dev/null && \
  sudo chmod +x /usr/local/bin/docker-machine-nfs
```

## Usage

```sh
docker-machine-nfs <machine-name> [--force]
```

## Demo

[![asciicast](https://asciinema.org/a/20224.png)](https://asciinema.org/a/20224)

## Credits

Heavily inspired by @[mattes](https://github.com/mattes) ruby version
[boot2docker-nfs.rb](https://gist.github.com/mattes/4d7f435d759ca2581347).
