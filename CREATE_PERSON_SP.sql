create or replace procedure CREATE_PERSON_SP (
    p_person_ID             OUT INTEGER,    -- an output parameter
    p_person_email          IN  VARCHAR,    -- Must be unique, not null
    P_person_given_name     IN  VARCHAR,    -- NOT NULL, if email is unique (new)
    p_person_surname        IN  VARCHAR,    -- NOT NULL, if email is unique (new)
    p_person_phone          IN  VARCHAR
)
IS
    ex_exception        EXCEPTION;
    ex_error_msg        VARCHAR(200);
    checked_person_id   NUMBER;

    CURSOR check_person_email IS
        SELECT PERSON_ID FROM VM_PERSON WHERE PERSON_EMAIL = p_person_email;

    BEGIN
        IF p_person_email IS NULL THEN
            ex_error_msg := 'Missing email address! Can not be NULL';
            RAISE ex_exception;
        ELSIF p_person_given_name IS NULL AND p_person_surname IS NULL THEN
            OPEN check_person_email;
            FETCH check_person_email INTO checked_person_id;
                IF check_person_email%FOUND THEN
                    p_person_id := checked_person_id;
                    RAISE DUP_VAL_ON_INDEX;
                ELSE
                    ex_error_msg := 'Email "' || p_person_email || '" is not in use!';
                    RAISE ex_exception;
                END IF;
            CLOSE check_person_email;
        ELSE
            IF p_person_given_name IS NULL THEN
                ex_error_msg := 'Missing name! Can not be NULL';
                RAISE ex_exception;
            ELSIF p_person_surname IS NULL THEN
                ex_error_msg := 'Missing surname! Can not be NULL';
                RAISE ex_exception;
            ELSE
                OPEN check_person_email;
                FETCH check_person_email INTO checked_person_id;
                    IF check_person_email%FOUND THEN
                        p_person_id := checked_person_id;
                        RAISE DUP_VAL_ON_INDEX;
                    ELSE
                        p_person_ID := PERSON_ID_SEQ.NEXTVAL;

                        INSERT INTO VM_PERSON
                        VALUES (
                            p_person_ID,
                            p_person_email,
                            p_person_given_name,
                            p_person_surname,
                            p_person_phone
                        );
                        COMMIT;

                        DBMS_OUTPUT.PUT_LINE('Person added with ID: ' || p_person_ID);
                    END IF;
                CLOSE check_person_email;
            END IF;
        END IF;

        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                DBMS_OUTPUT.PUT_LINE('This email is already in use! Person ID: ' || p_person_id);
                ROLLBACK;
            WHEN ex_exception THEN
                DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                ROLLBACK;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occured inserting new person!');
                dbms_output.put_line('Error code: ' || sqlcode);
                dbms_output.put_line('Error message: ' || sqlerrm);
                ROLLBACK;
    END;
