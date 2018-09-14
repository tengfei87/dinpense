-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE BSOFT_MOB_GET_DOCTORLIST 
	@instr varchar(max),
	@outstr xml output

AS

declare @orgid varchar(20);
declare @deptId numeric(18);
declare @xmldoc xml;
declare @data xml;
declare @message varchar(max);

BEGIN

	SET NOCOUNT ON;
    -- 入参说明：
	set @xmldoc = @instr
	set @orgid = @xmldoc.value('(/data/hospitalCode)[1]','varchar(20)');
	set @deptId  = @xmldoc.value('(/data/departmentCode)[1]','numeric(18)');
	
	
	BEGIN TRY
	set @data = (
			select 
                gy_ygdm.ygdm doctorCode,
                gy_ygdm.ygxm doctorName
            from ys_mz_ksqx,gy_ygdm
            where exists (select ksdm from ms_ghks where ms_ghks.ksdm = ys_mz_ksqx.ksdm and mzks  =  @deptId) 
                and ys_mz_ksqx.YSDM = gy_ygdm.YGDM
            for xml path ('data'))
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
