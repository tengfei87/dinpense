create or replace function f_recipedetail(v_identitynumber in varchar2) return varchar2
is
  v_return varchar2(4000);
  v_xmlhdl  dbms_xmlgen.ctxtype;
  v_xmltext clob;                 --varchar2(32767),转换为二进制型;
BEGIN
    dbms_lob.createtemporary(v_xmltext,true);
    --dbms_lob.createtemporary(sReturn,true);
    /*select
    (select fymc from gy_ylsf where fyxh = ms_yj02.ylxh )name,
    (select fydw from gy_ylsf where fyxh = ms_yj02.ylxh) specification,
    ms_yj02.yldj price,
    ms_yj02.ylsl quantity,
    (select fydw from gy_ylsf where fyxh = ms_yj02.ylxh) unit
    from ms_yj02
    where yjxh in (select substr(column_value,3) from table(p_split(:v_identitynumber0)) t where substr(column_value,1,1) = ''1'')
    */
    
    v_xmlhdl:=dbms_xmlgen.newcontext('
    select
    (select fymc from yk_typk where ypxh = ms_cf02.ypxh )name,
    ms_cf02.yfgg specification,
    ms_cf02.ypdj price,
    ms_cf02.ypsl quantity,
    ms_cf02.yfdw unit
    from ms_cf02
    where cfsb in (select substr(column_value,3) from table(p_split(:v_identitynumber0)) t where substr(column_value,1,1) = ''2'')
    ');
    dbms_xmlgen.setbindvalue(v_xmlhdl,'v_identitynumber0',v_identitynumber);
    dbms_xmlgen.setrowsettag(v_xmlhdl,'data');
    dbms_xmlgen.setrowtag(v_xmlhdl,'drugDetail');
    dbms_xmlgen.setnullhandling(v_xmlhdl,dbms_xmlgen.EMPTY_TAG);
    v_xmltext:=dbms_xmlgen.getXML(v_xmlhdl);
    dbms_xmlgen.closecontext(v_xmlhdl);
    
    if v_xmltext is null  then
       v_xmltext := '-1' ;
    end if ;
    v_return := v_xmltext;
    return v_return;
end f_recipedetail;
