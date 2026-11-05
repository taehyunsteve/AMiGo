# amigo-data

Lapisan data (MySQL) untuk AMIGO — Kelompok 4, Rekayasa Sistem Informasi.

## Isi
- `schema/amigo_schema.sql` — DDL 12 tabel (AKUN, OTP, SESILOGIN, KATEGORI, POSTINGAN, BOOKMARK, RUANGCHAT, PESANCHAT, ORDER, PEMBAYARAN, PROFILSELLER, ULASAN) dengan 20 foreign key.

## Cara menjalankan
1. Jalankan MySQL 8 (atau XAMPP/MariaDB).
2. Buka `schema/amigo_schema.sql` di DBeaver atau MySQL Workbench, lalu jalankan seluruh script.
3. Hasilnya: database `amigo` dengan 12 tabel.

Catatan: tabel `ORDER` memakai backtick karena ORDER adalah kata kunci SQL.
