create table YHF_CONFIG
(
  SEQ          VARCHAR2(5),
  TYPE         VARCHAR2(50),
  CURSOR       VARCHAR2(1500),
  SOURCE_TABLE VARCHAR2(50),
  LONG_FLG     VARCHAR2(1)
);

delete from YHF_CONFIG;
commit;
prompt Loading YHF_CONFIG...
insert into YHF_CONFIG (SEQ, TYPE, CURSOR, SOURCE_TABLE, LONG_FLG)
values ('01', 'Applet Service Script', 'select wt.name,wt.script,wt.applet_id object_id from siebel.S_APPL_WEBSCRPT wt where wt.repository_id = :s_rep_id and wt.inactive_flg = ''N''', 'SIEBEL.S_APPLET', 'Y');
insert into YHF_CONFIG (SEQ, TYPE, CURSOR, SOURCE_TABLE, LONG_FLG)
values ('02', 'Applet Browser Script', 'select st.name,st.script,st.applet_id object_id from siebel.s_aplt_brsscrpt st where st.repository_id = :s_rep_id and st.inactive_flg = ''N''', 'SIEBEL.S_APPLET', 'Y');
insert into YHF_CONFIG (SEQ, TYPE, CURSOR, SOURCE_TABLE, LONG_FLG)
values ('03', 'BC Service Script', 'select t.name,t.script,t.buscomp_id object_id from siebel.s_buscomp_script t where t.repository_id = :s_rep_id and t.inactive_flg = ''N''', 'SIEBEL.S_BUSCOMP', 'Y');
insert into YHF_CONFIG (SEQ, TYPE, CURSOR, SOURCE_TABLE, LONG_FLG)
values ('04', 'BC Browser Script', 'select t.name,t.script,t.buscomp_id object_id from siebel.S_BC_BRS_SCRPT t where t.repository_id = :s_rep_id and t.inactive_flg = ''N''', 'SIEBEL.S_BUSCOMP', 'Y');
insert into YHF_CONFIG (SEQ, TYPE, CURSOR, SOURCE_TABLE, LONG_FLG)
values ('05', 'BS Service Script', 'select t.name,t.script,t.service_id object_id from siebel.s_service_scrpt t where t.repository_id = :s_rep_id and t.inactive_flg = ''N''', 'SIEBEL.S_SERVICE', 'Y');
insert into YHF_CONFIG (SEQ, TYPE, CURSOR, SOURCE_TABLE, LONG_FLG)
values ('06', 'BS Browser Script', 'select t.name,t.script,t.service_id object_id from siebel.S_SVC_BRS_SCRPT t where t.repository_id = :s_rep_id and t.inactive_flg = ''N''', 'SIEBEL.S_SERVICE', 'Y');
insert into YHF_CONFIG (SEQ, TYPE, CURSOR, SOURCE_TABLE, LONG_FLG)
values ('07', 'WF Step', 'select p.service_name name,p.service_name||''#''||p.method_name script,p.process_id object_id from siebel.s_Wfr_Stp pwhere p.repository_id = :s_rep_id and p.inactive_flg = ''N''', 'SIEBEL.S_WFR_PROC', 'N');
commit;
