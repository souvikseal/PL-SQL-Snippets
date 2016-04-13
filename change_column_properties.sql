SET SERVEROUTPUT ON
DECLARE
  PROCEDURE CHANGE_COLUMN_PROPERTIES (TABLE_NAME IN VARCHAR2 
                                , SOURCE_COLUMN_NAME IN VARCHAR2 
                                , SOURCE_COLUMN_TYPE IN VARCHAR2 
                                , DEST_COLUMN_NAME IN VARCHAR2 
                                , DEST_COLUMN_TYPE IN VARCHAR2 )
   IS
   add_column   VARCHAR2(1000);
   updt_column   VARCHAR2(1000);
   drop_column   VARCHAR2(1000);
   rename_column   VARCHAR2(1000);
   temp_dest    VARCHAR2(1000);
   BEGIN
        IF(SOURCE_COLUMN_TYPE is not null) THEN
          IF(DEST_COLUMN_NAME is null) THEN
            IF(DEST_COLUMN_TYPE is null) THEN --add new column
                  DBMS_OUTPUT.PUT_LINE ('Add a new column:');
                  
                  add_column :='ALTER TABLE '||TABLE_NAME||' ADD '|| SOURCE_COLUMN_NAME|| ' '||SOURCE_COLUMN_TYPE;
                  DBMS_OUTPUT.PUT_LINE (add_column);
                  
                  EXECUTE IMMEDIATE add_column;
                  
            ELSE
                  DBMS_OUTPUT.PUT_LINE ('Change column type:');
                  
                  temp_dest:=SOURCE_COLUMN_NAME||'_DUP';
                  add_column :='ALTER TABLE '||TABLE_NAME||' ADD '|| temp_dest|| ' '||DEST_COLUMN_TYPE;
                  DBMS_OUTPUT.PUT_LINE (add_column);
                  EXECUTE IMMEDIATE add_column;
                  
                  updt_column:='UPDATE '|| TABLE_NAME || ' SET '|| temp_dest || '= CAST(' || SOURCE_COLUMN_NAME || ' AS ' || DEST_COLUMN_TYPE || ')';
                  DBMS_OUTPUT.PUT_LINE (updt_column);
                  EXECUTE IMMEDIATE updt_column;
                  
                  drop_column:= 'ALTER TABLE '|| TABLE_NAME|| ' DROP COLUMN '||SOURCE_COLUMN_NAME;
                  DBMS_OUTPUT.PUT_LINE (drop_column);
                  EXECUTE IMMEDIATE drop_column;
                  
                  rename_column:= 'ALTER TABLE '||TABLE_NAME||' RENAME COLUMN '|| temp_dest|| ' TO '||SOURCE_COLUMN_NAME;
                  DBMS_OUTPUT.PUT_LINE (rename_column);
                  EXECUTE IMMEDIATE rename_column;
            END IF;
          ELSE --change column name
              DBMS_OUTPUT.PUT_LINE ('Change column name:');
              add_column :='ALTER TABLE '||TABLE_NAME||' RENAME COLUMN '|| SOURCE_COLUMN_NAME|| ' TO '||DEST_COLUMN_NAME;
              EXECUTE IMMEDIATE add_column;
          END IF;
      ELSE --SOURCE COLUMN TYPE is null
          IF(DEST_COLUMN_NAME is null) THEN --drop column
            drop_column:= 'ALTER TABLE '|| TABLE_NAME|| ' DROP COLUMN '||SOURCE_COLUMN_NAME;
            DBMS_OUTPUT.PUT_LINE (drop_column);
            EXECUTE IMMEDIATE drop_column;
          ELSE
            DBMS_OUTPUT.PUT_LINE ('Change column name:');
              add_column :='ALTER TABLE '||TABLE_NAME||' RENAME COLUMN '|| SOURCE_COLUMN_NAME|| ' TO '||DEST_COLUMN_NAME;
              EXECUTE IMMEDIATE add_column;
          END IF;
      END IF;  
   END;
BEGIN
  CHANGE_COLUMN_PROPERTIES ('TEST_TABLE', 'TEST_COL', null,null,null);--drop column
  --CHANGE_COLUMN_PROPERTIES ('TEST_TABLE', 'TEST_COL', 'VARCHAR2',null,'NUMBER');--change column data type
  --CHANGE_COLUMN_PROPERTIES ('TEST_TABLE', 'TEST_COL', null,'TARGET_UNIT_DISPLAY',null);--change column name
  --CHANGE_COLUMN_PROPERTIES ('TEST_TABLE', 'TEST_COL', null,null,null);--drop column
END;
