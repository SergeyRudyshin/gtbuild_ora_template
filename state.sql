-- -----------------------------------------------------------------------------
-- Copyright 2017 Sergey Rudyshin. All rights reserved.
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--    http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- the script captures a state of the database 
-- Its firts parameter is a name of the schema to be examined
--
-- the script may be adjusted in various ways
-- for example it can look at the data of some project specific tables (such as dictionaries)
-- -----------------------------------------------------------------------------

-- @depends on: skip

set linesize 1000 pagesize 10000 arraysize 200 TRIMSPOOL ON TERMOUT OFF echo ON

define CAPTURE_USER=&1

spool state.sql.out

column owner format a20
column name format a30
column object_name format a30
column subobject_name format a30

select owner, object_type, 
    decode (generated, 'N', object_name, regexp_replace (object_name, '^SYS.*$', 'SYS_XXX')) object_name, 
    regexp_replace (subobject_name, '^SYS.*$', 'SYS_XXX') subobject_name, 
    status, temporary
from all_objects
where owner = '&CAPTURE_USER'
order by 1,2,3,4;

column text_hash format 9999999999

select owner, type, name object_name, ora_hash(sum(line || ora_hash(text))) text_hash 
from all_source 
where owner = '&CAPTURE_USER' 
group by owner, name, type order by owner, type, name;

column TRIGGERING_EVENT format a30
column TRIGGER_NAME format a30
column TABLE_NAME format a30
column OWNER format a30
column COLUMN_NAME format a30
column DESCRIPTION format a30
column WHEN_CLAUSE format a30
column REFERENCING_NAMES format a30
column TRIGGER_BODY format a30
column TABLE_OWNER format a30

select * from all_triggers where owner = '&CAPTURE_USER' order by 1,2,3,4;

column DATA_TYPE format a30
column OWNER format a30
column TABLE_NAME format a30
column COLUMN_NAME format a30
column DATA_TYPE_OWNER format a30
column LOW_VALUE format a30
column TABLE_NAME format a30
column DATA_DEFAULT format a30

select
owner, table_name, column_name, data_type, data_type_mod, data_type_owner, data_length, data_precision, data_scale, 
nullable, column_id, default_length, data_default
from all_tab_columns
where owner = '&CAPTURE_USER'
order by 1,2,3,4;


/*
column VALUE format a30
column DISPLAY_VALUE format a30
column UPDATE_COMMENT format a30
column NAME format a30
column DESCRIPTION format a30
select * from v$parameter2;
*/

/*
column OWNER format a30
column LOG_GROUP_NAME format a30
column TABLE_NAME format a30

select owner, log_group_name, table_name, log_group_type, always, generated 
from dba_log_groups 
order by owner, log_group_name, table_name, log_group_type, always, generated;
*/

column OWNER format a30
column PRIVILEGE format a30
column TABLE_NAME format a30
column GRANTEE format a30
column GRANTOR format a30

select *
from all_tab_privs 
where grantee = '&CAPTURE_USER' 
order by 1,2,3,4;

column GRANTEE format a30
column PRIVILEGE format a30
select grantee, privilege, admin_option
from dba_sys_privs 
where grantee like '&CAPTURE_USER' order by grantee, privilege, admin_option ;

spool off
