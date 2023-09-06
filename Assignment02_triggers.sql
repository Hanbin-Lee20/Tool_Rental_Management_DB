-- Trigger for TOOL_VIEW
CREATE OR REPLACE TRIGGER TOOL_VIEW_TRG
INSTEAD OF INSERT OR UPDATE OR DELETE ON TOOL_VIEW
FOR EACH ROW
DECLARE
    v_tool_id NUMBER;
    v_tool_name VARCHAR2(255);
    v_tool_serial_number VARCHAR2(255);
--    v_brand_id NUMBER;
BEGIN
    -- Handle INSERT operation
    IF INSERTING THEN
        v_tool_id := :NEW.TOOL_ID;
        v_tool_name := :NEW.TOOL_NAME;
        v_tool_serial_number := :NEW.TOOL_SERIAL_NUMBER;
--        v_brand_id := :NEW.TOOL_BRAND_ID;
        
        INSERT INTO TOOL (TOOL_ID, NAME, BRAND_ID)
        VALUES (v_tool_id, v_tool_name, NULL);

        INSERT INTO TOOL_SERIAL
        VALUES (GROUP2_SEQ.NEXTVAL, v_tool_id, v_tool_serial_number, NULL, SYSDATE, NULL
        );

        INSERT INTO TOOL_VIEW_HISTORY
        VALUES (GROUP2_SEQ.NEXTVAL, v_tool_id, v_tool_name, v_tool_serial_number, 'INSERT', SYSTIMESTAMP
        );

    -- Handle UPDATE operation
    ELSIF UPDATING THEN
        v_tool_id := :OLD.TOOL_ID;
        v_tool_name := :NEW.TOOL_NAME;
        v_tool_serial_number := :NEW.TOOL_SERIAL_NUMBER;

        UPDATE TOOL SET NAME = v_tool_name
        WHERE TOOL_ID = v_tool_id;

        UPDATE TOOL_SERIAL SET SERIAL_NUMBER = v_tool_serial_number, ENDTIME = SYSDATE
        WHERE TOOL_ID = v_tool_id AND ENDTIME IS NULL;

        INSERT INTO TOOL_SERIAL (SERIAL_ID, TOOL_ID, SERIAL_NUMBER, CATEGORY_ID, STARTTIME, ENDTIME)
        VALUES (
            GROUP2_SEQ.NEXTVAL, v_tool_id, v_tool_serial_number, NULL, SYSDATE, NULL
        );

        INSERT INTO TOOL_VIEW_HISTORY (
            HISTORY_ID, TOOL_ID, TOOL_NAME, SERIAL_NUMBER, CHANGE_TYPE, CHANGE_TIMESTAMP
        )
        VALUES (
            GROUP2_SEQ.NEXTVAL, v_tool_id, v_tool_name, v_tool_serial_number, 'UPDATE', SYSTIMESTAMP
        );

    -- Handle DELETE operation
    ELSIF DELETING THEN
        v_tool_id := :OLD.TOOL_ID;

        DELETE FROM TOOL WHERE TOOL_ID = v_tool_id;
        UPDATE TOOL_SERIAL SET ENDTIME = SYSDATE WHERE TOOL_ID = v_tool_id AND ENDTIME IS NULL;

        INSERT INTO TOOL_VIEW_HISTORY (
            HISTORY_ID, TOOL_ID, TOOL_NAME, SERIAL_NUMBER, CHANGE_TYPE, CHANGE_TIMESTAMP
        )
        VALUES (
            GROUP2_SEQ.NEXTVAL, v_tool_id, :OLD.TOOL_NAME, NULL, 'DELETE', SYSTIMESTAMP
        );
    END IF;
END;
/
