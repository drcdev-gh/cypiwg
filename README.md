# cypiwg

This simple `setup.sh` script installs wireguard and pihole and makes the DNS provided by pihole only accessible via the wireguard tunnel.
Note that the script also sets up a ufw firewall - don't run this script if you aren't on a clean machine.

After the script is run, you'll need to to add a new peer with the `wg_add_new_peer.sh` script. It will tell you what to configure on the client:

```
wg_add_new_peer.sh <client public key> <client ip>
```

You can check the connection by:
- Connecting via wireguard
- Checking that web-browsing etc. works as normal

Then:
- Disconnect from wireguard
- Configure the machine with wireguard/pihole installation as "normal DNS"
- Make sure that DNS resolution doesn't work

This has been tested on a DigitalOcean Fedora 33 droplet.