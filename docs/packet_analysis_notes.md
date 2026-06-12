# Packet Analysis Notes (Modul 4)

Berdasarkan capture tcpdump di srv01 (router).

## 1. Apa itu ARP?
Address Resolution Protocol — memetakan alamat IP (layer-3) ke alamat MAC
(layer-2) dalam satu segmen jaringan lokal. Sebelum host mengirim frame ke IP
tujuan di subnet yang sama, ia bertanya via ARP "siapa punya IP X?" dan menerima
balasan berisi MAC. Berlaku hanya dalam broadcast domain (subnet) yang sama.

## 2. Bedanya ICMP vs TCP?
- **ICMP**: protokol kontrol/diagnostik (mis. ping = echo request/reply). Tidak
  membuka koneksi, tidak ada handshake, tidak menjamin urutan. Dipakai untuk
  cek reachability & pesan error (mis. destination unreachable, TTL exceeded).
- **TCP**: protokol transport berorientasi koneksi. Ada handshake (SYN/SYN-ACK/
  ACK), pengurutan, retransmisi, dan flow control. Dipakai layanan seperti SSH/HTTP.

## 3. Apa fungsi SYN?
SYN (synchronize) adalah paket pertama TCP handshake: client mengirim SYN dengan
initial sequence number untuk meminta membuka koneksi dan menyinkronkan nomor
urut. Server membalas SYN-ACK (SYN miliknya + ACK atas SYN client), lalu client
mengirim ACK → koneksi terbentuk (three-way handshake).

Bukti dari capture (adm01 → cli01:22):
```
Flags [S]   = SYN      (10.10.2.10 -> 10.20.2.2)
Flags [S.]  = SYN-ACK  (10.20.2.2  -> 10.10.2.10)
Flags [.]   = ACK      (10.10.2.10 -> 10.20.2.2)
```

## 4. Kenapa ping bisa gagal tapi SSH jalan (atau sebaliknya)?
Karena ICMP dan TCP diperlakukan terpisah. Contoh penyebab:
- Firewall memblok ICMP tapi mengizinkan TCP/22 → ping gagal, SSH jalan.
- Sebaliknya, routing/gateway salah memengaruhi keduanya.
- Maka "ping gagal" tidak otomatis berarti host mati — perlu cek per-protokol.

## 5. Apa arti TTL?
Time To Live — penghitung hop pada header IP. Tiap router yang meneruskan paket
mengurangi TTL 1; jika TTL=0 paket dibuang (cegah loop tak berujung). 
Pada lab: reply dari cli01 ke adm01 ber-TTL 63 (mulai 64, lewat 1 router srv01),
membuktikan paket melalui 1 hop.

Evidence: `evidence/tcpdump_icmp.txt`, `evidence/tcpdump_ssh.txt`.
