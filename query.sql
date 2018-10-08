CREATE OR REPLACE PROCEDURE usp_APP_recipeOrderQuery(xmlParm in varchar2, sReturn out clob)
is
--处方购买记录查询

  v_orgid   varchar2(20);
  v_patid   varchar2(80);    --病人唯一号列表   
  v_orderstatus number(4);    --订单状态
  v_xml                  XMLTYPE;
  v_xmlhdl  dbms_xmlgen.ctxtype;
  v_xmltext clob;                 --varchar2(32767),转换为二进制型;
BEGIN   
    dbms_lob.createtemporary(v_xmltext,true); 
    dbms_lob.createtemporary(sReturn,true);
    v_xml := XMLTYPE(xmlParm);    -- 生成XML
    
    SELECT EXTRACTVALUE(VALUE(t),'/body/hospitalCode') 
           ,EXTRACTVALUE(VALUE(t),'/body/patientCode')   
           ,EXTRACTVALUE(VALUE(t),'/body/orderStatus')                               
           INTO v_orgid,v_patid,v_orderstatus
    FROM TABLE(XMLSEQUENCE(EXTRACT(v_xml, '/body'))) t;    -- 提取XML节点值
        
   
    v_xmlhdl:=dbms_xmlgen.newcontext('select
	orderNo,
	orderDate,
	orderStatus,
	payStatus,
	dispenseWay,
	receiverAddress,
	consigneeName,
	consigneeCall,
	boilSign,
	recipeLifetime,
	recipeinfo(identificationNumber) sumDescription,
	recipedetail(identificationNumber) drugDetail	
where recipe_order
where patientcode in (:v_patid0)
and orderStatus = :v_orderstatus0');
    dbms_xmlgen.setbindvalue(v_xmlhdl,'v_patid0',v_patid);
    dbms_xmlgen.setbindvalue(v_xmlhdl,'v_orderstatus0',v_orderstatus);                    
    --dbms_xmlgen.setrowsettag(v_xmlhdl,'data');
    dbms_xmlgen.setrowtag(v_xmlhdl,'data');
    dbms_xmlgen.setnullhandling(v_xmlhdl,dbms_xmlgen.EMPTY_TAG);
    v_xmltext:=dbms_xmlgen.getXML(v_xmlhdl);
    dbms_xmlgen.closecontext(v_xmlhdl);   
    end if;          
    if v_xmltext is null  then
    ireturn:=-1;
    sReturn:='没有符合条件的信息';
    else
    ireturn:=0;
    sReturn:=v_xmltext;
    end if ;
                
           
       
 END  usp_APP_Doctorsch_Query;
