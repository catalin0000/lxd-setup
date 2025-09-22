# Auto LXD setup

Make sure you have lxd installed already as usualle there are some dependencies conflicts. (iptables and iptables-nft)
I may automate that in future... maybe? 


## How to

`git clone https://github.com/catalin0000/lxd-setup`

```
cd lxd-setu
bash lxd-setup.sh
```

## What will happen:

For `lxd-setup.sh`

- enable lxd service
- map container root user to uid and gid 1000000
- lxd init from the preseed file
- install lvm2
- create a lvm thin pool and mount it on loop device
- create service `loop-lxd-thin` and enable it to remount the lvm on boot
- add the thin pool to lxd, remove the default created by the preseed and make lvm pool default
- create `x11-profile` to be able to access x11 from container (basically mounting /tmp/.X11-unix/X0 inside the container and defining variables for DISPLAY and XAUTHORITY)
- pull a kali and create `kali-golden` container
- stop the `kali-golden` container and 'publish' it as in creating an image from it
- copies the `container` script into `/usr/local/bin/container`

For `container`

- this is the way to handle your containers easily.

simple `container help` and it should give you a good idea of what's doing.

