-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE BSOFT_MOB_DISPENSE_COMMITORDER
	@instr varchar(max),
	@outstr xml output

AS

declare @orgid varchar(20);
declare @patientid varchar(max);
declare @xmldoc xml;
declare @data xml;
declare @message varchar(max);
declare @deptid numeric(18);
declare @docid varchar(18);
declare @parentvisitno numeric(18);
declare @outorderno varchar(40);
declare @ordertime varchar(20);
declare @outpatienttype numeric(4);
declare @orderno numeric(18);
BEGIN

	SET NOCOUNT ON;
    -- 入参说明：
    -- 医院代码	hospitalCode
    -- 病人唯一号	patientCode
    -- 科室代码	departmentCode
    -- 医生代码	doctorCode
    -- 医生就诊记录识别	parentVisitNo
    -- 平台订单号	outOrderNo
    -- 申请时间	orderTime
    -- 门诊类型	outPatientType

	set @xmldoc = @instr
	set @orgid = @xmldoc.value('(/data/hospitalCode)[1]','varchar(20)');
	set @patientid = @xmldoc.value('(/data/patientCode)[1]','varchar(max)');
	set @deptid = @xmldoc.value('(/data/departmentCode)[1]','varchar(max)');
	set @docid = @xmldoc.value('(/data/doctorCode)[1]','varchar(max)');
	set @parentVisitNo = @xmldoc.value('(/data/parentVisitNo)[1]','varchar(max)');
	set @outOrderNo = @xmldoc.value('(/data/outOrderNo)[1]','varchar(max)');
	set @orderTime = @xmldoc.value('(/data/orderTime)[1]','varchar(max)');
	set @outPatientType = @xmldoc.value('(/data/outPatientType)[1]','varchar(max)');
	

	--参数校验
	IF (isnull(@orgid,'') = '')
	BEGIN
		set @orgid = 1
	END


	BEGIN TRY
		begin tran
		INSERT INTO [dbo].[MS_YYGH]
				([YYXH]
				,[JGID]
				,[YYMM]
				,[BRID]
				,[GHRQ]
				,[KSDM]
				,[ZBLB]
				,[YSDM]
				,[YYLB]
				,[GHBZ]
				,[YYRQ]
				,[JZXH]
				,[SBXH]
				,[ZCID]
				,[DJGH]
				,[ZJLX]
				,[ZJHM]
				,[LXDH]
				,[QXYY]
				,[OUTORDERNO]
				,[PARENTVISITNO])
			VALUES
				(@orderno, 
					, @orgid
					, ''''
					, @patientid
					, getdate()
					, <KSDM, varchar(18), >
					, <ZBLB, numeric(4,0), >
					, <YSDM, varchar(10), >
					, <YYLB, numeric(2,0), >
					, <GHBZ, numeric(1,0), >
					, <YYRQ, datetime, >
					, <JZXH, numeric(4,0), >
					, <SBXH, numeric(18,0), >
					, <ZCID, numeric(18,0), >
					, <DJGH, varchar(10), >
					, <ZJLX, numeric(8,0), >
					, <ZJHM, varchar(40), >
					, <LXDH, varchar(40), >
					, <qxyy, varchar(100), >)


	
	END TRY
	BEGIN CATCH
		SET @message =  ERROR_MESSAGE();
		rollback tran
		GOTO p_error

	END CATCH
	if @@TRANCOUNT > 0 
	BEGIN
		commit tran
	END
	
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


SELECT * FROM MS_YYGH
