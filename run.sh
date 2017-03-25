#!/bin/zsh

dns=8.8.8.8

die() {
  echo $*
  exit 1
}

[ $# -eq 0 ] && die must provide ovpn file
tmpdir=$(mktemp -d)

finish() {
  [ -d $tmpdir ] && rm -r $tmpdir
}
trap finish EXIT TERM

cp $1 $tmpdir/cfg.ovpn || die could not copy ovpn config to $tmpdir

# sudo iptables -P FORWARD ACCEPT
sudo rkt run \
  --insecure-options=image,paths,capabilities \
  --dns=$dns --net=default --interactive \
  --volume vpnconfig,kind=host,source=$tmpdir \
  --mount volume=vpnconfig,target=/var/vpn-config \
  ./*.aci
