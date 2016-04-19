SET SERVEROUTPUT ON
DECLARE
--function generating CREATE TABLE statements
FUNCTION CREATE_TABLE_STMT_GENERATOR (tablename IN VARCHAR2,username IN VARCHAR2) 
  RETURN VARCHAR2
   IS
   temp   CLOB;
   BEGIN             
        SELECT dbms_metadata.get_ddl('TABLE',tablename,username) 
        INTO temp 
        FROM dual;

        RETURN temp;       
   END;
--driver program
Procedure proc_main IS
 cursor cur IS
      SELECT u.*
      FROM user_tables u
      where u.tablespace_name = 'SAMPLE_DATABASE'
      and u.table_name LIKE 'QUALIFIER_%'
      and u.table_name not like '%TEST'
      and u.num_rows>0
      and ROWNUM <= 5;
BEGIN
  FOR rec in cur
      LOOP
        DBMS_OUTPUT.PUT_LINE(CREATE_TABLE_STMT_GENERATOR(rec.table_name,'CAAL_JUNIT'));
      END LOOP;
END;
   BEGIN
      proc_main();
   END;

