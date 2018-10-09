create or replace type type_split as table of varchar2(40); 
create or replace function p_split
(
p_list varchar2,
p_sep varchar2 := ','
) return type_split pipelined
is
l_idx pls_integer;
v_list varchar2(50) := p_list;
begin
loop
l_idx := instr(v_list,p_sep);
if l_idx > 0 then
pipe row(substr(v_list,1,l_idx-1));
v_list := substr(v_list,l_idx+length(p_sep));
else
pipe row(v_list);
exit;
end if;
end loop;
return;
end p_split;