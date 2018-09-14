-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE <存储过程名字>
	@instr varchar(max),
	@outstr xml output

AS

declare @orgid varchar(20);
declare @patientid varchar(max);
declare @xmldoc xml;
declare @data xml;
declare @message varchar(max);
declare @patientId_t table(patientId numeric(18));
BEGIN

	SET NOCOUNT ON;
    -- 入参说明：
	set @xmldoc = @instr
	set @orgid = @xmldoc.value('(/data/hospitalCode)[1]','varchar(20)');
	set @patientid = @xmldoc.value('(/data/patientCodeList)[1]','varchar(max)');
	insert into @patientId_t select c.value('.','varchar(18)') from @xmldoc.nodes('/data/patientCodeList') T(c)
	
	
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
			(select convert(varchar(4),row_number() OVER(ORDER BY jlbh))+ '.' + jbmc + ';'   from ys_mz_jbzd where jzxh = ys_mz_jzls.jzxh for xml path('')) diagnsisName,
			convert(xml,(select
			(select ypmc from yk_typk where ypxh = ms_cf02.ypxh) drugName,
			(select ypmc from yk_typk where ypxh = ms_cf02.ypxh) specifiation,
			convert(varchar(18),ms_cf02.ypsl) + ms_cf02.YFDW quantity,
			convert(varchar(8),ms_cf02.ycjl) + ((select jldw from yk_typk where ypxh = ms_cf02.ypxh)) onesDose,
			(select PCMC from GY_SYPC where pcbm = ms_cf02.YPYF and jgid  = 0 ) frequency,
			(select XMMC from zy_ypyf where ypyf = ms_cf02.GYTJ) usage
			from ms_cf01,ms_cf02 where ms_cf01.cfsb = ms_cf02.cfsb and ms_cf01.jzxh = ys_mz_jzls.jzxh for xml path('drugItem'))) 
			from ys_mz_jzls
			where brbh in ( select patientId from @patientId_t ) for xml path ('data'))
	END TRY
	BEGIN CATCH
		SET @message =  ERROR_MESSAGE();
		GOTO p_error

	END CATCH
	
	
	-- 出参统一处理
	SET @outstr =  (SELECT 1 'code', isnull(@message,'') 'message',isnull(@data,'') FOR XML PATH('root'));
	
	
	--根据接口需要，只有一条数据时处理
	IF (  @outstr.value('count(/root/data)','int')  < 2 ) 
	BEGIN
		SET @outstr.modify('insert <data></data> as last into (/root)[1]')
		
	END
    return 1
	


    p_error:
    SET @outstr =  (SELECT -1 'code', isnull(@message,'') 'message','' 'data' FOR XML PATH('root'));
    return -1
END

GO 
