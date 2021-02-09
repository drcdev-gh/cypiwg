#!/bin/bash

print_seperator()
{
    echo "---------------------------------------"
}

print_info()
{
    echo "** INFO: $@"
}

update()
{
    print_seperator
    print_info "Starting update process"

    dnf update -y
    dnf install -y curl iproute

    print_info "Done with update process"
    print_seperator
}

install_wireguard()
{
    dnf install -y kernel-headers kernel-devel kmod dkms iptables
    dnf install -y wireguard-tools

    sysctl -w net.ipv4.ip_forward=1
    sysctl -p

    wg genkey | tee /etc/wireguard/wireguard.key | wg pubkey > /etc/wireguard/wireguard.pub
    cp configs/wg0.conf /etc/wireguard/wg0.conf
    PRIVATEKEY=$(cat /etc/wireguard/wireguard.key)
    echo "PrivateKey = $PRIVATEKEY" >> /etc/wireguard/wg0.conf

    chmod 600 /etc/wireguard/wireguard.key
    chmod 600 /etc/wireguard/wg0.conf

    modprobe wireguard
    wg-quick up wg0

    systemctl enable wg-quick@wg0
}

install_pihole()
{
    print_seperator
    print_info "Starting pihole installation process"
    print_info "Stopping resolved"

    systemctl stop systemd-resolved
    systemctl disable systemd-resolved.service

    if [ ! -f /etc/sysconfig/network-scripts/ifcfg-wg0 ]
    then
        touch /etc/sysconfig/network-scripts/ifcfg-wg0
    fi

    print_info "Downloading and running pihole installation script"
    print_info "IMPORTANT: Choose wg0 as interface and set the static IP to 10.0.0.1"
    curl -sSL https://install.pi-hole.net | PIHOLE_SELINUX=true PIHOLE_SKIP_OS_CHECK=true sudo -E bash
    print_seperator
}

setup_firewall()
{
    print_seperator
    print_info "Installing and setting up ufw"

    dnf install -y ufw
    sleep 1

    ufw default deny incoming
    ufw default allow outgoing

    ufw allow from 10.0.0.0/24 to any port 53
    ufw allow 51825
    ufw allow ssh

    systemctl enable ufw
    print_seperator
}

restart_wireguard()
{
    print_seperator
    print_info "Restarting wg"

    wg-quick down wg0
    sleep 1
    wg-quick up wg0
}

update
install_wireguard
install_pihole
setup_firewall
restart_wireguard

print_info "DONE"