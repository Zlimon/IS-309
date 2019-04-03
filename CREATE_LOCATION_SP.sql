create or replace procedure CREATE_LOCATION_SP (
    p_location_id                       OUT INTEGER,    -- an output parameter
    p_location_country                  IN  VARCHAR,    -- must not be NULL
    p_location_postal_code              IN  VARCHAR,    -- must not be NULL
    p_location_street1                  IN  VARCHAR,
    p_location_street2                  IN  VARCHAR,
    p_location_city                     IN  VARCHAR,
    p_location_administrative_region    IN  VARCHAR
)
IS
    ex_exception    EXCEPTION;
    ex_error_msg    VARCHAR(100);
    location_count  INTEGER;

    BEGIN
        IF p_location_country IS NULL THEN
            ex_error_msg := 'Missing country! Can not be NULL';
            RAISE ex_exception;
        END IF;

        IF p_location_postal_code IS NULL THEN
            ex_error_msg := 'Missing postal code! Can not be NULL';
            RAISE ex_exception;
        END IF;

        SELECT COUNT(*) INTO location_count
        FROM VM_LOCATION
        WHERE location_country = p_location_country AND location_postal_code = p_location_postal_code AND location_street_1 = p_location_street1;

        IF location_count >= 1 THEN
            SELECT LOCATION_ID
            INTO p_location_id
            FROM VM_LOCATION
            WHERE location_country = p_location_country AND location_postal_code = p_location_postal_code AND location_street_1 = p_location_street1;

            ex_error_msg := 'This location already exist. Location ID: ' || p_location_id;
            RAISE ex_exception;
        ELSE
            p_location_id := LOCATION_ID_SEQ.NEXTVAL;

            INSERT INTO VM_LOCATION(LOCATION_ID, LOCATION_COUNTRY, LOCATION_POSTAL_CODE, LOCATION_STREET_1, LOCATION_STREET_2, LOCATION_CITY, LOCATION_ADMINISTRATIVE_REGION)
            VALUES (p_location_id, p_location_country, p_location_postal_code, p_location_street1, p_location_street2, p_location_city, p_location_administrative_region);
            COMMIT;

            DBMS_OUTPUT.PUT_LINE('Location added with ID: ' || p_location_id);
        END IF;

        EXCEPTION
            WHEN ex_exception THEN
                DBMS_OUTPUT.PUT_LINE (ex_error_msg);
                ROLLBACK;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occured inserting new location!');
                ROLLBACK;
    END;
