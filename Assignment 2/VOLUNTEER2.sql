procedure CREATE_LOCATION_SP (
    p_location_id                    OUT INTEGER,    -- an output parameter
    p_location_country               IN  VARCHAR,    -- must not be NULL
    p_location_postal_code           IN  VARCHAR,    -- must not be NULL
    p_location_street1               IN  VARCHAR,
    p_location_street2               IN  VARCHAR,
    p_location_city                  IN  VARCHAR,
    p_location_administrative_region IN  VARCHAR
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
    END;

procedure CREATE_PERSON_SP (
    p_person_ID             OUT INTEGER,    -- an output parameter
    p_person_email          IN  VARCHAR,    -- Must be unique, not null
    P_person_given_name     IN  VARCHAR,    -- NOT NULL, if email is unique (new)
    p_person_surname        IN  VARCHAR,    -- NOT NULL, if email is unique (new)
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
    END;

procedure CREATE_MEMBER_SP (
    p_person_ID                         OUT INTEGER,  -- an output parameter
    p_person_email                      IN  VARCHAR,  -- passed through to CREATE_PERSON_PP
    P_person_given_name                 IN  VARCHAR,  -- passed through to CREATE_PERSON_PP
    p_person_surname                    IN  VARCHAR,  -- passed through to CREATE_PERSON_PP
    p_person_phone                      IN  VARCHAR,  -- passed through to CREATE_PERSON_PP
    p_location_country                  IN  VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_postal_code              IN  VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_street1                  IN  VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_street2                  IN  VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_city                     IN  VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_administrative_region    IN  VARCHAR,  -- passed through to CREATE_LOCATION_SP
    p_member_password                   IN  VARCHAR   -- NOT NULL  
)
IS
    ex_exception    EXCEPTION;
    ex_error_msg    VARCHAR (200);
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

procedure CREATE_ORGANIZATION_SP (
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
    END;

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

procedure ADD_ORG_CAUSE_SP (
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

procedure ADD_OPP_SKILL_SP (
    p_opp_id        IN  INTEGER,    -- NOT NULL
    p_skill_name    IN  VARCHAR     -- NOT NULL
)
IS
    ex_exception        EXCEPTION;
    ex_error_msg        VARCHAR (200);
    checked_opp_id      NUMBER;
    checked_skill_name  VARCHAR (50);
    opp_id_out          NUMBER;
    skill_name_out      VARCHAR (50);

    CURSOR check_opp_id IS
        SELECT OPPORTUNITY_ID FROM VM_OPPORTUNITY WHERE OPPORTUNITY_ID = p_opp_id;

    CURSOR check_skill_name IS
        SELECT SKILL_NAME FROM VM_SKILL WHERE SKILL_NAME = p_skill_name;

    BEGIN
        IF p_opp_id IS NULL THEN
            ex_error_msg := 'Missing opportunity ID! Can not be NULL';
            RAISE ex_exception;
        ELSIF p_skill_name IS NULL THEN
            ex_error_msg := 'Missing skill name! Can not be NULL';
            RAISE ex_exception;
        ELSE
            OPEN check_opp_id;
            FETCH check_opp_id INTO checked_opp_id;
                OPEN check_skill_name;
                FETCH check_skill_name INTO checked_skill_name;
                    IF check_opp_id%FOUND AND check_skill_name%FOUND THEN
                        opp_id_out := checked_opp_id;
                        skill_name_out := checked_skill_name;

                        INSERT INTO VM_OPPSKILL
                        VALUES (
                            skill_name_out,
                            opp_id_out
                        );
                        COMMIT;

                        DBMS_OUTPUT.PUT_LINE('Opportunity skill added with opportunity ID: ' || opp_id_out || ' and skill name: ' || skill_name_out);
                    ELSIF check_opp_id%NOTFOUND AND check_skill_name%NOTFOUND THEN
                        ex_error_msg := 'Opportunity ID "' || p_opp_id || '" and skill name "' || p_skill_name || '" not found!';
                        RAISE ex_exception;
                    ELSIF check_opp_id%NOTFOUND THEN
                        ex_error_msg := 'Opportunity ID "' || p_opp_id || '" not found!';
                        RAISE ex_exception;
                    ELSIF check_skill_name%NOTFOUND THEN
                        ex_error_msg := 'Skill name "' || p_skill_name || '" not found!';
                        RAISE ex_exception;
                    ELSE
                        ex_error_msg := 'An error occured!';
                        RAISE ex_exception;
                    END IF;
                CLOSE check_skill_name;
            CLOSE check_opp_id;
        END IF;

        EXCEPTION
            WHEN ex_exception THEN
                DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                ROLLBACK;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occured inserting new opportunity skill!');
                dbms_output.put_line('Error code: ' || sqlcode);
                dbms_output.put_line('Error message: ' || sqlerrm);
                ROLLBACK;
    END;

procedure ADD_MEMBER_SKILL_SP (
    p_person_id     IN  INTEGER,    -- NOT NULL
    p_skill_name    IN  VARCHAR     -- NOT NULL
)
IS
    ex_exception        EXCEPTION;
    ex_error_msg        VARCHAR (200);
    checked_member_id   NUMBER;
    checked_skill_name  VARCHAR (50);
    member_id_out       NUMBER;
    skill_name_out      VARCHAR (50);

    CURSOR check_member_id IS
        SELECT PERSON_ID FROM VM_MEMBER WHERE PERSON_ID = p_person_id;

    CURSOR check_skill_name IS
        SELECT SKILL_NAME FROM VM_SKILL WHERE SKILL_NAME = p_skill_name;

    BEGIN
        IF p_person_id IS NULL THEN
            ex_error_msg := 'Missing person ID! Can not be NULL';
            RAISE ex_exception;
        ELSIF p_skill_name IS NULL THEN
            ex_error_msg := 'Missing skill name! Can not be NULL';
            RAISE ex_exception;
        ELSE
            OPEN check_member_id;
            FETCH check_member_id INTO checked_member_id;
                OPEN check_skill_name;
                FETCH check_skill_name INTO checked_skill_name;
                    IF check_member_id%FOUND AND check_skill_name%FOUND THEN
                        member_id_out := checked_member_id;
                        skill_name_out := checked_skill_name;

                        INSERT INTO VM_MEMSKILL
                        VALUES (
                            member_id_out,
                            skill_name_out
                        );
                        COMMIT;

                        DBMS_OUTPUT.PUT_LINE('Member skill added with person ID: ' || member_id_out || ' and skill name: ' || skill_name_out);
                    ELSIF check_member_id%NOTFOUND AND check_skill_name%NOTFOUND THEN
                        ex_error_msg := 'Member ID "' || p_person_id || '" and skill name "' || p_skill_name || '" not found!';
                        RAISE ex_exception;
                    ELSIF check_member_id%NOTFOUND THEN
                        ex_error_msg := 'Member ID "' || p_person_id || '" not found!';
                        RAISE ex_exception;
                    ELSIF check_skill_name%NOTFOUND THEN
                        ex_error_msg := 'Skill name "' || p_skill_name || '" not found!';
                        RAISE ex_exception;
                    ELSE
                        ex_error_msg := 'An error occured!';
                        RAISE ex_exception;
                    END IF;
                CLOSE check_skill_name;
            CLOSE check_member_id;
        END IF;

        EXCEPTION
            WHEN ex_exception THEN
                DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                ROLLBACK;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occured inserting new member skill!');
                dbms_output.put_line('Error code: ' || sqlcode);
                dbms_output.put_line('Error message: ' || sqlerrm);
                ROLLBACK;
    END;