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
        order_id "paymentOrderId",
        order_date "orderDate",
        order_status        "orderStatus",
        invoice_no "invoiceNo",
        pay_status      "payStatus",
        take_way        "takeWay",
        consignee_address       "address",
        consignee_name        "consigneeName",
        consignee_call       "consigneeCall",
        fee_identifier "identificationNumber",
        boil_sign "boilSign",
        order_expiring_date  "orderLifetime"
        f_recipeinfo(fee_identifier) ,
        f_recipedetail(fee_identifier)
    from payment_order
    where patient_id in (select column_value  from table(p_split(:v_patid0)) t )
    and orderStatus = :v_orderstatus0');
    dbms_xmlgen.setbindvalue(v_xmlhdl,'v_patid0',v_patid);
    dbms_xmlgen.setbindvalue(v_xmlhdl,'v_orderstatus0',v_orderstatus);
    dbms_xmlgen.setrowsettag(v_xmlhdl,'root');
    dbms_xmlgen.setrowtag(v_xmlhdl,'data');
    dbms_xmlgen.setnullhandling(v_xmlhdl,dbms_xmlgen.EMPTY_TAG);
    v_xmltext:=dbms_xmlgen.getXML(v_xmlhdl);
    dbms_xmlgen.closecontext(v_xmlhdl);
    
    if v_xmltext is null  then
        sReturn:= '<code>-1</code><message>没有符合条件的信息</message><data></data>';
        return;
    else
        sReturn:= '<code>0</code><message></message><data>'||v_xmltext||'</data>';
    end if ;
    return;
 END  usp_APP_recipeOrderQuery;
