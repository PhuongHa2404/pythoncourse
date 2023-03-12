alter PROCEDURE SP_CapNhatGiangVien
(
	@MaGiangVien  NVARCHAR(20),
	@HoDem  NVARCHAR(50),
	@Ten  NVARCHAR(20),
	@GioiTinh BIT,
	@NgaySinh VARCHAR(10),
	@HocVi NVARCHAR(50),
	@IDKhoa INT,
	@CCCD VARCHAR(20),
	@SoDienThoai VARCHAR(20),
	@DiaChiLienLac NVARCHAR(200),
	@IsChamDutHD BIT  
)
AS
BEGIN
	IF NOT EXISTS (SELECT gv.Id FROM dbo.GiangVien gv WHERE gv.MaGiangVien = @MaGiangVien)
	BEGIN
		INSERT INTO dbo.GiangVien
		VALUES
		(   @MaGiangVien,
			@HoDem,
			@Ten,
			@GioiTinh,
			@NgaySinh,
			@HocVi,
			@IDKhoa,
			@CCCD,
			@SoDienThoai,
			@DiaChiLienLac,
			@IsChamDutHD 
			)
	END 
	ELSE
    BEGIN
        UPDATE dbo.GiangVien 
		SET HoDem = @HoDem,
			Ten = @Ten,
			GioiTinh = @GioiTinh,
			NgaySinh = @NgaySinh,
			HocVi = @HocVi,
			IDKhoa = @IDKhoa,
			CCCD = @CCCD,
			SoDienThoai = @SoDienThoai,
			DiaChiLienLac = @DiaChiLienLac,
			IsChamDutHD  = @IsChamDutHD 
		WHERE MaGiangVien = @MaGiangVien
    END
END
GO

alter PROCEDURE SP_XoaGiangVien
    @Id INT
AS
BEGIN
    DELETE dbo.GiangVien WHERE Id = @Id
END
GO

alter PROCEDURE SP_LoadGiangVien
(
	@GiangVien NVARCHAR(100),
	@IDKhoa INTl
)
AS 
BEGIN
	SELECT gv.Id, gv.MaGiangVien, gv.HoDem, gv.Ten, TenKhoa, NgaySinh, SoDienThoai, DiaChiLienLac, 
	GT = CASE GioiTinh WHEN 1 THEN N'Nữ' ELSE N'Nam' END, HocVi, CCCD, IDKhoa, IsChamDutHD, GioiTinh
	FROM dbo.GiangVien gv
		inner join dbo.Khoa k ON k.Id = gv.IDKhoa
	WHERE (LEN(ISNULL(@GiangVien, '')) = 0 OR gv.MaGiangVien = @GiangVien OR gv.HoDem + ' ' + gv.Ten LIKE N'%' + @GiangVien + '%')
		AND (@IDKhoa IS NULL OR gv.IDKhoa = @IDKhoa)
	ORDER BY gv.Ten, gv.HoDem, gv.MaGiangVien
END 
go
alter PROCEDURE SP_LoadMonHoc
(
	@MonHoc NVARCHAR(100)
)
AS
BEGIN
    SELECT mh.Id, mh.MaMonHoc, mh.TenMonHoc
	FROM dbo.MonHoc mh
	WHERE (LEN(ISNULL(@MonHoc, '')) = 0 OR mh.MaMonHoc = @MonHoc OR mh.TenMonHoc LIKE N'%' + @MonHoc + '%')
END
go

ALTER PROCEDURE SP_CapNhatMonHoc
(
	@MaMH NVARCHAR(10),
	@TenMH NVARCHAR(100)
)
AS
BEGIN
	IF NOT EXISTS (SELECT mh.Id FROM dbo.MonHoc mh WHERE mh.MaMonHoc = @MaMH)
	BEGIN
		INSERT INTO dbo.MonHoc
		VALUES
		(   @MaMH,
		    @TenMH
		    )
		
	END 
	ELSE
    BEGIN
        UPDATE dbo.MonHoc 
		SET TenMonHoc = @TenMH
		WHERE MaMonHoc = @MaMH
    END
END
GO

alter PROCEDURE SP_XoaMonHoc
(
    @Id INT
)
AS
BEGIN
    DELETE dbo.MonHoc WHERE Id = @Id
END
GO

ALTER PROCEDURE dbo.SP_BaoCaoThongKe
( 
	@Type INT
)
AS
BEGIN
    --1. thống kê số lượng GV theo khoa
	IF @Type = 1
	BEGIN
	    SELECT TieuChi = k.TenKhoa, SL = COUNT(gv.Id), ChiTiet = ''
		FROM dbo.GiangVien gv
			INNER JOIN dbo.Khoa k ON k.Id = gv.IDKhoa
		GROUP BY k.TenKhoa
	END
	--2. thống kê số lương GV tham gia giảng dạy môn học
	ELSE IF @Type = 2
	BEGIN
	    SELECT TieuChi = mh.TenMonHoc, SL = COUNT(gvmh.Id), ChiTiet = ''
		FROM dbo.GiangVienMonHoc gvmh
		INNER JOIN dbo.MonHoc mh ON mh.Id= gvmh.IDMonHoc
		GROUP BY mh.TenMonHoc
	END
	--3. thống kê số môn mỗi GV tham gia giảng dạy
	ELSE IF @Type = 3
	BEGIN
		SELECT TieuChi = gv.MaGiangVien + ' - ' + gv.HoDem + ' ' + gv.Ten, SL = COUNT(gvmh.Id), ChiTiet = dbo.GROUP_CONCAT(mh.MaMonHoc + ' - ' + mh.TenMonHoc)
		FROM dbo.GiangVienMonHoc gvmh
		INNER JOIN dbo.GiangVien gv ON gv.Id= gvmh.IDGiangVien
		INNER JOIN dbo.MonHoc mh ON mh.Id = gvmh.IDMonHoc
		GROUP BY gv.MaGiangVien, gv.HoDem, gv.Ten
	END
	ELSE 
	BEGIN
	    SELECT TieuChi = '', SL = NULL, ChiTiet = ''
	END
END
GO

ALTER PROCEDURE SP_CapNhatGVMH
(
	@IDGV INT,
	@IDMH INT
)
AS
BEGIN
    IF NOT EXISTS (SELECT mh.Id FROM dbo.GiangVienMonHoc mh WHERE mh.IDGiangVien = @IDGV AND mh.IDMonHoc = @IDMH)
	BEGIN
		INSERT INTO dbo.GiangVienMonHoc
		VALUES
		(   @IDGV,
		    @IDMH
		    )
	END 
END
go
ALTER PROCEDURE SP_BaoCaoThongKe
( 
	@Type INT
)
AS
BEGIN
    --1. thống kê số lượng GV theo khoa
	IF @Type = 1
	BEGIN
	    SELECT TieuChi = k.TenKhoa, SL = COUNT(gv.Id), ChiTiet = ''
		FROM dbo.GiangVien gv
			INNER JOIN dbo.Khoa k ON k.Id = gv.IDKhoa
		GROUP BY k.TenKhoa
	END
	--2. thống kê số lương GV tham gia giảng dạy môn học
	ELSE IF @Type = 2
	BEGIN
	    SELECT TieuChi = mh.TenMonHoc, SL = COUNT(gvmh.Id), ChiTiet = ''
		FROM dbo.GiangVienMonHoc gvmh
		INNER JOIN dbo.MonHoc mh ON mh.Id= gvmh.IDMonHoc
		GROUP BY mh.TenMonHoc
	END
	--3. thống kê số môn mỗi GV tham gia giảng dạy
	ELSE IF @Type = 3
	BEGIN
		SELECT TieuChi = gv.MaGiangVien + ' - ' + gv.HoDem + ' ' + gv.Ten, SL = COUNT(gvmh.Id), ChiTiet = dbo.GROUP_CONCAT(mh.MaMonHoc + ' - ' + mh.TenMonHoc)
		FROM dbo.GiangVienMonHoc gvmh
		INNER JOIN dbo.GiangVien gv ON gv.Id= gvmh.IDGiangVien
		INNER JOIN dbo.MonHoc mh ON mh.Id = gvmh.IDMonHoc
		GROUP BY gv.MaGiangVien, gv.HoDem, gv.Ten
	END
	ELSE 
	BEGIN
	    SELECT TieuChi = '', SL = NULL, ChiTiet = ''
	END
END
GO


--EXEC dbo.SP_BaoCaoThongKe @Type = 1 -- int
--EXEC dbo.SP_BaoCaoThongKe @Type = 2 -- int
--EXEC dbo.SP_BaoCaoThongKe @Type = 3 -- int

ALTER PROCEDURE SP_LoadGVMH
( 
	@IDGiangVien INT,
	@IDMonHoc INT,
	@Id INT
)
AS
BEGIN
    SELECT gvmh.Id, gv.MaGiangVien, gv.Ten, gv.HoDem, mh.MaMonHoc, mh.TenMonHoc, gvmh.IDGiangVien, gvmh.IDMonHoc FROM dbo.GiangVienMonHoc gvmh
	INNER JOIN dbo.GiangVien gv ON gv.Id = gvmh.IDGiangVien
	INNER JOIN dbo.MonHoc mh ON mh.Id = gvmh.IDMonHoc
	WHERE (@Id IS NULL OR gvmh.Id = @Id)
		AND (@IDGiangVien = -1 OR gvmh.IDGiangVien = @IDGiangVien)
		AND (@IDMonHoc = -1 OR gvmh.IDMonHoc = @IDMonHoc)
	ORDER BY gv.Ten, gv.HoDem, gv.MaGiangVien, mh.TenMonHoc
END
go
create PROCEDURE SP_XoaGVMH
(
    @Id INT
)
AS
BEGIN
    DELETE dbo.GiangVienMonHoc WHERE Id = @Id
END
GO