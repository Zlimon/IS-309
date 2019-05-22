procedure CREATE_OPPORTUNITY_SP (
    p_opp_id                         OUT INTEGER,   -- output parameter
    p_org_id                         IN  INTEGER,   -- NOT NULL
    p_opp_title                      IN  VARCHAR,   -- NOT NULL
    p_opp_description                IN  LONG,       
    p_opp_create_date                IN  DATE,      -- If NULL, use SYSDATE
    p_opp_max_volunteers             IN  INTEGER,   -- If provided, must be > 0
    p_opp_min_volunteer_age          IN  INTEGER,   -- If provided, must be between 0 and 125
    p_opp_start_date                 IN  DATE,
    p_opp_start_time                 IN  CHAR,       
    p_opp_end_date                   IN  DATE,
    p_opp_end_time                   IN  CHAR,
    p_opp_status                     IN  VARCHAR,   -- If provided, must conform to domain
    p_opp_great_for                  IN  VARCHAR,   -- If provided, must conform to domain
    p_location_country               IN  VARCHAR,   -- passed to CREATE_LOCATION_SP
    p_location_postal_code           IN  VARCHAR,   -- passed to CREATE_LOCATION_SP
    p_location_street1               IN  VARCHAR,   -- passed to CREATE_LOCATION_SP
    p_location_street2               IN  VARCHAR,   -- passed to CREATE_LOCATION_SP
    p_location_city                  IN  VARCHAR,   -- passed to CREATE_LOCATION_SP
    p_location_administrative_region IN  VARCHAR,   -- passed to CREATE_LOCATION_SP
    p_person_email                   IN  VARCHAR,   -- passed to CREATE_PERSON_SP
    P_person_given_name              IN  VARCHAR,   -- passed to CREATE_PERSON_SP
    p_person_surname                 IN  VARCHAR,   -- passed to CREATE_PERSON_SP
    p_person_phone                   IN  VARCHAR    -- passed to CREATE_PERSON_SP    
)
IS
    ex_exception        EXCEPTION;
    ex_error_msg        VARCHAR (200);
    org_id_out          NUMBER;
    current_create_date DATE;
    location_id_out     NUMBER;
    person_id_out       NUMBER;

    CURSOR check_org_id IS
        SELECT ORGANIZATION_ID FROM VM_ORGANIZATION WHERE ORGANIZATION_ID = p_org_id;

    BEGIN
        IF p_opp_create_date IS NULL THEN
            current_create_date := SYSDATE;
        ELSE
            current_create_date := p_opp_create_date;
        END IF;

        IF p_org_id IS NULL THEN
            ex_error_msg := 'Missing organization ID! Can not be NULL';
            RAISE ex_exception;
        ELSIF p_opp_title IS NULL THEN
            ex_error_msg := 'Missing opportunity title! Can not be NULL';
            RAISE ex_exception;
        ELSIF p_opp_max_volunteers <= 0 THEN
            ex_error_msg := 'Max volunteers must be higher than 0!';
            RAISE ex_exception;
        ELSIF p_opp_min_volunteer_age < 0 AND p_opp_min_volunteer_age > 125 THEN
            ex_error_msg := 'Volunteer age must be between 0 and 125!';
            RAISE ex_exception;
        ELSE
            OPEN check_org_id;
            FETCH check_org_id INTO org_id_out;
                IF check_org_id%FOUND THEN
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

                    p_opp_id := OPPORTUNITY_ID_SEQ.NEXTVAL;

                    INSERT INTO VM_OPPORTUNITY
                    VALUES (
                        p_opp_id,
                        p_opp_title,
                        p_opp_description,
                        current_create_date,
                        p_opp_max_volunteers,
                        p_opp_min_volunteer_age,
                        p_opp_start_date,
                        p_opp_start_time,
                        p_opp_end_date,
                        p_opp_end_time,
                        p_opp_status,
                        p_opp_great_for,
                        location_id_out,
                        p_org_id,
                        person_id_out
                    );
                    COMMIT;

                    DBMS_OUTPUT.PUT_LINE('Opportunity added with ID: ' || p_opp_id);
                ELSE
                    ex_error_msg := 'Organization ID: ' || p_org_id || ' not found!';
                    RAISE ex_exception;
                END IF;
            CLOSE check_org_id;
        END IF;

        EXCEPTION
            WHEN ex_exception THEN
                DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                ROLLBACK;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occured inserting new opportunity!');
                dbms_output.put_line('Error code: ' || sqlcode);
                dbms_output.put_line('Error message: ' || sqlerrm);
                ROLLBACK;
    END;