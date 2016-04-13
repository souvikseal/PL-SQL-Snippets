SET SERVEROUTPUT ON
DECLARE
  PROCEDURE MOVE_COLUMN_TO_POS (TABLE_NAMES IN VARCHAR2 
                                , COLUMN_NAMES IN VARCHAR2 
                                , CURR_POS IN NUMBER, POS IN NUMBER)
   IS
   column_name_prev   VARCHAR2(5000);
   select_stmt   VARCHAR2(5000);
   create_stmt   VARCHAR2(5000);
   drop_stmt   VARCHAR2(5000);
   rename_stmt   VARCHAR2(5000);
   BEGIN
        FOR rec in (SELECT COLUMN_NAME,COLUMN_ID 
                    FROM ALL_TAB_COLUMNS 
                    WHERE TABLE_NAME=TABLE_NAMES
                    AND COLUMN_ID<=POS
                    AND COLUMN_NAME<>COLUMN_NAMES
                    ORDER BY COLUMN_ID)
        LOOP
          IF(CURR_POS<POS) THEN
            IF(rec.COLUMN_ID<=POS) THEN
              IF(column_name_prev is null) THEN
                column_name_prev := rec.COLUMN_NAME;
              ELSE
                column_name_prev := column_name_prev || ',' ||rec.COLUMN_NAME;
              END IF;
            END IF;
          ELSE
            IF(rec.COLUMN_ID<POS) THEN
              IF(column_name_prev is null) THEN
                column_name_prev := rec.COLUMN_NAME;
              ELSE
                column_name_prev := column_name_prev || ',' ||rec.COLUMN_NAME;
              END IF;
            END IF;
          END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE (column_name_prev);
        
        IF(column_name_prev is null) THEN
            column_name_prev := COLUMN_NAMES;
        ELSE
            column_name_prev := column_name_prev || ',' ||COLUMN_NAMES;
        END IF;
        DBMS_OUTPUT.PUT_LINE (column_name_prev);
        
        FOR rec in (SELECT COLUMN_NAME,COLUMN_ID 
                    FROM ALL_TAB_COLUMNS 
                    WHERE TABLE_NAME=TABLE_NAMES
                    AND COLUMN_NAME<>COLUMN_NAMES
                    ORDER BY COLUMN_ID)
        LOOP
          IF(CURR_POS<POS) THEN
            IF(rec.COLUMN_ID>POS) THEN
              IF(column_name_prev is null) THEN
                column_name_prev := rec.COLUMN_NAME;
              ELSE
                column_name_prev := column_name_prev || ',' ||rec.COLUMN_NAME;
              END IF;
            END IF;
          ELSE
            IF(rec.COLUMN_ID>=POS) THEN
              IF(column_name_prev is null) THEN
                column_name_prev := rec.COLUMN_NAME;
              ELSE
                column_name_prev := column_name_prev || ',' ||rec.COLUMN_NAME;
              END IF;
            END IF;
          END IF;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE (column_name_prev);
        
        select_stmt:='SELECT '||column_name_prev||' FROM '||TABLE_NAMES;
        DBMS_OUTPUT.PUT_LINE (select_stmt);
        
        create_stmt:= 'CREATE TABLE '||TABLE_NAMES||'_DUP AS ('||select_stmt||')';
        DBMS_OUTPUT.PUT_LINE (create_stmt);
        
        EXECUTE IMMEDIATE create_stmt;
        
        drop_stmt:='DROP TABLE '||TABLE_NAMES;
        DBMS_OUTPUT.PUT_LINE (drop_stmt);
        EXECUTE IMMEDIATE drop_stmt;
        
        rename_stmt:='RENAME '||TABLE_NAMES || '_DUP TO '||TABLE_NAMES;
        DBMS_OUTPUT.PUT_LINE (rename_stmt);
        EXECUTE IMMEDIATE rename_stmt;
        
   END;
BEGIN
  MOVE_COLUMN_TO_POS('TEST_TABLE','TEST_COL',1,4);
END;
