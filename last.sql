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
-- the script:
-- 1) compiles ivalid objects of the schema 
-- 2) verifies that there are no invalid objects left
-- 3) prints the schema's errors
--
-- the variable &THE_USER is to be defined before the script invocation
-- -----------------------------------------------------------------------------

begin 
    DBMS_UTILITY.compile_schema ('&THE_USER');
end;
/

set serveroutput on size unlimited linesize 200

column owner format a20
column name format a30
column text format a60

select * from all_errors where owner = '&THE_USER' order by 1,2,3,4,5;

declare
    l_invalid_cnt number := 0;
begin
    for x in (
        select owner, object_name from all_objects where owner = '&THE_USER' and status != 'VALID' order by 1,2
    ) loop
        l_invalid_cnt := l_invalid_cnt + 1;
        dbms_output.put_line (x.owner || '.' || x.object_name);
    end loop;
    
    if l_invalid_cnt > 0 then
        raise_application_error (-20100, 'Number of invalid objects is ' || l_invalid_cnt);
    end if;
end;
/
