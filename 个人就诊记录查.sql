-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE BSOFT_MOB_GET_VISITRECORD 
	@instr varchar(max),
	@outstr xml output

AS
declare @orgid varchar(20);
declare @patientid varchar(max);
declare @xmldoc xml;
declare @data xml;
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--医院代码	HospitalCode	Y
	--患者唯一号列表	patientCodeList	Y	患者在平台绑定多个档案时，传入多个唯一号，数据用逗号隔开。
    -- Insert statements for procedure here
	set @xmldoc = @instr;
    set @orgid = @xmldoc.VALUE('(/data/hospitalCode)[1]','varchar(20)');
	set @patientid = @xmldoc.VALUE('(/data/patientCodeList)[1]','varchar(max)');
	BEGIN TRY
	set @data = (
			select 
			jzxh visitNo,
			brbh patientCode,
			(select brxm from ms_brda where brid = brbh) patientNme,
			convert(varchar(20),kssj,120) visitTime,
			ksdm departmentCode,
			(select ksmc from gy_ksdm where ksdm = ys_mz_jzls.KSDM) departmentName,
			(select ygxm from gy_ygdm where ygdm = ys_mz_jzls.YSDM) doctorName,
			(select convert(varchar(4),row_number() OVER(ORDER BY jlbh))+ '.' + jbmc + ';'   from ys_mz_jbzd where jzxh = 31545 for xml path('')) diagnsisName,
			convert(xml,(select
			(select ypmc from yk_typk where ypxh = ms_cf02.ypxh) drugName,
			(select ypmc from yk_typk where ypxh = ms_cf02.ypxh) specifiation,
			ms_cf02.ypsl quantity,
			convert(varchar(8),ms_cf02.ycjl) + ((select jldw from yk_typk where ypxh = ms_cf02.ypxh)) onesDose,
			(select PCMC from GY_SYPC where pcbm = ms_cf02.YPYF and jgid  = 0 ) frequency,
			(select XMMC from zy_ypyf where ypyf = ms_cf02.GYTJ) usage
			from ms_cf01,ms_cf02 where ms_cf01.cfsb = ms_cf02.cfsb and ms_cf01.jzxh = ys_mz_jzls.jzxh for xml path('drugItem'))) 
			from ys_mz_jzls
			where brbh in( @patientid  ) for xml path ('data'),root('root'))
	END TRY
	BEGIN CATCH
		SET @message =  ERROR_MESSAGE();
		GOTO p_error

	END CATCH
	--只有一条数据时处理
	IF (  @data.exist('(/root/data)[2]') = 0) 
	BEGIN
		SET @data = convert(text,@data) + '<data></data>'
		



	END
	 
	SET @outstr =  (SELECT 1 'code',@message 'message',@data 'data' FOR XML PATH(''));
	return 1
	 p_error:
	 SET @outstr =  (SELECT -1 'code',@message 'message','' 'data' FOR XML PATH(''));
	 return 0

	
END

GO 
