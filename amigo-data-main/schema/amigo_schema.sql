-- AMIGO schema - dijalankan berurutan sesuai traceability (1-12)
CREATE DATABASE IF NOT EXISTS amigo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE amigo;

-- 1. AKUN (entitas Akun) (MHS)
CREATE TABLE AKUN (
  id_akun VARCHAR(10) NOT NULL PRIMARY KEY,
  email_ub VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  nama_pengguna VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. OTP (entitas OTP) (NKP)
CREATE TABLE OTP (
  id_otp VARCHAR(10) NOT NULL PRIMARY KEY,
  id_akun VARCHAR(10) NOT NULL,
  kode_otp CHAR(6) NOT NULL,
  waktu_dibuat DATETIME NOT NULL,
  waktu_kedaluwarsa DATETIME NOT NULL,
  status_otp ENUM('aktif', 'terpakai', 'kedaluwarsa') NOT NULL DEFAULT 'aktif',
  CONSTRAINT fk_otp_akun FOREIGN KEY (id_akun) REFERENCES AKUN(id_akun)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. SESILOGIN (entitas SesiLogin) (DRT)
CREATE TABLE SESILOGIN (
  id_sesi VARCHAR(10) NOT NULL PRIMARY KEY,
  id_akun VARCHAR(10) NOT NULL,
  token_sesi VARCHAR(255) NOT NULL UNIQUE,
  role_aktif ENUM('seller', 'buyer') NULL,
  waktu_login DATETIME NOT NULL,
  status_sesi ENUM('aktif', 'berakhir') NOT NULL DEFAULT 'aktif',
  CONSTRAINT fk_sesilogin_akun FOREIGN KEY (id_akun) REFERENCES AKUN(id_akun)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. KATEGORI (entitas Kategori) (DRT)
CREATE TABLE KATEGORI (
  id_kategori VARCHAR(10) NOT NULL PRIMARY KEY,
  id_induk VARCHAR(10) NULL,
  nama_kategori VARCHAR(50) NOT NULL,
  CONSTRAINT fk_kategori_induk FOREIGN KEY (id_induk) REFERENCES KATEGORI(id_kategori)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. POSTINGAN (entitas Postingan) (FHY)
CREATE TABLE POSTINGAN (
  id_postingan VARCHAR(10) NOT NULL PRIMARY KEY,
  id_akun VARCHAR(10) NOT NULL,
  id_kategori VARCHAR(10) NOT NULL,
  id_subkategori VARCHAR(10) NOT NULL,
  jenis_postingan ENUM('tawaran', 'request') NOT NULL,
  judul VARCHAR(100) NOT NULL,
  deskripsi TEXT NOT NULL,
  harga INT NOT NULL CHECK (harga >= 0),
  fakultas VARCHAR(50) NOT NULL,
  foto_produk VARCHAR(255) NOT NULL,
  lokasi VARCHAR(100) NOT NULL,
  status_postingan ENUM('aktif', 'terjual', 'dihapus') NOT NULL DEFAULT 'aktif',
  waktu_dibuat DATETIME NOT NULL,
  CONSTRAINT fk_postingan_akun FOREIGN KEY (id_akun) REFERENCES AKUN(id_akun),
  CONSTRAINT fk_postingan_kategori FOREIGN KEY (id_kategori) REFERENCES KATEGORI(id_kategori),
  CONSTRAINT fk_postingan_subkategori FOREIGN KEY (id_subkategori) REFERENCES KATEGORI(id_kategori)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. BOOKMARK (entitas Bookmark) (MHS)
CREATE TABLE BOOKMARK (
  id_bookmark VARCHAR(10) NOT NULL PRIMARY KEY,
  id_akun VARCHAR(10) NOT NULL,
  id_postingan VARCHAR(10) NOT NULL,
  kategori ENUM('jastip', 'preloved') NOT NULL,
  waktu_disimpan DATETIME NOT NULL,
  CONSTRAINT fk_bookmark_akun FOREIGN KEY (id_akun) REFERENCES AKUN(id_akun),
  CONSTRAINT fk_bookmark_postingan FOREIGN KEY (id_postingan) REFERENCES POSTINGAN(id_postingan)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. RUANGCHAT (entitas RuangChat) (FHY)
CREATE TABLE RUANGCHAT (
  id_ruang_chat VARCHAR(10) NOT NULL PRIMARY KEY,
  id_buyer VARCHAR(10) NOT NULL,
  id_seller VARCHAR(10) NOT NULL,
  id_postingan VARCHAR(10) NOT NULL,
  waktu_dibuat DATETIME NOT NULL,
  CONSTRAINT fk_ruangchat_buyer FOREIGN KEY (id_buyer) REFERENCES AKUN(id_akun),
  CONSTRAINT fk_ruangchat_seller FOREIGN KEY (id_seller) REFERENCES AKUN(id_akun),
  CONSTRAINT fk_ruangchat_postingan FOREIGN KEY (id_postingan) REFERENCES POSTINGAN(id_postingan)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. PESANCHAT (entitas PesanChat) (FHY)
CREATE TABLE PESANCHAT (
  id_pesan VARCHAR(10) NOT NULL PRIMARY KEY,
  id_ruang_chat VARCHAR(10) NOT NULL,
  id_pengirim VARCHAR(10) NOT NULL,
  isi_pesan TEXT NOT NULL,
  waktu_kirim DATETIME NOT NULL,
  status_pesan ENUM('terkirim', 'dibaca') NOT NULL DEFAULT 'terkirim',
  CONSTRAINT fk_pesanchat_ruang_chat FOREIGN KEY (id_ruang_chat) REFERENCES RUANGCHAT(id_ruang_chat),
  CONSTRAINT fk_pesanchat_pengirim FOREIGN KEY (id_pengirim) REFERENCES AKUN(id_akun)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. ORDER (entitas Order) (DRT)
CREATE TABLE `ORDER` (
  id_order VARCHAR(10) NOT NULL PRIMARY KEY,
  id_akun_buyer VARCHAR(10) NOT NULL,
  id_postingan VARCHAR(10) NOT NULL,
  jumlah INT NOT NULL CHECK (jumlah >= 1),
  catatan TEXT NULL,
  lokasi_antar VARCHAR(100) NOT NULL,
  harga_item INT NOT NULL,
  biaya_layanan INT NOT NULL,
  total_harga INT NOT NULL,
  status_order ENUM('menunggu_pembayaran', 'diproses', 'diserahkan_ke_kurir', 'transit', 'sedang_dikirim', 'selesai') NOT NULL DEFAULT 'menunggu_pembayaran',
  waktu_dibuat DATETIME NOT NULL,
  CONSTRAINT fk_order_akun_buyer FOREIGN KEY (id_akun_buyer) REFERENCES AKUN(id_akun),
  CONSTRAINT fk_order_postingan FOREIGN KEY (id_postingan) REFERENCES POSTINGAN(id_postingan)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10. PEMBAYARAN (entitas Pembayaran) (MHS)
CREATE TABLE PEMBAYARAN (
  id_pembayaran VARCHAR(10) NOT NULL PRIMARY KEY,
  id_order VARCHAR(10) NOT NULL,
  kode_qris VARCHAR(255) NOT NULL,
  total_bayar INT NOT NULL,
  status_pembayaran ENUM('menunggu', 'berhasil', 'gagal', 'kedaluwarsa') NOT NULL DEFAULT 'menunggu',
  waktu_bayar DATETIME NULL,
  CONSTRAINT fk_pembayaran_order FOREIGN KEY (id_order) REFERENCES `ORDER`(id_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11. PROFILSELLER (entitas ProfilSeller) (NKP)
CREATE TABLE PROFILSELLER (
  id_seller VARCHAR(10) NOT NULL PRIMARY KEY,
  nama_seller VARCHAR(100) NOT NULL,
  rata_rata_rating DECIMAL(2,1) NOT NULL DEFAULT 0.0,
  jumlah_ulasan INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_profilseller_seller FOREIGN KEY (id_seller) REFERENCES AKUN(id_akun)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 12. ULASAN (entitas Ulasan) (NKP)
CREATE TABLE ULASAN (
  id_ulasan VARCHAR(10) NOT NULL PRIMARY KEY,
  id_order VARCHAR(10) NOT NULL UNIQUE,
  id_seller VARCHAR(10) NOT NULL,
  id_buyer VARCHAR(10) NOT NULL,
  rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  teks_ulasan TEXT NOT NULL,
  waktu_ulasan DATETIME NOT NULL,
  CONSTRAINT fk_ulasan_order FOREIGN KEY (id_order) REFERENCES `ORDER`(id_order),
  CONSTRAINT fk_ulasan_seller FOREIGN KEY (id_seller) REFERENCES PROFILSELLER(id_seller),
  CONSTRAINT fk_ulasan_buyer FOREIGN KEY (id_buyer) REFERENCES AKUN(id_akun)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
