-- Tao bang tam Cost_table 
create table Cost_table(
	don_vi varchar(1024),
	nhom_doi_tuong varchar(1024),
	ma_ncc varchar(1024),
	ten_ncc varchar(1024),
	quoc_gia varchar(1024),
	so_chung_tu varchar(1024),
	so_hoa_don varchar(1024),
	ngay_chung_tu date,
	loai_ct varchar(1024),
	dien_giai varchar(1024),
	ty_gia numeric,
	don_vi_tien varchar(1024),
	phat_sinh_no_nguyen_te numeric,
	phat_sinh_co_nguyen_te numeric,
	phat_sinh_no_vnd numeric,
	phat_sinh_co_vnd numeric
)
-- Add data vao bang tam chi phi
insert into Cost_table (	
	don_vi,
	nhom_doi_tuong,
	ma_ncc,
	ten_ncc,
	quoc_gia,
	so_chung_tu,
	so_hoa_don,
	ngay_chung_tu,
	loai_ct,
	dien_giai,
	ty_gia,
	don_vi_tien,
	phat_sinh_no_nguyen_te,
	phat_sinh_co_nguyen_te,
	phat_sinh_no_vnd,
	phat_sinh_co_vnd)

select 
	don_vi,
	nhom_doi_tuong,
	ma_ncc,
	ten_ncc,
	quoc_gia,
	so_chung_tu,
	so_hoa_don,
	ngay_chung_tu,
	loai_ct,
	dien_giai,
	ty_gia,
	don_vi_tien,
	phat_sinh_no_nguyen_te,
	phat_sinh_co_nguyen_te,
	phat_sinh_no_vnd,
	phat_sinh_co_vnd
from AP004 
	
	
-- Data Cost_table 
select 
	* 
from
(	select 
		ma_ncc,
		trim(ten_ncc) ten_ncc,
		loai_ct,
		ty_gia,
		don_vi_tien,
		phat_sinh_co_nguyen_te,
		phat_sinh_no_nguyen_te,
		case 
			when ma_ncc in (select ma_dvvc from data_đvvc) then 'Vanchuyen'
			when ma_ncc in (select replace(ma_ncc,'.0','') from ncc_xlsx) then 'SPTM'
			when trim(ten_ncc) not ilike '%công ty%' then 'Ca nhan'
			when trim(ten_ncc) ilike '%hoa sen%' then 'Hoa Sen'
			else null
		end as Loaigd
	from cost_table ct )
where Loaigd is null
group by ten_ncc 

--------------------------------------------------------------------------------------------------
-- Check do dai ky tu trong ID NCC (7 so)
select 
	ma_ncc 
from ncc
where length(ma_ncc) <> 7 and ma_ncc <> 'Chưa tìm ra'

-- Check data loi co ky tu trong ID NCC	
select 
	ma_ncc::int
from 
	ncc
where ten_ncc not ilike 'Chưa tìm ra'

-- Check duplicate trong bang 
select 
	mat_hang,
	ma_ncc,
	ten_ncc,
	ten_viet_tat,
	htht,
	thuong_hieu,
	count(*)
from ncc
group by mat_hang, ma_ncc, ten_ncc, ten_viet_tat, htht, thuong_hieu
having count(*) > 1

-- Doi chieu giua bang data moi va cu
select 
	*
from ncc_xlsx a
where not exists
	(select 
		1 
	from ncc b
	where a.ma_ncc = b.ma_ncc 
	)

-- Them bang data NCC moi tam vao truoc, update lai bang goc
-- Cap nhat data data moi
-- Update ma_NCC moi bang data moi 
update ncc a
	set ma_ncc = b.ma_ncc 
from ncc_xlsx b
where a.ten_viet_tat = b.ten_viet_tat  
	and a.ma_ncc like '%0.0%'

-- Update data loi ky tu
update ncc a
	set ma_ncc = replace(trim(b.ma_ncc),'.0','')
from ncc_xlsx b
where a.ten_viet_tat = b.ten_viet_tat  

-- Check lai sau update
select 
	ma_ncc::int
from ncc
where ten_ncc not ilike 'Chưa tìm ra'
