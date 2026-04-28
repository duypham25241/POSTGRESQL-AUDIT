-- Tao bang luu tru data giao dich
create table inv044_txn
	( 
	so_chung_tu VARCHAR(50),
	shipment_number VARCHAR(50),
    ma_vat_tu VARCHAR(9),
    ten_vat_tu text,
    so_lo VARCHAR(50),
    ma_kho VARCHAR(3),
    loai_giao_dich VARCHAR(50),
    ngay_chung_tu date,
    so_luong numeric,
    dien_giai text,
    lan_nhap VARCHAR(9)
	)
	
-- Xoa du lieu toan bang
truncate table inv044_txn
-- Kiem tra sau truncate
select * from inv044_txn 

-- Them data 2025 vao bang tam
insert into inv044_txn
	(
	so_chung_tu,
	shipment_number,
	ma_vat_tu,
	ten_vat_tu,
	so_lo,
	ma_kho,
	loai_giao_dich,
	ngay_chung_tu,
	so_luong,
	dien_giai,
	lan_nhap 
	)

-- Them data nam 2025 vao bang tam	
--select count(*) from (	
select
	so_chung_tu,
	shipment_number,
	ma_vat_tu,
	ten_vat_tu,
	so_lo,
	ma_kho,
	loai_giao_dich,
	to_date(ngay_chung_tu,'DD/MM/YYYY'),
	cast(replace(replace(so_luong_1,'.',''),',','.') as numeric) so_luong_1 ,
	dien_giai,
	'Q4.2025' lan_nhap 
from inv044_q4
where ma_kho 
	in (
	'23L','231','23A','23D','23N', -- Cai Cui
	'24L','241','24A','24D','24N', -- Dak Lak
	'38L','38D','38N','38E','011','012','014', -- Binh Duong
	'211','21L','21D','21N','21A', -- Binh Dinh
	'421','422','423','42A','42B','42L','42N', -- Da Nang 
	'44A','44D','44L','44N', -- Nghe An 
	'20L','20A','20N','20D', -- Binh Dinh
	'22L', -- Yen Bai
	'01M','01T','01U' -- Phong Ban Khác
	'45A', '45B' -- Showwroom An Khanh
	)
and 
	(
	loai_giao_dich ilike '%PO Receipt%'
or	loai_giao_dich ilike '%Intransit Shipment%'
or	loai_giao_dich ilike '%Intransit Receipt%'
	)

-- Check lai ket qua sau import
select * from inv044_txn it 

-- Them data vao bang luu tru	
insert into inv044_txn
	(
	so_chung_tu,
	shipment_number,
	ma_vat_tu,
	ten_vat_tu,
	so_lo,
	ma_kho,
	loai_giao_dich,
	ngay_chung_tu,
	so_luong,
	dien_giai,
	lan_nhap 
	)
	
-- Filter data ma kho Home, các loai giao dich PO, Intransit
select
	so_chung_tu,
	shipment_number,
	ma_vat_tu,
	ten_vat_tu,
	so_lo,
	ma_kho,
	loai_giao_dich,
	ngay_chung_tu,
	so_luong_1,
	dien_giai,
	'Q1.2026' lan_nhap 
from inv044
where ma_kho 
	in (
	'23L','231','23A','23D','23N', -- Cai Cui
	'24L','241','24A','24D','24N', -- Dak Lak
	'38L','38D','38N','38E','011','012','014', -- Binh Duong
	'211','21L','21D','21N','21A', -- Binh Dinh
	'421','422','423','42A','42B','42L','42N', -- Da Nang 
	'44A','44D','44L','44N', -- Nghe An 
	'20L','20A','20N','20D', -- Binh Dinh
	'22L', -- Yen Bai
	'01M','01T','01U' -- Phong Ban Khác
	'45A', '45B' -- Showwroom An Khanh
	)
and 
	(
	loai_giao_dich ilike '%PO Receipt%'
or	loai_giao_dich ilike '%Intransit Shipment%'
or	loai_giao_dich ilike '%Intransit Receipt%'
	)
	
	
--Check kq sau khi insert data	
select 
min(ngay_chung_tu),
max(ngay_chung_tu)
from inv044_txn 


-- Check luan chuyen hang hoa giua cac Tong Kho
WITH movement AS (
    select
    	so_chung_tu,
    	shipment_number,
        ten_vat_tu,
        so_lo,
        ma_kho,
        loai_giao_dich,
        ngay_chung_tu,
        sum(so_luong) so_luong_1 
    FROM inv044_txn
    where loai_giao_dich ilike '%intransit%'
    and ngay_chung_tu between '2025-12-01' and '2026-04-22'
	group by     
		so_chung_tu,
    	shipment_number,
        ten_vat_tu,
        so_lo,
        ma_kho,
        loai_giao_dich,
        ngay_chung_tu
),

paired AS (
    SELECT 
        m1.ten_vat_tu as ma_1,
        m1.so_lo as lo_1,
        m1.ma_kho as kho_xuat,
        m1.so_luong_1 as sl_xuat,
        m1.ngay_chung_tu as ngay_xuat,
        m2.ten_vat_tu as ma_2,
        m2.so_lo as lo_2,
        m2.ma_kho as kho_nhap,
        m2.so_luong_1 as sl_nhap,
        m2.ngay_chung_tu as ngay_nhap,
        m1.so_luong_1 + m2.so_luong_1 Chenhlech
    FROM movement m1
    JOIN movement m2
        ON  m1.ten_vat_tu = m2.ten_vat_tu
        AND m1.loai_giao_dich ilike '%Intransit Shipment%'
        AND m2.loai_giao_dich ilike '%Intransit Receipt%'
        AND m2.ngay_chung_tu > m1.ngay_chung_tu
        AND m2.shipment_number = m1.so_chung_tu  -- Ke thua so chung tu
        AND m2.so_lo  = m1.so_lo  -- Dieu kien cung ma lot
        AND m1.ma_kho <> m2.ma_kho   -- Dieu kien phai khac ma kho
),
--	
loop_detect AS (
    SELECT 
        p1.ma_2 ten_vat_tu,
        p1.lo_2 so_lo,
        p1.kho_xuat AS kho_1,
        p1.sl_xuat as SL_kho_1,
        p1.ngay_xuat ngay_1,
        p1.kho_nhap AS kho_nhap,
        p1.sl_nhap  as SL_kho_nhap,
        p1.ngay_nhap as ngay_kho_nhap,
        p2.ma_1 ten_vat_tu_nl,
        p2.lo_1 so_lo_nl,
        p2.kho_nhap AS kho_nl,
        p2.sl_nhap  as SL_kho_nl,
        p2.ngay_nhap ngay_kho_nl
    FROM paired p1
    JOIN paired p2
        ON p1.ma_2 = p2.ma_1 
        AND p1.kho_xuat = p2.kho_nhap
        AND p1.kho_nhap = p2.kho_xuat
        AND p2.ngay_nhap > p1.ngay_xuat
) 
-- Check lai ket qua
select 
	* 
from loop_detect  
order by ten_vat_tu 

----
