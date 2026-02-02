-- 1
SELECT DISTINCT NH.TenNH
FROM NganHang NH
JOIN ChiNhanh CN ON NH.MaNH = CN.MaNH
WHERE CN.ThanhPhoCN = 'Da Lat';

-- 2
SELECT DISTINCT CN.ThanhPhoCN
FROM ChiNhanh CN
JOIN NganHang NH ON CN.MaNH = NH.MaNH
WHERE NH.TenNH = 'Ngan Hang Cong Thuong';

-- 3
SELECT CN.*
FROM ChiNhanh CN
JOIN NganHang NH ON CN.MaNH = NH.MaNH
WHERE NH.TenNH = 'Ngan Hang Cong Thuong' AND CN.ThanhPhoCN = 'TP HCM';

-- 4
SELECT NH.TenNH, CN.MaCN, CN.ThanhPhoCN, CN.TaiSan
FROM NganHang NH
JOIN ChiNhanh CN ON NH.MaNH = CN.MaNH
ORDER BY NH.TenNH;

-- 5
SELECT * FROM KhachHang WHERE DiaChi LIKE '%Ha Noi%';

-- 6
SELECT * FROM KhachHang WHERE TenKH LIKE '%Son';

-- 7
SELECT * FROM KhachHang WHERE DiaChi LIKE '%Tran Hung Dao%';

-- 8
SELECT * FROM KhachHang WHERE TenKH LIKE '% Thao'; 

-- 9
SELECT * FROM KhachHang 
WHERE MaKH LIKE '11%' AND DiaChi LIKE '%TP HCM%';

-- 10
SELECT NH.TenNH, CN.ThanhPhoCN, CN.TaiSan
FROM ChiNhanh CN
JOIN NganHang NH ON CN.MaNH = NH.MaNH
ORDER BY CN.TaiSan ASC, CN.ThanhPhoCN ASC;

-- 11
SELECT NH.TenNH, CN.*
FROM ChiNhanh CN
JOIN NganHang NH ON CN.MaNH = NH.MaNH
WHERE CN.TaiSan > 3000000000 AND CN.TaiSan < 5000000000;

-- 12
SELECT NH.TenNH, AVG(CN.TaiSan) AS TaiSanTrungBinh
FROM NganHang NH
JOIN ChiNhanh CN ON NH.MaNH = CN.MaNH
GROUP BY NH.TenNH;

-- 13
SELECT DISTINCT KH.*
FROM KhachHang KH
JOIN TaiKhoanVay TKV ON KH.MaKH = TKV.MaKH
JOIN ChiNhanh CN ON TKV.MaCN = CN.MaCN
JOIN NganHang NH ON CN.MaNH = NH.MaNH
WHERE NH.TenNH = 'Ngan Hang Cong Thuong' AND KH.TenKH LIKE '% Thao';

-- 14
SELECT NH.TenNH, SUM(CN.TaiSan) AS TongTaiSan
FROM NganHang NH
JOIN ChiNhanh CN ON NH.MaNH = CN.MaNH
GROUP BY NH.TenNH;

-- 15
SELECT MaCN, TaiSan
FROM ChiNhanh
WHERE TaiSan = (SELECT MAX(TaiSan) FROM ChiNhanh);

-- 16
SELECT DISTINCT KH.*
FROM KhachHang KH
JOIN TaiKhoanGoi TKG ON KH.MaKH = TKG.MaKH
JOIN ChiNhanh CN ON TKG.MaCN = CN.MaCN
JOIN NganHang NH ON CN.MaNH = NH.MaNH
WHERE NH.TenNH = 'Ngan Hang A Chau';

-- 17
SELECT TKV.SoTKV, TKV.SoTienVay
FROM TaiKhoanVay TKV
JOIN ChiNhanh CN ON TKV.MaCN = CN.MaCN
JOIN NganHang NH ON CN.MaNH = NH.MaNH
WHERE NH.TenNH = 'Ngan Hang Ngoai Thuong' AND TKV.SoTienVay > 1200000;

-- 18
SELECT CN.MaCN, CN.ThanhPhoCN, SUM(TKG.SoTienGoi) AS TongTienGui
FROM ChiNhanh CN
LEFT JOIN TaiKhoanGoi TKG ON CN.MaCN = TKG.MaCN
GROUP BY CN.MaCN, CN.ThanhPhoCN;

-- 19
SELECT KH.TenKH, N'Vay' AS LoaiTaiKhoan, TKV.SoTKV AS SoTaiKhoan, TKV.SoTienVay AS SoTien, CN.ThanhPhoCN
FROM KhachHang KH
JOIN TaiKhoanVay TKV ON KH.MaKH = TKV.MaKH
JOIN ChiNhanh CN ON TKV.MaCN = CN.MaCN
WHERE KH.TenKH LIKE '% Son'
UNION ALL
SELECT KH.TenKH, N'Gửi' AS LoaiTaiKhoan, TKG.SoTKG AS SoTaiKhoan, TKG.SoTienGoi AS SoTien, CN.ThanhPhoCN
FROM KhachHang KH
JOIN TaiKhoanGoi TKG ON KH.MaKH = TKG.MaKH
JOIN ChiNhanh CN ON TKG.MaCN = CN.MaCN
WHERE KH.TenKH LIKE '% Son';

-- 20
SELECT KH.MaKH, KH.TenKH, SUM(TKV.SoTienVay) AS TongTienVay
FROM KhachHang KH
JOIN TaiKhoanVay TKV ON KH.MaKH = TKV.MaKH
GROUP BY KH.MaKH, KH.TenKH
HAVING SUM(TKV.SoTienVay) > 30000000;