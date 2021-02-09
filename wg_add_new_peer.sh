#!/bin/bash

wg set wg0 peer $1 allowed-ips $2
PUBLICKEY=$(cat /etc/wireguard/wireguard.pub)
echo "Added peer $2. The public key of the server is $PUBLICKEY"
echo "On the client, make sure to set DNS to the following: 10.0.0.1"
echo "On the client, make sure to set AllowedIPs to the following: 0.0.0.0/0, ::/0"
