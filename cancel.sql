CREATE  PROCEDURE usp_APP_recipe_order_cancel(xmlParm in varchar2, sReturn out clob)
is
--处方下单取消
hospitalCode	Y	string	医院代码
orderNo	Y	string	处方购买订单号
patientCode	Y	string	病人唯一号
cancelReason	Y	string	取消原因

v_orgid varchar2(20);             -- hospitalCode	Y	string	医院代码
v_patid varchar2(20);             -- 患者id -- patientCode	Y	string	病人唯一号
v_orderNo number(18);                -- 处方购买订单号
v_cancelReason varchar2(255);          -- consigneeAddress	N	string	收货地址
v_xml XMLTYPE;
v_count number(3,0);
BEGIN   
    v_xml := XMLTYPE(xmlParm);    -- 生成XML
    
    SELECT EXTRACTVALUE(VALUE(t),'/body/hospitalCode') 
           ,EXTRACTVALUE(VALUE(t),'/body/patientCode')
           ,EXTRACTVALUE(VALUE(t),'/body/orderNo') 
           ,EXTRACTVALUE(VALUE(t),'/body/cancelReason')           
                      
           INTO v_orgid,v_patid,v_orderNo,v_cancelReason
    FROM TABLE(XMLSEQUENCE(EXTRACT(v_xml, '/body'))) t;    -- 提取XML节点值
    --查询订单内的处方
    select indentitynumber into v_indentity from recipe_order where order_id = v_orderno;
    --处理处方识别  
    v_indentity

    update recipe_order set order_status = 5 where order_id = v_orderNo and payStatus = 0 and order_status = 0;
    if sqlcode<> 0 then
       
       sReturn:='插入订单表失败'||sqlerrm;
       rollback ; 
       return;
    end if;



    --解锁处方
    update ms_cf01 set cfbz = 0,orderid = null where cfsb in  (v_indentity) and cfbz = 0 ;
    if sqlcode<> 0 then       
       sReturn:='更新处方信息失败'||sqlerrm;
       rollback ; 
       sReturn:='<code></code><message>'||sReturn||'</message>'||'<data></data>';
       return;
    end if;
    commit; 

    -- 返回
    -- <orderNo>   
    -- orderStatus
    -- payStatus

    sReturn:='<code></code><message></message>'||'<data>'||to_char(v_pass)||'</data>';        
 END usp_APP_recipe_order_cancel;
