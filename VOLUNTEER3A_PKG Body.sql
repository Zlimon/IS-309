create or replace package body volunteer3a_pkg
is
    procedure CREATE_LOCATION_PP (
      p_location_id                     OUT INTEGER,        -- an output parameter
      p_location_country                IN  VARCHAR,        -- must not be NULL
      p_location_postal_code            IN  VARCHAR,        -- must not be NULL
      p_location_street1                IN  VARCHAR,
      p_location_street2                IN  VARCHAR,
      p_location_city                   IN  VARCHAR,
      p_location_administrative_region  IN  VARCHAR
    )
    IS
        ex_exception        EXCEPTION;
        ex_error_msg        VARCHAR (200);
        checked_location_id NUMBER;

        CURSOR check_location_duplicate IS
            SELECT LOCATION_ID FROM VM_LOCATION WHERE location_country = p_location_country AND location_postal_code = p_location_postal_code AND location_street_1 = p_location_street1;

        BEGIN
            IF p_location_country IS NULL THEN
                ex_error_msg := 'Missing country! Can not be NULL';
                RAISE ex_exception;
            ELSIF p_location_postal_code IS NULL THEN
                ex_error_msg := 'Missing postal code! Can not be NULL';
                RAISE ex_exception;
            ELSE
                OPEN check_location_duplicate;
                FETCH check_location_duplicate INTO checked_location_id;
                    IF check_location_duplicate%FOUND THEN
                        p_location_id := checked_location_id;
                        RAISE DUP_VAL_ON_INDEX;
                    ELSE
                        p_location_id := LOCATION_ID_SEQ.NEXTVAL;

                        INSERT INTO VM_LOCATION
                        VALUES (
                            p_location_id,
                            p_location_country,
                            p_location_postal_code,
                            p_location_street1,
                            p_location_street2,
                            p_location_city,
                            p_location_administrative_region,
                            NULL,
                            NULL
                        );
                        COMMIT;

                        DBMS_OUTPUT.PUT_LINE('Location added with ID: ' || p_location_id);
                    END IF;
                CLOSE check_location_duplicate;
            END IF;

            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    DBMS_OUTPUT.PUT_LINE('This location already exists! Location ID: ' || p_location_id);
                    ROLLBACK;
                WHEN ex_exception THEN
                    DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                    ROLLBACK;
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('An error occured inserting new location!');
                    dbms_output.put_line('Error code: ' || sqlcode);
                    dbms_output.put_line('Error message: ' || sqlerrm);
                    ROLLBACK;
        END CREATE_LOCATION_PP;

    procedure CREATE_PERSON_PP (
        p_person_ID             OUT INTEGER,     -- an output parameter
        p_person_email          IN  VARCHAR,     -- Must be unique, not null
        P_person_given_name     IN  VARCHAR,     -- NOT NULL, if email is unique (new)
        p_person_surname        IN  VARCHAR,     -- NOT NULL, if email is unique (new)
        p_person_phone          IN  VARCHAR
    )
    IS
        ex_exception        EXCEPTION;
        ex_error_msg        VARCHAR (200);
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
        END CREATE_PERSON_PP;
end volunteer3a_pkg;