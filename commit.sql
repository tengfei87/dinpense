CREATE  PROCEDURE usp_APP_recipe_order_commit(xmlParm in varchar2, sReturn out clob) return number
is
--处方下单业务


v_orgid varchar2(20);             -- hospitalCode	Y	string	医院代码
v_patid varchar2(20);             -- 患者id -- patientCode	Y	string	病人唯一号
v_take_way number;                -- takeWay	Y	int	取药方式
v_address varchar2(255);          -- consigneeAddress	N	string	收货地址
v_consigneeName  varchar2(40);    -- consigneeName	N	string	收货人姓名
v_consigncall varchar2(20);       -- consigneeCall	N	string	收货人电话
v_orderamount number(18,2);       -- orderAmount	Y	string	订单金额
v_indentitynumber varchar2(2000);                 -- identificationNumber	Y	string	处方识别
v_boilsign number(2);                -- boilSign	N	int	煎药标志
v_xml XMLTYPE;
v_recipe_count number(3,0);

BEGIN   
    v_xml := XMLTYPE(xmlParm);    -- 生成XML
    
    SELECT EXTRACTVALUE(VALUE(t),'/body/hospitalCode') 
           ,EXTRACTVALUE(VALUE(t),'/body/patientCode')
           ,EXTRACTVALUE(VALUE(t),'/body/takeWay') 
           ,EXTRACTVALUE(VALUE(t),'/body/consigneeAddress') 
           ,EXTRACTVALUE(VALUE(t),'/body/consigneeName')             
           ,EXTRACTVALUE(VALUE(t),'/body/consigneeCall')     
           ,EXTRACTVALUE(VALUE(t),'/body/orderAmount') 
           ,EXTRACTVALUE(VALUE(t),'/body/identificationNumber')
           ,EXTRACTVALUE(VALUE(t),'/body/boilSign')   
                      
           INTO v_orgid,v_patid,v_take_way,v_address,v_consigneeName,v_consigncall,v_orderamount,v_indentitynumber,v_boilsign
    FROM TABLE(XMLSEQUENCE(EXTRACT(v_xml, '/body'))) t;    -- 提取XML节点值
    
    --处方张数
    select count(1) into v_recipe_count from table(p_split(v_identitynumber)) t where substr(column_value,1,1) = '2';

    
    select t_recipe_order_seq.nextval into v_order_id from dual;
    select sysdate into v_order_date  from dual; 
    select sysdate + interval '48' hour  into order_expiring_date  from dual; 
    
    --写入订单
    insert into recipe_order
           (  order_id,order_date,order_amount, order_status, patient_id, take_way, 
              consignee_name, consignee_call, consignee_address, order_expiring_date,boilsign
             )     
    values ( v_order_id, v_order_date, v_orderamount, 0 , v_patid,v_take_way,
             v_consigneeName, v_consigncall, v_address, order_expiring_date,v_boilsign
             ); 
    if sqlcode<> 0 then       
       sReturn:='插入订单表失败'||sqlerrm;
       rollback ; 
       return -1;
    end if;
    --更新并锁定处方表，（需确认下锁定的标志，可以更新的标志）
    update ms_cf01 set cfbz = 1,orderid = v_identity where cfsb in  (select substr(column_value,3) from table(p_split(v_identitynumber)) t where substr(column_value,1,1) = '2') and cfbz = 0 and nvl(orderid,0) = 0;
    if sqlcode<> 0  then       
       sReturn:='更新处方信息失败'||sqlerrm;
       rollback ;        
       return -1;
    else if (sql%rowcount <> v_recipe_count) THEN
       sReturn:='更新处方信息失败，处方信息发生变动（更新处方数'||v_recipe_count||'实际更新处方数'||sql%rowcount||'）';
       rollback ;        
       return -1;

    end if;
    --库存冻结

    commit; 
    sReturn:= '<orderNo>'||v_order_id||'</orderNo><orderDate>'||v_order_date||'</orderDate><orderStatus>0</orderStatus><payStatus>0</payStatus>';   
    return 1;     
 END usp_APP_recipe_order_commit;
