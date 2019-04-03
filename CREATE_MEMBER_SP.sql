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
    p_location_id   NUMBER;

    BEGIN
        IF p_member_password IS NULL THEN
            ex_error_msg := 'Missing password! Can not be NULL';
            RAISE ex_exception;
        END IF;

        p_person_id := PERSON_ID_SEQ.NEXTVAL;

        CREATE_PERSON_SP(p_person_id, p_person_email, p_person_given_name, p_person_surname, p_person_phone);
        CREATE_LOCATION_SP(p_location_id, p_location_country, p_location_postal_code, p_location_street1, p_location_street2, p_location_city, p_location_administrative_region);

        INSERT INTO VM_MEMBER VALUES (PERSON_ID_SEQ.CURRVAL, p_member_password, LOCATION_ID_SEQ.CURRVAL);
        COMMIT;

        DBMS_OUTPUT.PUT_LINE('Member added with ID: ' || p_person_ID);

        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occured inserting new member!');
                ROLLBACK;
    END;