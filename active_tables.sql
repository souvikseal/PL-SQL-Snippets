SET SERVEROUTPUT ON
DECLARE
--function generating CREATE TABLE statements
FUNCTION FIND_LAST_UPDT_DTTM_TABLE (tablename IN VARCHAR2) 
  RETURN NUMBER
   IS
   temp   NUMBER;
   query_stmt varchar2(1000);
   
   BEGIN             
        query_stmt:=  'begin SELECT NVL(MAX(ora_rowscn),0)
                      INTO :temp_holder FROM '||tablename||';end;';
        execute immediate query_stmt using out temp;
        --DBMS_OUTPUT.put_line(query_stmt);
        RETURN temp;       
   END;
--driver program
Procedure proc_main IS
 active_tables CLOB;
 inactive_tables CLOB;
 change_number NUMBER;
 last_updt_dt varchar2(1000);
 cursor cur IS
      SELECT u.*
      FROM user_tables u
      where u.tablespace_name = 'SAMPLE_DATABASE'
      and u.table_name LIKE 'PHRASE_%'
      and u.table_name not like '%TEST'
      order by u.table_name;
BEGIN
  FOR rec in cur
      LOOP
        change_number:=FIND_LAST_UPDT_DTTM_TABLE(rec.table_name);
        --DBMS_OUTPUT.put_line(change_number);
        IF (change_number = 0) THEN
          inactive_tables:=inactive_tables||chr(13)||chr(10)||rec.table_name;
        ELSE
          last_updt_dt:=trunc(SCN_TO_TIMESTAMP(change_number));
          active_tables:=rec.table_name||'; Last Updt DTTM:'||last_updt_dt||chr(13)||chr(10)||active_tables;
          --active_tables:=active_tables||chr(13)||chr(10)||rec.table_name;
        END IF;
      END LOOP;
      DBMS_OUTPUT.put_line('Inactive_tables:');
      DBMS_OUTPUT.put_line(inactive_tables);
      DBMS_OUTPUT.put_line(' ');
      DBMS_OUTPUT.put_line('Active_tables:');
      DBMS_OUTPUT.put_line(' ');
      DBMS_OUTPUT.put_line(active_tables);
END;
   BEGIN
      proc_main();
   END;
