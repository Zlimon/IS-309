create or replace procedure CREATE_ORGANIZATION_SP (
    p_org_id                            OUT INTEGER,    -- output parameter
    p_org_name                          IN  VARCHAR,    -- NOT NULL
    p_org_mission                       IN  VARCHAR,    -- NOT NULL
    p_org_descrip                       IN  LONG,
    p_org_phone                         IN  VARCHAR,    -- NOT NULL
    p_org_type                          IN  VARCHAR,    -- must conform to domain, if it has a value
    p_org_creation_date                 IN  DATE,       -- IF NULL, use SYSDATE
    p_org_URL                           IN  VARCHAR,
    p_org_image_URL                     IN  VARCHAR,
    p_org_linkedin_URL                  IN  VARCHAR,
    p_org_facebook_URL                  IN  VARCHAR,
    p_org_twitter_URL                   IN  VARCHAR,
    p_location_country                  IN  VARCHAR,    -- passed to CREATE_LOCATION_SP
    p_location_postal_code              IN  VARCHAR,    -- passed to CREATE_LOCATION_SP
    p_location_street1                  IN  VARCHAR,    -- passed to CREATE_LOCATION_SP
    p_location_street2                  IN  VARCHAR,    -- passed to CREATE_LOCATION_SP
    p_location_city                     IN  VARCHAR,    -- passed to CREATE_LOCATION_SP
    p_location_administrative_region    IN  VARCHAR,    -- passed to CREATE_LOCATION_SP
    p_person_id                         OUT INTEGER,    -- an output parameter
    p_person_email                      IN  VARCHAR,    -- passed to CREATE_PERSON_SP
    P_person_given_name                 IN  VARCHAR,    -- passed to CREATE_PERSON_SP
    p_person_surname                    IN  VARCHAR,    -- passed to CREATE_PERSON_SP
    p_person_phone                      IN  VARCHAR     -- passed to CREATE_PERSON_SP
)
IS
    ex_exception            EXCEPTION;
    ex_error_msg            VARCHAR (200);
    current_creation_date   DATE;
    location_id_out         NUMBER;
    person_id_out           NUMBER;

    BEGIN
        IF p_org_creation_date IS NULL THEN
            current_creation_date := SYSDATE;
        ELSE
            current_creation_date := p_org_creation_date;
        END IF;

        IF p_org_name IS NULL THEN
            ex_error_msg := 'Missing organization name! Can not be NULL';
            RAISE ex_exception;
        ELSIF p_org_mission IS NULL THEN
            ex_error_msg := 'Missing organization mission! Can not be NULL';
            RAISE ex_exception;
        ELSIF p_org_phone IS NULL THEN
            ex_error_msg := 'Missing organization phone! Can not be NULL';
            RAISE ex_exception;
        ELSE
            CREATE_LOCATION_SP (
                location_id_out,
                p_location_country,
                p_location_postal_code,
                p_location_street1,
                p_location_street2,
                p_location_city,
                p_location_administrative_region
            );

            CREATE_PERSON_SP (
                person_id_out,
                p_person_email,
                P_person_given_name,
                p_person_surname,
                p_person_phone
            );

            p_org_id := ORGANIZATION_ID_SEQ.NEXTVAL;

            INSERT INTO VM_ORGANIZATION
            VALUES (
                p_org_id,
                p_org_name,
                p_org_mission,
                p_org_descrip,
                p_org_phone,
                p_org_type,
                create or replace procedure CREATE_ORGANIZATION_SP (
    p_org_id                            OUT INTEGER,    -- output parameter
    p_org_name                          IN  VARCHAR,    -- NOT NULL
    p_org_mission                       IN  VARCHAR,    -- NOT NULL
    p_org_descrip                       IN  LONG,
    p_org_phone                         IN  VARCHAR,    -- NOT NULL
    p_org_type                          IN  VARCHAR,    -- must conform to domain, if it has a value
    p_org_creation_date                 IN  DATE,       -- IF NULL, use SYSDATE
    p_org_URL                           IN  VARCHAR,
    p_org_image_URL                     IN  VARCHAR,
    p_org_linkedin_URL                  IN  VARCHAR,
    p_org_facebook_URL                  IN  VARCHAR,
    p_org_twitter_URL                   IN  VARCHAR,
    p_location_country                  IN  VARCHAR,    -- passed to CREATE_LOCATION_SP
    p_location_postal_code              IN  VARCHAR,    -- passed to CREATE_LOCATION_SP
    p_location_street1                  IN  VARCHAR,    -- passed to CREATE_LOCATION_SP
    p_location_street2                  IN  VARCHAR,    -- passed to CREATE_LOCATION_SP
    p_location_city                     IN  VARCHAR,    -- passed to CREATE_LOCATION_SP
    p_location_administrative_region    IN  VARCHAR,    -- passed to CREATE_LOCATION_SP
    p_person_id                         OUT INTEGER,    -- an output parameter
    p_person_email                      IN  VARCHAR,    -- passed to CREATE_PERSON_SP
    P_person_given_name                 IN  VARCHAR,    -- passed to CREATE_PERSON_SP
    p_person_surname                    IN  VARCHAR,    -- passed to CREATE_PERSON_SP
    p_person_phone                      IN  VARCHAR     -- passed to CREATE_PERSON_SP
)
IS
    ex_exception            EXCEPTION;
    ex_error_msg            VARCHAR (200);
    current_creation_date   DATE;
    location_id_out         NUMBER;
    person_id_out           NUMBER;

    BEGIN
        IF p_org_creation_date IS NULL THEN
            current_creation_date := SYSDATE;
        ELSE
            current_creation_date := p_org_creation_date;
        END IF;

        IF p_org_name IS NULL THEN
            ex_error_msg := 'Missing organization name! Can not be NULL';
            RAISE ex_exception;
        ELSIF p_org_mission IS NULL THEN
            ex_error_msg := 'Missing organization mission! Can not be NULL';
            RAISE ex_exception;
        ELSIF p_org_phone IS NULL THEN
            ex_error_msg := 'Missing organization phone! Can not be NULL';
            RAISE ex_exception;
        ELSE
            CREATE_LOCATION_SP (
                location_id_out,
                p_location_country,
                p_location_postal_code,
                p_location_street1,
                p_location_street2,
                p_location_city,
                p_location_administrative_region
            );

            CREATE_PERSON_SP (
                person_id_out,
                p_person_email,
                P_person_given_name,
                p_person_surname,
                p_person_phone
            );

            p_org_id := ORGANIZATION_ID_SEQ.NEXTVAL;

            INSERT INTO VM_ORGANIZATION
            VALUES (
                p_org_id,
                p_org_name,
                p_org_mission,
                p_org_descrip,
                p_org_phone,
                p_org_type,
                current_creation_date,
                p_org_URL,
                p_org_image_URL,
                p_org_linkedin_URL,
                p_org_facebook_URL,
                p_org_twitter_URL,
                location_id_out,
                person_id_out
            );
            COMMIT;

            DBMS_OUTPUT.PUT_LINE('Organization added with organization ID: ' || p_org_id || ', person ID: ' || person_id_out || ' and location ID: ' || location_id_out);
        END IF;

        EXCEPTION
            WHEN ex_exception THEN
                DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                ROLLBACK;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occured inserting new organization!');
                dbms_output.put_line('Error code: ' || sqlcode);
                dbms_output.put_line('Error message: ' || sqlerrm);
                ROLLBACK;
    END;,
                p_org_URL,
                p_org_image_URL,
                p_org_linkedin_URL,
                p_org_facebook_URL,
                p_org_twitter_URL,
                location_id_out,
                person_id_out
            );
            COMMIT;

            DBMS_OUTPUT.PUT_LINE('Organization added with organization ID: ' || p_org_id || ', person ID: ' || person_id_out || ' and location ID: ' || location_id_out);
        END IF;

        EXCEPTION
            WHEN ex_exception THEN
                DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                ROLLBACK;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occured inserting new organization!');
                dbms_output.put_line('Error code: ' || sqlcode);
                dbms_output.put_line('Error message: ' || sqlerrm);
                ROLLBACK;
    END;
