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
-- the scripts verifies that the version of the patch matches the version of the database
-- -----------------------------------------------------------------------------

begin
    if '&VERSION_BASE' = current_version ()
    then
        null;
    else
        raise_application_error (-20100, 'Error. Versions mismatch. Expected: &VERSION_BASE got: ' || current_version ());
    end if;
end;
/

