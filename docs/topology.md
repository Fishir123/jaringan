# Topology

Kelompok X=2 · LAN 10.10.2.0/24 · domain draft lab2.local

## Diagram logis

```
                 Internet
                    |
                  [NAT]            <- VirtualBox NAT (enp0s3, DHCP 10.0.2.15)
        ____________|____________
       |            |            |
   enp0s3       enp0s3       enp0s3
  +--------+   +--------+   +--------+
  | adm01  |   | srv01  |   | cli01  |
  | admin  |   | server |   | client |
  +--------+   +--------+   +--------+
   enp0s8       enp0s8       enp0s8
 10.10.2.10   10.10.2.11   10.10.2.12
       |____________|____________|
                    |
        Host-only LAN  vboxnet0  10.10.2.0/24
                 (host: 10.10.2.1)
```

## Adapter per VM (VirtualBox)
- Adapter 1 = NAT  → guest enp0s3 (DHCP, untuk apt/internet)
- Adapter 2 = Host-only (vboxnet0) → guest enp0s8 (IP statik LAN)

## IP Plan
| Host  | LAN IP        | Mask          |
|-------|---------------|---------------|
| host  | 10.10.2.1     | 255.255.255.0 |
| adm01 | 10.10.2.10    | 255.255.255.0 |
| srv01 | 10.10.2.11    | 255.255.255.0 |
| cli01 | 10.10.2.12    | 255.255.255.0 |

Gateway LAN: kosong (routing dibahas modul berikutnya).
DNS internal: rencana di srv01 (modul berikutnya).

## Akses admin
adm01 --(SSH ed25519, key-only)--> srv01, cli01
