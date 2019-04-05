create or replace procedure CREATE_MEMBER_SP (
    p_person_ID                         OUT INTEGER,    -- an output parameter
    p_person_email                      IN  VARCHAR,    -- passed through to CREATE_PERSON_SP
    P_person_given_name                 IN  VARCHAR,    -- passed through to CREATE_PERSON_SP
    p_person_surname                    IN  VARCHAR,    -- passed through to CREATE_PERSON_SP
    p_person_phone                      IN  VARCHAR,    -- passed through to CREATE_PERSON_SP
    p_location_country                  IN  VARCHAR,    -- passed through to CREATE_LOCATION_SP
    p_location_postal_code              IN  VARCHAR,    -- passed through to CREATE_LOCATION_SP
    p_location_street1                  IN  VARCHAR,    -- passed through to CREATE_LOCATION_SP
    p_location_street2                  IN  VARCHAR,    -- passed through to CREATE_LOCATION_SP
    p_location_city                     IN  VARCHAR,    -- passed through to CREATE_LOCATION_SP
    p_location_administrative_region    IN  VARCHAR,    -- passed through to CREATE_LOCATION_SP
    p_member_password                   IN  VARCHAR     -- NOT NULL
)
IS
    ex_exception    EXCEPTION;
    ex_error_msg    VARCHAR(100);
    person_id_out   NUMBER;
    location_id_out NUMBER;

    BEGIN
        IF p_member_password IS NULL THEN
            ex_error_msg := 'Missing password! Can not be NULL';
            RAISE ex_exception;
        ELSE
            CREATE_PERSON_SP (
                person_id_out,
                p_person_email,
                p_person_given_name,
                p_person_surname,
                p_person_phone
            );

            CREATE_LOCATION_SP (
                location_id_out,
                p_location_country,
                p_location_postal_code,
                p_location_street1,
                p_location_street2,
                p_location_city,
                p_location_administrative_region
            );

            INSERT INTO VM_MEMBER
            VALUES (
                person_id_out,
                p_member_password,
                location_id_out
            );
            COMMIT;

            DBMS_OUTPUT.PUT_LINE('Member added with person ID: ' || person_id_out || ' and location ID: ' || location_id_out);
        END IF;

        EXCEPTION
            WHEN ex_exception THEN
                DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                ROLLBACK;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occured inserting new member!');
                dbms_output.put_line('Error code: ' || sqlcode);
                dbms_output.put_line('Error message: ' || sqlerrm);
                ROLLBACK;
    END;
