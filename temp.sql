-- 添加空节点
-- declare @xml xml;
-- declare @count int;
-- set @xml = '<root><code></code><message></message><data>1</data></root>';
-- set @count =    @xml.value('count(/root/data)','int');
-- if @count < 2 
-- set @xml.modify('insert <data></data> as last into (/root)[1]');
-- declare @instr varchar(max);


--执行存储过程
DECLARE	@return_value int,
		@outstr xml

EXEC	@return_value = [dbo].[BSOFT_MOB_GET_VISITRECORD]
		@instr = N'<data><hospitalCode>1</hospitalCode><patientCodeList>6388605</patientCodeList><patientCodeList>6388610</patientCodeList></data>',
		@outstr = @outstr OUTPUT

SELECT	@outstr as N'@outstr'

SELECT	'Return Value' = @return_value
