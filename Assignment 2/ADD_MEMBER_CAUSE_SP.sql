procedure ADD_MEMBER_CAUSE_SP (
    p_person_id     IN  INTEGER,    -- NOT NULL
    p_cause_name    IN  VARCHAR     -- NOT NULL
)
IS
    ex_exception        EXCEPTION;
    ex_error_msg        VARCHAR (200);
    checked_member_id   NUMBER;
    checked_cause_name  VARCHAR (50);
    member_id_out       NUMBER;
    cause_name_out      VARCHAR (50);

    CURSOR check_member_id IS
        SELECT PERSON_ID FROM VM_MEMBER WHERE PERSON_ID = p_person_id;

    CURSOR check_cause_name IS
        SELECT CAUSE_NAME FROM VM_CAUSE WHERE CAUSE_NAME = p_cause_name;

    BEGIN
        IF p_person_id IS NULL THEN
            ex_error_msg := 'Missing member id! Can not be NULL';
            RAISE ex_exception;
        ELSIF p_cause_name IS NULL THEN
            ex_error_msg := 'Missing cause name! Can not be NULL';
            RAISE ex_exception;
        ELSE
            OPEN check_member_id;
            FETCH check_member_id INTO checked_member_id;
                OPEN check_cause_name;
                FETCH check_cause_name INTO checked_cause_name;
                    IF check_member_id%FOUND AND check_cause_name%FOUND THEN
                        member_id_out := checked_member_id;
                        cause_name_out := checked_cause_name;

                        INSERT INTO VM_MEMCAUSE
                        VALUES (
                            cause_name_out,
                            member_id_out
                        );
                        COMMIT;

                        DBMS_OUTPUT.PUT_LINE('Member cause added with person ID: ' || member_id_out || ' and cause name: ' || cause_name_out);
                    ELSIF check_member_id%NOTFOUND AND check_cause_name%NOTFOUND THEN
                        ex_error_msg := 'Member ID "' || p_person_id || '" and cause name "' || p_cause_name || '" not found!';
                        RAISE ex_exception;
                    ELSIF check_member_id%NOTFOUND THEN
                        ex_error_msg := 'Member ID "' || p_person_id || '" not found!';
                        RAISE ex_exception;
                    ELSIF check_cause_name%NOTFOUND THEN
                        ex_error_msg := 'Cause name "' || p_cause_name || '" not found!';
                        RAISE ex_exception;
                    ELSE
                        ex_error_msg := 'An error occured!';
                        RAISE ex_exception;
                    END IF;
                CLOSE check_cause_name;
            CLOSE check_member_id;
        END IF;

        EXCEPTION
            WHEN ex_exception THEN
                DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                ROLLBACK;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occured inserting new member cause!');
                dbms_output.put_line('Error code: ' || sqlcode);
                dbms_output.put_line('Error message: ' || sqlerrm);
                ROLLBACK;
    END;