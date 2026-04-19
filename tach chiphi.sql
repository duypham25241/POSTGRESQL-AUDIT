-- Tao bang tam chi phi
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
