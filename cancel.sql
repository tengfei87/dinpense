CREATE OR REPLACE PROCEDURE usp_APP_recipe_order_cancel(xmlParm in varchar2, sReturn out clob)
is
--处方下单取消


v_orgid varchar2(20);             -- hospitalCode  Y  string  医院代码
v_patid varchar2(20);             -- 患者id -- patientCode  Y  string  病人唯一号
v_orderno number(18);                -- 处方购买订单号
v_xml XMLTYPE;
--v_count number(3,0);
BEGIN
    v_xml := XMLTYPE(xmlParm);    -- 生成XML

    SELECT EXTRACTVALUE(VALUE(t),'/body/hospitalCode')
           ,EXTRACTVALUE(VALUE(t),'/body/patientCode')
           ,EXTRACTVALUE(VALUE(t),'/body/paymentOrderId')
           

           INTO v_orgid,v_patid,v_orderNo
    FROM TABLE(XMLSEQUENCE(EXTRACT(v_xml, '/body'))) t;    -- 提取XML节点值


    update payment_order set order_status = 5 where order_id = v_orderno and pay_status = 0 and order_status = 0;
    if sqlcode<> 0 then

       sReturn:= '<code>-1</code><message>更新订单失败'||sqlerrm||'）</message><data></data>';
       rollback ;
       return ;
    end if;



    --解锁处方
    update ms_cf01 set cfbz = 0,orderid = null where orderid = v_orderno and cfbz = 1 ;
    if sqlcode<> 0 then
       sReturn:= '<code>-1</code><message>解锁处方失败'||sqlerrm||'）</message><data></data>';
       rollback ;
       return ;
    end if;
    commit;
    --解冻库存


    -- 返回

    sReturn:= '<code>0</code><message></message><data>/data>';


    return ;
 END usp_APP_recipe_order_cancel;
