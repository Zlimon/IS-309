create or replace procedure ADD_ORG_CAUSE_SP (
    p_org_id            IN  INTEGER,    -- NOT NULL
    p_cause_name        IN  VARCHAR     -- NOT NULL
)
IS
    ex_exception        EXCEPTION;
    ex_error_msg        VARCHAR (200);
    checked_org_id      NUMBER;
    checked_cause_name  VARCHAR (50);
    org_id_out          NUMBER;
    cause_name_out      VARCHAR (50);

    CURSOR check_org_id IS 
        SELECT ORGANIZATION_id FROM VM_ORGANIZATION WHERE ORGANIZATION_ID = p_org_id;
    
    CURSOR check_cause_name IS
        SELECT CAUSE_NAME FROM VM_CAUSE WHERE CAUSE_NAME = p_cause_name;

    BEGIN
        IF p_org_id IS NULL THEN
            ex_error_msg := 'Missing organization ID! Can not be NULL';
            RAISE ex_exception;
        ELSIF p_cause_name IS NULL THEN
            ex_error_msg := 'Missing cause name! Can not be NULL';
            RAISE ex_exception;
        ELSE
            OPEN check_org_id;
            FETCH check_org_id INTO checked_org_id;
                OPEN check_cause_name;
                FETCH check_cause_name INTO checked_cause_name;
                    IF check_org_id%FOUND AND check_cause_name%FOUND THEN
                        org_id_out := checked_org_id;
                        cause_name_out := checked_cause_name;

                        INSERT INTO VM_ORGCAUSE
                        VALUES (
                            org_id_out,
                            cause_name_out
                        );
                        COMMIT;

                        DBMS_OUTPUT.PUT_LINE('Organization cause added with organization ID: ' || org_id_out || ' and cause name: ' || cause_name_out);
                    ELSIF check_org_id%NOTFOUND AND check_cause_name%NOTFOUND THEN
                        ex_error_msg := 'Organization ID "' || p_org_id || '" and cause name "' || p_cause_name || '" not found!';
                        RAISE ex_exception;
                    ELSIF check_org_id%NOTFOUND THEN
                        ex_error_msg := 'Organization ID "' || p_org_id || '" not found!';
                        RAISE ex_exception;
                    ELSIF check_cause_name%NOTFOUND THEN
                        ex_error_msg := 'Cause name "' || p_cause_name || '" not found!';
                        RAISE ex_exception;
                    ELSE
                        ex_error_msg := 'An error occured!';
                        RAISE ex_exception;
                    END IF;
                CLOSE check_cause_name;
            CLOSE check_org_id;
        END IF;

        EXCEPTION
            WHEN ex_exception THEN
                DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                ROLLBACK;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occured inserting new organization cause!');
                dbms_output.put_line('Error code is: ' || sqlcode);
                dbms_output.put_line('Error message is: ' || sqlerrm);
                ROLLBACK;
    END;