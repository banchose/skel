# Condensed systemd-networkd reference
---

**systemd-networkd condensed reference**

Daemon managing network config; detects/configures physical devices, creates virtual devices. Part of default Arch systemd install.

**Services:** Enable `systemd-networkd.service`. Only one DHCP client/network manager per interface. `systemd-networkd-wait-online.service` auto-enabled (waits all managed links configured/failed, ≥1 online). Override with `--any` for any-interface, or use `systemd-networkd-wait-online@<iface>.service` for specific. `RequiredForOnline=no` in [Link] excludes interface from wait. `RequiredForOnline=routable` waits for routable address. `--dns` flag waits for DNS reachability.

**systemd-resolved interaction:** Required if DNS specified in .network files or obtained via DHCP/RA (UseDNS=yes default in [DHCPv4]/[DHCPv6]/[IPv6AcceptRA]).

**Config files:** Priority order: `/etc/systemd/network/` > `/run/systemd/network/` > `/usr/lib/systemd/network/`. Three types: `.network` (apply config to matching device), `.netdev` (create virtual device), `.link` (udev matches on device appearance). All sorted/processed lexically across dirs. Identical names replace. Case-sensitive options. Mask system files via symlink to `/dev/null`. Global overrides in `/etc/systemd/networkd.conf`.

**Match section:** Empty = wildcard. `Name=en*` glob supported. `Type=ether|wlan|wwan`. `Type=ether` matches virtual too; exclude with `Kind=!*`. Match by `SSID=`/`BSSID=` for wifi location-based config.

**Quick start:** Symlink `/usr/lib/systemd/network/80-wifi-station.network.example` and `89-ethernet.network.example` to `/etc/systemd/network/`.

**networkctl:** Query/modify link status. `networkctl edit @wlan0 --drop-in <name>` for per-interface overrides.

**Wired DHCP:** [Match] Name=enp1s0 / [Link] RequiredForOnline=routable / [Network] DHCP=yes

**Wired static:** [Network] Address=10.1.10.9/24 (repeatable), Gateway=10.1.10.1, DNS=10.1.10.1. Supports multiple Address= for dual-stack.

**Wireless:** Requires external auth (wpa_supplicant/iwd). Same .network structure. `IgnoreCarrierLoss=3s` reduces downtime during AP roaming within same SSID.

**Dual wired+wireless (failover):** Set different RouteMetric in [DHCPv4] and [IPv6AcceptRA]. Lower = preferred. Example: wired=100, wireless=600. `Metric` for static routes, `RouteMetric` for DHCP/RA routes.

**DHCP server:** [Network] Address=10.1.1.1/24, DHCPServer=true, IPMasquerade=ipv4 (adds NAT rules, implies IPv4Forwarding=yes; note: filter table rules may need manual addition). [DHCPServer] PoolOffset=, PoolSize=, DNS=.

**Secondary route:** [Route] Destination=10.10.0.0/16, Gateway=10.1.0.5.

**Network bridge:** Create .netdev Kind=bridge → bind interfaces via [Network] Bridge=br0 in their .network (no IP on bound interfaces) → configure bridge .network with DHCP/static. `MACAddress=none` in .netdev + `MACAddressPolicy=none` in .link for MAC inheritance. Container: `--network-bridge=br0`. Container gets host0 interface auto-configured via system 80-container-host0.network (override in /etc for static).

**MACVLAN bridge:** Host's physical iface gets [Network] MACVLAN=mv-0, no IP (DHCP=no, IPv6AcceptRA=false, LinkLocalAddressing=no), RequiredForOnline=carrier. Create .netdev Kind=macvlan Mode=bridge. Host connects via MACVLAN interface. Container: MACVLAN=enp1s0 in .nspawn or `--network-macvlan=`. Container interface named mv-<underlying>.

**Bonding:** .netdev Kind=bond, Mode=active-backup, PrimarySlave=true on wired, secondary on wireless. Bond .network: BindCarrier=enp0s25 wlan0, DHCP=yes. Use PermanentMACAddress over MACAddress in [Match].

**TCP slow-start tuning:** [Route] Gateway=_dhcp4, InitialCongestionWindow=N, InitialAdvertisedReceiveWindow=N (default 10, multiply of MSS 1460B). 30 good for 100Mbit, 100 excessive. Related sysctls: net.ipv4.tcp_slow_start_after_idle, net.ipv4.tcp_congestion_control.

**Prevent multiple default routes:** Assign different RouteMetric per device, or UseGateway=false in [DHCPv4]/[IPv6AcceptRA] to suppress default route from specific interface.

**Second static IP with own MAC (MACVLAN on self):** .netdev Kind=macvlan MACAddress=xx, Mode=bridge. .network with static IP, [Route] Metric=2 so main interface preferred. Add MACVLAN=<name> to main interface's .network [Network]. Use arping to announce new MAC.

**SSID-based config:** Lower-numbered file with SSID match for specific network (e.g., static office), higher-numbered wildcard for DHCP fallback.

**ManageForeignRoutingPolicyRules=** in networkd.conf controls whether networkd modifies routing tables for other software.
