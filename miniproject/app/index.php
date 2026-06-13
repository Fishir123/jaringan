<?php
require __DIR__ . '/dbconfig.php';
header('Content-Type: text/html; charset=utf-8');

// Koneksi ke MariaDB di VM lain (10.20.2.11) - sesuai contoh: new mysqli(host,user,pass,db)
$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
if ($conn->connect_errno) {
    http_response_code(500);
    die('Koneksi DB gagal: ' . htmlspecialchars($conn->connect_error));
}

// Tambah data lewat form (prepared statement - aman dari SQL injection)
$msg = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['name'])) {
    $stmt = $conn->prepare('INSERT INTO visitors (name, note) VALUES (?, ?)');
    $stmt->bind_param('ss', $_POST['name'], $_POST['note']);
    $stmt->execute();
    $stmt->close();
    $msg = 'Data tersimpan ke DB remote.';
}

$server_ip = $_SERVER['SERVER_ADDR'] ?? 'web';
?>
<!DOCTYPE html>
<html lang="id"><head><meta charset="utf-8"><title>Mini Project - Web + DB Remote</title>
<style>body{font-family:sans-serif;max-width:680px;margin:30px auto}table{border-collapse:collapse;width:100%}td,th{border:1px solid #ccc;padding:6px}th{background:#2c5aa0;color:#fff}.box{background:#eef;padding:10px;border-radius:6px}</style>
</head><body>
<h1>Mini Project - Buku Tamu</h1>
<div class="box">
  <b>Web Server (VM1):</b> <?= htmlspecialchars($server_ip) ?> (cli01)<br>
  <b>Database Server (VM2):</b> <?= DB_HOST ?> (adm01) - MariaDB<br>
  <b>Status koneksi DB:</b> <?= $conn->connect_errno ? 'GAGAL' : 'TERHUBUNG (host info: ' . htmlspecialchars($conn->host_info) . ')' ?>
</div>
<?php if ($msg): ?><p style="color:green"><?= $msg ?></p><?php endif; ?>
<h2>Tambah Tamu</h2>
<form method="post">
  Nama: <input name="name" required>
  Catatan: <input name="note">
  <button type="submit">Simpan</button>
</form>
<h2>Daftar Tamu (dari DB remote)</h2>
<table><tr><th>ID</th><th>Nama</th><th>Catatan</th><th>Waktu</th></tr>
<?php
$res = $conn->query('SELECT id, name, note, created_at FROM visitors ORDER BY id DESC');
while ($row = $res->fetch_assoc()) {
    printf('<tr><td>%d</td><td>%s</td><td>%s</td><td>%s</td></tr>',
        $row['id'],
        htmlspecialchars($row['name']),
        htmlspecialchars($row['note'] ?? ''),
        htmlspecialchars($row['created_at']));
}
$conn->close();
?>
</table>
</body></html>
