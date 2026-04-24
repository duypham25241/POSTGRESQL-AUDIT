WITH movement AS (
    select
    	so_chung_tu,
    	shipment_number,
        ma_vat_tu,
        so_lo,
        ma_kho,
        loai_giao_dich,
        TO_DATE(REPLACE(ngay_chung_tu , ' ICT', ''),'Dy Mon DD HH24:MI:SS YYYY') ngay_chung_tu,
        sum(so_luong_1) so_luong_1 
    FROM "inv044_m3"
    where ma_kho ilike '%L%'
	and loai_giao_dich ilike '%intransit%'
	group by     
		so_chung_tu,
    	shipment_number,
        ma_vat_tu,
        so_lo,
        ma_kho,
        loai_giao_dich,
        ngay_chung_tu
),

paired AS (
    SELECT 
        m1.ma_vat_tu as ma_1,
        m1.so_lo as lo_1,
        m1.ma_kho as kho_xuat,
        m1.so_luong_1 as sl_xuat,
        m1.ngay_chung_tu as ngay_xuat,
        m2.ma_vat_tu as ma_2,
        m2.so_lo as lo_2,
        m2.ma_kho as kho_nhap,
        m2.so_luong_1 as sl_nhap,
        m2.ngay_chung_tu as ngay_nhap,
        m1.so_luong_1 + m2.so_luong_1 Chenhlech
    FROM movement m1
    JOIN movement m2
        ON  m1.ma_vat_tu = m2.ma_vat_tu
        AND m1.loai_giao_dich ilike '%Intransit Shipment%'
        AND m2.loai_giao_dich ilike '%Intransit Receipt%'
        AND m2.ngay_chung_tu > m1.ngay_chung_tu
        AND m2.shipment_number = m1.so_chung_tu  -- Ke thua so chung tu
        AND m2.so_lo  = m1.so_lo  -- Dieu kien cung ma lot
        AND m1.ma_kho <> m2.ma_kho   -- Dieu kien phai khac ma kho
),-- select * from paired,
loop_detect AS (
    SELECT 
        p1.ma_2 ma_vat_tu,
        p1.lo_2 so_lo,
        p1.kho_xuat AS kho_1,
        p1.sl_xuat as SL_kho_1,
        p1.ngay_xuat ngay_1,
        p1.kho_nhap AS kho_nhap,
        p1.sl_nhap  as SL_kho_nhap,
        p1.ngay_nhap as ngay_kho_nhap,
        p2.ma_1 ma_vat_tu_nl,
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
select 
	* 
from loop_detect  
order by ma_vat_tu 

----
