create or replace package volunteer3b_pkg
IS
procedure CREATE_LOCATION_PP (
    p_location_id         OUT INTEGER,        -- an output parameter
    p_location_country    IN  VARCHAR,        -- must not be NULL
    p_location_postal_code IN VARCHAR,        -- must not be NULL
    p_location_street1    IN  VARCHAR,
    p_location_street2    IN  VARCHAR,
    p_location_city       IN  VARCHAR,
    p_location_administrative_region IN VARCHAR
);
procedure CREATE_PERSON_PP (
    p_person_ID             OUT INTEGER,     -- an output parameter
    p_person_email          IN VARCHAR,  -- Must be unique, not null
    P_person_given_name     IN VARCHAR,  -- NOT NULL, if email is unique (new)
    p_person_surname        IN VARCHAR,  -- NOT NULL, if email is unique (new)
    p_person_phone          IN VARCHAR
);
procedure CREATE_MEMBER_PP (
    p_person_ID             OUT INTEGER,     -- an output parameter
    p_person_email          IN  VARCHAR,  -- passed through to CREATE_PERSON_PP
    P_person_given_name     IN  VARCHAR,  -- passed through to CREATE_PERSON_PP
    p_person_surname        IN  VARCHAR,  -- passed through to CREATE_PERSON_PP
    p_person_phone          IN  VARCHAR,  -- passed through to CREATE_PERSON_PP
    p_location_country      IN  VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_postal_code  IN  VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_street1      IN  VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_street2      IN  VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_city         IN  VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_administrative_region IN VARCHAR, -- passed through to CREATE_LOCATION_SP
    p_member_password       IN  VARCHAR   -- NOT NULL  
);
procedure CREATE_ORGANIZATION_PP (
    p_org_id                    OUT INTEGER,    -- output parameter
    p_org_name                  IN VARCHAR,     -- NOT NULL
    p_org_mission               IN VARCHAR,     -- NOT NULL
    p_org_descrip               IN LONG,            
    p_org_phone                 IN VARCHAR,     -- NOT NULL
    p_org_type                  IN VARCHAR,     -- must conform to domain, if it has a value
    p_org_creation_date         IN DATE,            -- IF NULL, use SYSDATE
    p_org_URL                   IN VARCHAR,
    p_org_image_URL             IN VARCHAR,
    p_org_linkedin_URL          IN VARCHAR,
    p_org_facebook_URL          IN VARCHAR,
    p_org_twitter_URL           IN VARCHAR,
    p_location_country          IN  VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_postal_code      IN  VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street1          IN  VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street2          IN  VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_city             IN  VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_administrative_region IN VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_person_email              IN VARCHAR,  -- passed to CREATE_PERSON_SP
    P_person_given_name         IN VARCHAR,  -- passed to CREATE_PERSON_SP
    p_person_surname            IN VARCHAR,  -- passed to CREATE_PERSON_SP
    p_person_phone              IN VARCHAR   -- passed to CREATE_PERSON_SP
);
procedure CREATE_OPPORTUNITY_PP (
    p_opp_id                    OUT INTEGER,        -- output parameter
    p_org_id                    IN  INTEGER,        -- NOT NULL
    p_opp_title                 IN  VARCHAR,   -- NOT NULL
    p_opp_description           IN  LONG,       
    p_opp_create_date           IN  DATE,       -- If NULL, use SYSDATE
    p_opp_max_volunteers        IN  INTEGER,    -- If provided, must be > 0
    p_opp_min_volunteer_age     IN  INTEGER,    -- If provided, must be between 0 and 125
    p_opp_start_date            IN  DATE,
    p_opp_start_time            IN  CHAR,       
    p_opp_end_date              IN  DATE,
    p_opp_end_time              IN  CHAR,
    p_opp_status                IN  VARCHAR,    -- If provided, must conform to domain
    p_opp_great_for             IN  VARCHAR,    -- If provided, must conform to domain
    p_location_country          IN  VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_postal_code      IN  VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street1          IN  VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street2          IN  VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_city             IN  VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_administrative_region IN VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_person_email              IN VARCHAR,   -- passed to CREATE_PERSON_SP
    P_person_given_name         IN VARCHAR,   -- passed to CREATE_PERSON_SP
    p_person_surname            IN VARCHAR,   -- passed to CREATE_PERSON_SP
    p_person_phone              IN VARCHAR    -- passed to CREATE_PERSON_SP    
);
procedure ADD_ORG_CAUSE_PP (
    p_org_id            IN  INTEGER,    -- NOT NULL
    p_cause_name        IN  VARCHAR -- NOT NULL
);
procedure ADD_MEMBER_CAUSE_PP (
    p_person_id     IN  INTEGER,    -- NOT NULL
    p_cause_name    IN  VARCHAR     -- NOT NULL
);
procedure ADD_OPP_SKILL_PP (
    p_opp_id        IN  INTEGER,    -- NOT NULL
    p_skill_name    IN  VARCHAR     -- NOT NULL
);
procedure ADD_MEMBER_SKILL_PP (
    p_person_id     IN  INTEGER,    -- NOT NULL
    p_skill_name    IN  VARCHAR -- NOT NULL
);
/*
CREATE_COMMITMENT_PP.  Allow a member to sign up for a volunteer opportunity.  
Given a member email, an opportunity id, a commitment start date and a commitment 
end date (both optional), create a new record in the VM_COMMITMENT table.  If 
the member has already committed to this opportunity, then either (a) create a new 
commitment (if the new window between the start and end dates does not overlap
the existing commitment); or (b) update the dates of the existing commitment so that 
the new window is the union of the new and old windows.   For example, if the member
has already committed to an opportunity between 15-MAR-2019 and 18-MAR-2019 and then
commits again for 17-MAR-2019 to 20-MAR-2019, then update the existing commitment
so that the commitment is for 15-MAR-2019 to 20-MAR-2019.  If the current start 
or end dates are NULL, then they should be updated with the new start and end dates.

The procedure should also check that the start and end dates provided are within
the start and end dates of the opportunity.  If the opportunity has NULL values for 
the start and end dates, then any commitment dates are valid.

The new commitment status should be set to "inquiry".

If a new commitment is created, the commitment_id value should be returned using 
the p_commitment_id output parameter.  If an existing commitment is found and updated,
the p_commitment_id value should be set to the commitment id of this commitment. 
Otherwise, p_commitment_id should be set to NULL.

PARAMETERS:  Described below
RETURNS:  a new or existing commitment_id, using the p_commitment_id output parameter
ERROR MESSAGES:
  Error text:  "Missing mandatory value for parameter (x).  No Commitment added." 
  Error meaning: A mandatory value is missing.  Here, y = 'CREATE_COMMITMENT_PP'
  Error effect: Because a mandatory value is not provided, no data are 
    inserted into the VM_COMMITMENT table.  The p_commitment_id value returned is 
    NULL.

  Error text:  "Member (x) not found.  No commitment added."
  Error meaning: A member with the given email address was not found in the 
    VM_MEMBER and VM_PERSON tables.  
  Error effect:  Because there is no member for this commitment, no row is added
    to the VM_COMMITMENT table.  The p_commitment_id parameter returns a NULL value.
    
  Error text:  "Missing opportunity.  No commitment added."
  Error meaning: A opportunity with the given id was not found in the 
    VM_OPPORTUNITY tables.  
  Error effect:  Because there is no opportunity for this commitment, no row is added
    to the VM_COMMITMENT table.  The p_commitment_id parameter returns a NULL value.  
    
  Error text:  "Opportunity is inactive."
  Error meaning:  The commitment dates lie outside of the start and end date window 
    of the opportunity.
  Error effect:  No row is added to the VM)COMMITMENT table.  The p_commitment_id 
    parameter returns a NULL value.
*/
procedure CREATE_COMMITMENT_PP (
    p_commitment_id     OUT INTEGER,    -- Output parameter
    p_member_email      IN  VARCHAR,    -- Not NULL
    p_opportunity_id    IN  VARCHAR,    -- Not NULL
    p_start_date        IN  DATE,       
    p_end_date          IN  DATE
    );

/*
RECORD_HOURS_PP.  Record the hours worked by a member on a particular 
opportunity on a particular day.  Given a member email, an opportunity id, and 
a date, create a new record in the VM_TIMETABLE table.  Only one record can be 
made on a given day for a given member and opportunity.

The TIMESHEET_CREATION_DATE is to be set to the current date (use Oracle's CURRENT_DATE function).

The TIMESHEET_STATUS value is to be set to 'pending'.

PARAMETERS:     Described below
RETURNS:        Nothing
ERROR MESSAGES: 
  Error text:  "Invalid number of hours for opportunity x. Must be
                a number between 1 and 24 hours. " 
  Error meaning: The number of ours violates the domain definition, or is missing
  Error effect: Because the number of hours is invalid, no timesheet record is
        created.
        
  Error text:  "Member (x) not found.  No hours added."
  Error meaning: A member with the given email address was not found in the 
    VM_MEMBER and VM_PERSON tables.  
  Error effect:  Because there is no member for this timesheet entry, no row is added
    to the VM_TIMESHEET table.  
    
  Error text:  "Missing opportunity.  No commitment added."
  Error meaning: A opportunity with the given id was not found in the 
    VM_OPPORTUNITY tables.  
  Error effect:  Because there is no opportunity for this timesheet entry, no row is added
    to the VM_TIMESHEET table.  
    
  Error text: "Missing work date for opportunity x."
  Error meaning:  The date provided for the opportunity is invalid or missing.
        
*/

procedure RECORD_HOURS_PP (
    p_member_email      IN  VARCHAR,    -- Not NULL
    p_opportunity_id    IN  VARCHAR,    -- NOT NULL
    p_hours             IN  NUMBER,     -- NOT NULL
    p_volunteer_date    IN  DATE        -- NOT NULL
);

/*
APPROVE_HOURS_PP.  Given a member email, an opportunity id, a volunteer date 
(optional), an approver email, and an approval status value, update the status 
and approver id of the existing record in VM_TIMESHEET.  If the date is NULL, 
update all records for this member and opportunity.  

PARAMETERS:     Described below
RETURNS:        Nothing
ERROR MESSAGES: 
  Error text:  "Missing mandatory value for parameter (x) in APPROVE_HOURS_PP." 
           x = a mandatory parameter that is NULL
  Error meaning: A mandatory parameter is NULL.  
  Error effect:  No changes are made to the VM_TIMESHEET table.  

  Error text:  "Member (x) not found."  
           x = email address
  Error meaning: The member with the given email address cannot be found in the system.  
  Error effect:  No changes are made to the VM_TIMESHEET table.  
  
  Error text:  "Approver (x) not found."  
           x = email address
  Error meaning: The member with the given email address cannot be found in the system.  
  Error effect:  No changes are made to the VM_TIMESHEET table.  
  
  Error text:  "Opportunity (x) not found."
           x = opportunity id
  Error meaning: The opportunity with the given id value cannot be found in the system.  
  Error effect:  No changes are made to the VM_TIMESHEET table.  
  
  Error text:  "Invalid value "x" for approval status."
           x = approval status
  Error meaning: The value for approval status is not included in the domain ("approved", "not approved", "pending").  
  Error effect:  No changes are made to the VM_TIMESHEET table.  

  Error text:  "Member x has no recorded hours on opportunity y on z."  
           x = member id; y = opportunity id; z = volunteer date
  Error meaning: There is no row in VM_TIMESHEET with this combination of member, opportunity, and volunteer date.  
  Error effect:  No changes are made to the VM_TIMESHEET table.  
  
*/

procedure APPROVE_HOURS_PP (
    p_member_email      IN VARCHAR,    -- Must not be NULL.
    p_approver_email    IN VARCHAR,    -- Must not be NULL.  Approver is a member.
    p_opportunity_id    IN VARCHAR,    -- Must not be NULL.
    p_volunteer_date    IN DATE,
    p_approval_status   IN VARCHAR    -- Must not be NULL.
);

/*
GET_MEMBER_HOURS_PF. Given a member email address, an opportunity ID, a start 
date and an end date, calculate the number of hours worked.  The start date and
end date can be NULL.  If both are NULL, then calculate the hours worked on this
opportunity for all dates.
PARAMETERS:     Described below
RETURNS:        Calculated hours, or NULL
ERROR MESSAGES: 
  Error text:  "Missing mandatory value for parameter (x) in GET_MEMBER_HOURS_PF." 
           x = a mandatory parameter that is NULL
  Error meaning: A mandatory parameter is NULL.  
  Error effect:  NULL value returned.  
  
  Error text:  "Member (x) not found."  
           x = email address
  Error meaning: The member with the given email address cannot be found in the system.  
  Error effect:  NULL value returned.  
  
  Error text:  "Opportunity (x) not found."
           x = opportunity id
  Error meaning: The opportunity with the given id value cannot be found in the system.  
  Error effect:  NULL value returned.
  
  Error text:  "End date (x) must be later than the start date (y)"
           x = the end date
           y = the start date
  Error meaning:  The start date of the range of dates can't be after the end date.
  Error effect:  NULL value returned.


*/
function GET_MEMBER_HOURS_PF (
    p_member_email      IN VARCHAR,         -- Must not be NULL.
    p_opportunity_ID    IN INTEGER,         -- Must not be NULL.
    p_start_date        IN DATE,
    p_end_date          IN DATE
) RETURN NUMBER;

/*
GET_MEMBER_HOURS_PF. Same name as the function above, but with different parameters.  
This is overloading.  Given a member email address, a start 
date and an end date, calculate the number of hours worked by opportunity. The 
function should display the opportunity title for each opportunity on which the 
member has volunteered in the given time range and the hours worked for each 
opportunity.  The start date and end date can be NULL.  If both are NULL, then 
display all opportunities on which the member has worked at any time.   The 
function returns the sum of all hours within the specified range.
PARAMETERS:     Described below
RETURNS:        total number of hours worked, or NULL
ERROR MESSAGES: 
  Error text:  "Missing mandatory value for parameter (x) in GET_MEMBER_HOURS_PF." 
           x = a mandatory parameter that is NULL
  Error meaning: A mandatory parameter is NULL.  
  Error effect:  NULL value returned.  
  
  Error text:  "Member (x) not found."  
           x = email address
  Error meaning: The member with the given email address cannot be found in the system.  
  Error effect:  NULL value returned.  
  
  Error text:  "End date (x) must be later than the start date (y)"
           x = the end date
           y = the start date
  Error meaning:  The start date of the range of dates can't be after the end date.
  Error effect:  NULL value returned.


*/
function GET_MEMBER_HOURS_PF (
    p_member_email      IN VARCHAR,         -- Must not be NULL.
    p_start_date        IN DATE,
    p_end_date          IN DATE
) RETURN NUMBER;

/* 
SEARCH_OPPORTUNITIES_PP.  Given a member email, list all opportunities that 
match one or more of that member’s causes or skills.  Rank the results according 
to how good the fit is.  For example, if an opportunity matches two causes and 
two skills, it is ranked higher than an opportunity that matches one cause and 
two skills.

PARAMETERS:     Described below
RETURNS:        nothing
ERROR MESSAGES: 
  Error text:  "Missing mandatory value for parameter (x) in GET_SEARCH_OPPORTUNITIES_PP." 
           x = a mandatory parameter that is NULL
  Error meaning: A mandatory parameter is NULL.  
  Error effect:  No results 

  Error text:  "Member (x) not found."  
           x = email address
  Error meaning: The member with the given email address cannot be found in the system.  
  Error effect:  No results.  
  

*/

procedure SEARCH_OPPORTUNITIES_PP (
    p_member_email      IN VARCHAR      -- Must not be NULL
);

end volunteer3b_pkg;
/

create or replace package body volunteer3b_pkg
IS
    procedure CREATE_LOCATION_PP (
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
        END CREATE_LOCATION_PP;

    procedure CREATE_PERSON_PP (
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
        END CREATE_PERSON_PP;    

    procedure CREATE_MEMBER_PP (
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
        END CREATE_MEMBER_PP;

    procedure CREATE_ORGANIZATION_PP (
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
        END CREATE_ORGANIZATION_PP;

    procedure CREATE_OPPORTUNITY_PP (
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
        END CREATE_OPPORTUNITY_PP;

    procedure ADD_ORG_CAUSE_PP (
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
        END ADD_ORG_CAUSE_PP;

    procedure ADD_MEMBER_CAUSE_PP (
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
        END ADD_MEMBER_CAUSE_PP;
    
    procedure ADD_OPP_SKILL_PP (
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
        END ADD_OPP_SKILL_PP;

    procedure ADD_MEMBER_SKILL_PP (
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
        END ADD_MEMBER_SKILL_PP;

    procedure CREATE_COMMITMENT_PP (
        p_commitment_id     OUT INTEGER,    -- Output parameter
        p_member_email      IN  VARCHAR,    -- Not NULL
        p_opportunity_id    IN  VARCHAR,    -- Not NULL
        p_start_date        IN  DATE,       
        p_end_date          IN  DATE
    )
    IS
        ex_exception            EXCEPTION;
        ex_error_msg            VARCHAR (200);
        commitment_id_out       NUMBER;
        checked_person_id       NUMBER;
        checked_member_id       NUMBER;
        checked_opp_id          NUMBER;
        checked_commitment_id   NUMBER;
        checked_start_date      DATE;
        checked_end_date        DATE;
        checked_opp_start_date  DATE;
        checked_opp_end_date    DATE;

        CURSOR check_person_id IS
            SELECT PERSON_ID FROM VM_PERSON WHERE PERSON_EMAIL = p_member_email;

        CURSOR check_member_id IS
            SELECT PERSON_ID FROM VM_MEMBER WHERE PERSON_ID = checked_person_id;

        CURSOR check_opp_id IS
            SELECT OPPORTUNITY_ID FROM VM_OPPORTUNITY WHERE OPPORTUNITY_ID = p_opportunity_id;

        CURSOR check_commitment_id IS
            SELECT COMMITMENT_ID FROM VM_COMMITMENT WHERE OPPORTUNITY_ID = checked_opp_id AND PERSON_ID = checked_member_id ORDER BY COMMITMENT_ID DESC;

        CURSOR check_date IS
            SELECT COMMITMENT_START_DATE, COMMITMENT_END_DATE FROM VM_COMMITMENT WHERE COMMITMENT_ID = checked_commitment_id AND OPPORTUNITY_ID = checked_opp_id AND PERSON_ID = checked_member_id;

        CURSOR check_opp_date IS
            SELECT OPPORTUNITY_START_DATE, OPPORTUNITY_END_DATE FROM VM_OPPORTUNITY WHERE OPPORTUNITY_ID = checked_opp_id;

        BEGIN
            IF p_member_email IS NULL THEN
                ex_error_msg := 'Missing mandatory value for parameter "p_member_email".  No Commitment added.';
                RAISE ex_exception;
            ELSIF p_opportunity_id IS NULL THEN
                ex_error_msg := 'Missing mandatory value for parameter "p_opportunity_id".  No Commitment added.';
                RAISE ex_exception;
            ELSIF p_start_date > p_end_date THEN
                ex_error_msg := 'End date "' || p_end_date || '" must be later than the start date "' || p_start_date || '"';
                RAISE ex_exception;
            ELSE
                OPEN check_person_id;
                FETCH check_person_id INTO checked_person_id;
                    IF check_person_id%FOUND THEN
                        OPEN check_member_id;
                        FETCH check_member_id INTO checked_member_id;
                            IF check_member_id%FOUND THEN
                                OPEN check_opp_id;
                                FETCH check_opp_id INTO checked_opp_id;
                                    IF check_opp_id%FOUND THEN
                                        OPEN check_opp_date;
                                        FETCH check_opp_date INTO checked_opp_start_date, checked_opp_end_date;
                                            IF check_opp_date%FOUND THEN
                                                IF checked_opp_start_date IS NULL AND checked_opp_start_date IS NULL THEN
                                                    p_commitment_id := COMMITMENT_ID_SEQ.NEXTVAL;

                                                    INSERT INTO VM_COMMITMENT
                                                    VALUES (
                                                        p_commitment_id,
                                                        to_date(CURRENT_DATE,'DD-MM-YY'),
                                                        'inquiry',
                                                        p_start_date,
                                                        p_end_date,
                                                        p_opportunity_id,
                                                        checked_member_id
                                                    );
                                                    COMMIT;

                                                    DBMS_OUTPUT.PUT_LINE('Commitment ID "' || p_commitment_id || '" added for user ' || p_member_email || '!');
                                                ELSIF p_start_date >= checked_opp_start_date AND p_start_date <= checked_opp_end_date AND p_end_date >= checked_opp_start_date AND p_end_date <= checked_opp_end_date THEN
                                                    OPEN check_commitment_id;
                                                    FETCH check_commitment_id INTO checked_commitment_id;
                                                        IF check_commitment_id%FOUND THEN
                                                            OPEN check_date;
                                                            FETCH check_date INTO checked_start_date, checked_end_date;
                                                                IF check_date%FOUND THEN
                                                                    IF checked_end_date IS NULL AND checked_end_date IS NULL THEN
                                                                        UPDATE VM_COMMITMENT
                                                                        SET COMMITMENT_START_DATE = p_start_date, COMMITMENT_END_DATE = p_end_date
                                                                        WHERE COMMITMENT_ID = checked_commitment_id;
                                                                        COMMIT;

                                                                        DBMS_OUTPUT.PUT_LINE('Commitment ID "' || checked_commitment_id || '" updated for user ' || p_member_email || '!');
                                                                    ELSIF p_start_date <= checked_end_date AND p_end_date >= checked_start_date THEN
                                                                        UPDATE VM_COMMITMENT
                                                                        SET COMMITMENT_START_DATE = p_start_date, COMMITMENT_END_DATE = p_end_date
                                                                        WHERE COMMITMENT_ID = checked_commitment_id;
                                                                        COMMIT;

                                                                        DBMS_OUTPUT.PUT_LINE('Commitment ID "' || checked_commitment_id || '" updated for user ' || p_member_email || '!');
                                                                    ELSE
                                                                        p_commitment_id := COMMITMENT_ID_SEQ.NEXTVAL;

                                                                        INSERT INTO VM_COMMITMENT
                                                                        VALUES (
                                                                            p_commitment_id,
                                                                            to_date(CURRENT_DATE,'DD-MM-YY'),
                                                                            'inquiry',
                                                                            p_start_date,
                                                                            p_end_date,
                                                                            p_opportunity_id,
                                                                            checked_member_id
                                                                        );
                                                                        COMMIT;

                                                                        DBMS_OUTPUT.PUT_LINE('Commitment ID "' || p_commitment_id || '" added for user ' || p_member_email || '!');
                                                                    END IF;
                                                                END IF;
                                                            CLOSE check_date;
                                                        ELSE
                                                            p_commitment_id := COMMITMENT_ID_SEQ.NEXTVAL;

                                                            INSERT INTO VM_COMMITMENT
                                                            VALUES (
                                                                p_commitment_id,
                                                                to_date(CURRENT_DATE,'DD-MM-YY'),
                                                                'inquiry',
                                                                p_start_date,
                                                                p_end_date,
                                                                p_opportunity_id,
                                                                checked_member_id
                                                            );
                                                            COMMIT;

                                                            DBMS_OUTPUT.PUT_LINE('Commitment ID "' || p_commitment_id || '" added for user ' || p_member_email || '!');
                                                        END IF;
                                                    CLOSE check_commitment_id;
                                                ELSE    
                                                    ex_error_msg := 'Commitment dates are not within opportunity dates!';
                                                    RAISE ex_exception;   
                                                END IF;    
                                            ELSE
                                                p_commitment_id := COMMITMENT_ID_SEQ.NEXTVAL;

                                                INSERT INTO VM_COMMITMENT
                                                VALUES (
                                                    p_commitment_id,
                                                    to_date(CURRENT_DATE,'DD-MM-YY'),
                                                    'inquiry',
                                                    p_start_date,
                                                    p_end_date,
                                                    p_opportunity_id,
                                                    checked_member_id
                                                );
                                                COMMIT;

                                                DBMS_OUTPUT.PUT_LINE('Commitment ID "' || p_commitment_id || '" added for user ' || p_member_email || '!');
                                            END IF;
                                        CLOSE check_opp_date;
                                    ELSE
                                        ex_error_msg := 'Missing opportunity.  No commitment added.';
                                        RAISE ex_exception;
                                    END IF;
                                CLOSE check_opp_id;
                            ELSE
                                ex_error_msg := 'Member "' || p_member_email || '" not found.  No commitment added.';
                                RAISE ex_exception;
                            END IF;
                        CLOSE check_member_id;
                    ELSE
                        ex_error_msg := 'Person with email "' || p_member_email || '" does not exist!';
                        RAISE ex_exception;
                    END IF;
                CLOSE check_person_id;
            END IF;

            EXCEPTION
            WHEN ex_exception THEN
                DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                ROLLBACK;
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('An error occured inserting commitment!');
                dbms_output.put_line('Error code: ' || sqlcode);
                dbms_output.put_line('Error message: ' || sqlerrm);
                ROLLBACK;
        END CREATE_COMMITMENT_PP;

    procedure RECORD_HOURS_PP (
        p_member_email      IN  VARCHAR,    -- Not NULL
        p_opportunity_id    IN  VARCHAR,    -- NOT NULL
        p_hours             IN  NUMBER,     -- NOT NULL
        p_volunteer_date    IN  DATE        -- NOT NULL
    )
    IS
        ex_exception            EXCEPTION;
        ex_error_msg            VARCHAR (200);
        checked_person_id       NUMBER;
        checked_date            DATE;
        checked_member_id       NUMBER;
        checked_opp_id          NUMBER;

        CURSOR check_date IS
            SELECT TIMESHEET_VOLUNTEER_DATE FROM VM_TIMESHEET WHERE TIMESHEET_VOLUNTEER_DATE = p_volunteer_date AND OPPORTUNITY_ID = p_opportunity_id AND PERSON_ID = checked_person_id;

        CURSOR check_person_id IS
            SELECT PERSON_ID FROM VM_PERSON WHERE PERSON_EMAIL = p_member_email;

        CURSOR check_member_id IS
            SELECT PERSON_ID FROM VM_MEMBER WHERE PERSON_ID = checked_person_id;
        
        CURSOR check_opp_id IS
            SELECT OPPORTUNITY_ID FROM VM_OPPORTUNITY WHERE OPPORTUNITY_ID = p_opportunity_id;

        BEGIN
            IF p_member_email IS NULL THEN
                ex_error_msg := 'Missing email! Can not be NULL';
                RAISE ex_exception;
            ELSIF p_opportunity_id IS NULL THEN
                ex_error_msg := 'Missing opportunity ID! Can not be NULL';
                RAISE ex_exception;
            ELSIF p_hours IS NULL THEN
                ex_error_msg := 'Missing amount of hours! Can not be NULL';
                RAISE ex_exception;
            ELSIF p_volunteer_date IS NULL THEN
                ex_error_msg := 'Missing volunteer date! Can not be NULL';
                RAISE ex_exception;
            ELSIF p_hours < 0 AND p_hours > 24 THEN
                ex_error_msg := 'Invalid number of hours for opportunity "' || p_opportunity_id || '". Must be a number between 1 and 24 hours';
                RAISE ex_exception;
            ELSIF p_volunteer_date > CURRENT_DATE THEN
                ex_error_msg := 'You can not insert a future date!';
                RAISE ex_exception;
            ELSE
                OPEN check_person_id;
                FETCH check_person_id INTO checked_person_id;
                    IF check_person_id%FOUND THEN
                        OPEN check_member_id;
                        FETCH check_member_id INTO checked_member_id;
                            IF check_member_id%FOUND THEN
                                OPEN check_opp_id;
                                FETCH check_opp_id INTO checked_opp_id;
                                    IF check_opp_id%FOUND THEN
                                        OPEN check_date;
                                        FETCH check_date INTO checked_date;
                                            IF check_date%NOTFOUND THEN
                                                INSERT INTO VM_TIMESHEET
                                                VALUES (
                                                    p_volunteer_date,
                                                    p_hours,
                                                    to_date(CURRENT_DATE,'DD-MM-YY'),
                                                    'pending',
                                                    null,
                                                    checked_opp_id,
                                                    checked_member_id
                                                );
                                                COMMIT;

                                                DBMS_OUTPUT.PUT_LINE('Commitment hours added to user "' || p_member_email || '"!');
                                            ELSE
                                                ex_error_msg := 'Member: "' || p_member_email || '" in opportunity ID "' || p_opportunity_id || '"" has already registered a record for this day: ' || p_volunteer_date || '!';
                                                RAISE ex_exception;
                                            END IF;
                                        CLOSE check_date;
                                    ELSE
                                        ex_error_msg := 'Missing opportunity.  No commitment added.';
                                        RAISE ex_exception;
                                    END IF;
                                CLOSE check_opp_id;
                            ELSE
                                ex_error_msg := 'Member "' || checked_person_id || '" not found.  No hours added.';
                                RAISE ex_exception;
                            END IF;
                        CLOSE check_member_id;
                    ELSE
                        ex_error_msg := 'Person with email "' || p_member_email || '" does not exist!';
                        RAISE ex_exception;
                    END IF;
                CLOSE check_person_id;
            END IF;

            EXCEPTION
                WHEN ex_exception THEN
                    DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                    ROLLBACK;
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('An error occured inserting new record!');
                    dbms_output.put_line('Error code: ' || sqlcode);
                    dbms_output.put_line('Error message: ' || sqlerrm);
                    ROLLBACK;
        END RECORD_HOURS_PP;

    procedure APPROVE_HOURS_PP (
        p_member_email      IN VARCHAR,    -- Must not be NULL.
        p_approver_email    IN VARCHAR,    -- Must not be NULL.  Approver is a member.
        p_opportunity_id    IN VARCHAR,    -- Must not be NULL.
        p_volunteer_date    IN DATE,
        p_approval_status   IN VARCHAR     -- Must not be NULL.
    )
    IS
        ex_exception            EXCEPTION;
        ex_error_msg            VARCHAR(200);
        checked_person_id       NUMBER;
        checked_member_id       NUMBER;
        checked_approver_id     NUMBER;
        checked_opp_id          NUMBER;
        checked_timesheet_hours NUMBER;

        CURSOR check_person_id IS
            SELECT PERSON_ID FROM VM_PERSON WHERE PERSON_EMAIL = p_member_email;

        CURSOR check_member_id IS
            SELECT PERSON_ID FROM VM_MEMBER WHERE PERSON_ID = checked_person_id;

        CURSOR check_approver_id IS
            SELECT PERSON_ID FROM VM_PERSON WHERE PERSON_EMAIL = p_approver_email;

        CURSOR check_opp_id IS
            SELECT OPPORTUNITY_ID FROM VM_OPPORTUNITY WHERE OPPORTUNITY_ID = p_opportunity_id;

        CURSOR check_timesheet_hours IS
            SELECT TIMESHEET_VOLUNTEER_HOURS FROM VM_TIMESHEET WHERE TIMESHEET_VOLUNTEER_DATE = p_volunteer_date AND OPPORTUNITY_ID = checked_opp_id AND PERSON_ID = checked_person_id;

        BEGIN
            IF p_member_email IS NULL THEN
                ex_error_msg := 'Missing mandatory value for parameter "p_member_email" in APPROVE_HOURS_PP.';
                RAISE ex_exception;
            ELSIF p_approver_email IS NULL THEN
                ex_error_msg := 'Missing mandatory value for parameter "p_approver_email" in APPROVE_HOURS_PP.';
                RAISE ex_exception;
            ELSIF p_opportunity_id IS NULL THEN
                ex_error_msg := 'Missing mandatory value for parameter "p_opportunity_id" in APPROVE_HOURS_PP.';
                RAISE ex_exception;
            ELSIF p_approval_status IS NULL THEN
                ex_error_msg := 'Missing mandatory value for parameter "p_approval_status" in APPROVE_HOURS_PP.';
                RAISE ex_exception;
            ELSIF p_approval_status = 'approved' OR p_approval_status = 'not approved' OR p_approval_status = 'pending' THEN
                OPEN check_person_id;
                FETCH check_person_id INTO checked_person_id;
                    IF check_person_id%FOUND THEN
                        OPEN check_member_id;
                        FETCH check_member_id INTO checked_member_id;
                            IF check_member_id%FOUND THEN
                                OPEN check_approver_id;
                                FETCH check_approver_id INTO checked_approver_id;
                                    IF check_approver_id%FOUND THEN
                                        OPEN check_opp_id;
                                        FETCH check_opp_id INTO checked_opp_id;
                                            IF check_opp_id%FOUND THEN
                                                OPEN check_timesheet_hours;
                                                FETCH check_timesheet_hours INTO checked_timesheet_hours;
                                                    IF check_timesheet_hours%FOUND OR checked_timesheet_hours > 0 THEN
                                                        IF p_volunteer_date IS NULL THEN
                                                            UPDATE VM_TIMESHEET
                                                            SET
                                                            TIMESHEET_STATUS = p_approval_status,
                                                            APPROVER_ID = checked_approver_id
                                                            WHERE PERSON_ID = checked_person_id
                                                            AND OPPORTUNITY_ID = checked_opp_id;
                                                            COMMIT;

                                                            DBMS_OUTPUT.PUT_LINE('Approved hours for user "' || checked_member_id || '" in opportunity ID "' || checked_opp_id || '" with "' || p_approval_status || '"!');
                                                        ELSE
                                                            UPDATE VM_TIMESHEET
                                                            SET
                                                            TIMESHEET_STATUS = p_approval_status,
                                                            APPROVER_ID = checked_approver_id
                                                            WHERE PERSON_ID = checked_person_id
                                                            AND TIMESHEET_VOLUNTEER_DATE = p_volunteer_date
                                                            AND OPPORTUNITY_ID = checked_opp_id;
                                                            COMMIT;

                                                            DBMS_OUTPUT.PUT_LINE('Approved hours for user "' || checked_member_id || '" in opportunity ID "' || checked_opp_id || '" with "' || p_approval_status || '"!');
                                                        END IF;
                                                    ELSE
                                                        ex_error_msg := 'Member "' || checked_member_id || '" has no recorded hours on opportunity "' || checked_opp_id || '" on "' || p_volunteer_date || '".';
                                                        RAISE ex_exception;
                                                    END IF;
                                                CLOSE check_timesheet_hours;
                                            ELSE
                                                ex_error_msg := 'Opportunity "' || p_opportunity_id || '" not found.';
                                                RAISE ex_exception;
                                            END IF;
                                        CLOSE check_opp_id;
                                    ELSE
                                        ex_error_msg := 'Approver "' || checked_approver_id || '" not found.';
                                        RAISE ex_exception;
                                    END IF;
                                CLOSE check_approver_id;
                            ELSE
                                ex_error_msg := 'Member "' || checked_person_id || '" not found.';
                                RAISE ex_exception;
                            END IF;
                        CLOSE check_member_id;
                    ELSE
                        ex_error_msg := 'Person with email "' || p_member_email || '" does not exist!';
                        RAISE ex_exception;
                    END IF;
                CLOSE check_person_id;
            ELSE
                ex_error_msg := 'Invalid value "' || p_approval_status || '" for approval status.';
                RAISE ex_exception;
            END IF;

            EXCEPTION
                WHEN ex_exception THEN
                    DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                    ROLLBACK;
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('An error occured approving hours!');
                    dbms_output.put_line('Error code: ' || sqlcode);
                    dbms_output.put_line('Error message: ' || sqlerrm);
                    ROLLBACK;
        END APPROVE_HOURS_PP; 

    function GET_MEMBER_HOURS_PF (
        p_member_email      IN VARCHAR,         -- Must not be NULL.
        p_opportunity_id    IN INTEGER,         -- Must not be NULL.
        p_start_date        IN DATE,
        p_end_date          IN DATE
    ) RETURN NUMBER
    IS
        ex_exception            EXCEPTION;
        ex_error_msg            VARCHAR (200);
        checked_person_id       NUMBER;
        checked_member_id       NUMBER;
        checked_opp_id          NUMBER;
        total_hours             NUMBER := 0;

        CURSOR check_person_id IS
            SELECT PERSON_ID FROM VM_PERSON WHERE PERSON_EMAIL = p_member_email;

        CURSOR check_member_id IS
            SELECT PERSON_ID FROM VM_MEMBER WHERE PERSON_ID = checked_person_id;

        CURSOR check_opp_id IS
            SELECT OPPORTUNITY_ID FROM VM_OPPORTUNITY WHERE OPPORTUNITY_ID = p_opportunity_id;

        BEGIN
            IF p_member_email IS NULL THEN
                ex_error_msg := 'Missing mandatory value for parameter "p_member_email" in GET_MEMBER_HOURS_PF.';
                RAISE ex_exception;
            ELSIF p_opportunity_id IS NULL THEN
                ex_error_msg := 'Missing mandatory value for parameter "p_opportunity_id" in GET_MEMBER_HOURS_PF.';
                RAISE ex_exception;
            ELSIF p_start_date > p_end_date THEN
                ex_error_msg := 'End date "' || p_end_date || '" must be later than the start date "' || p_start_date || '"';
                RAISE ex_exception;
            ELSE
                OPEN check_person_id;
                FETCH check_person_id INTO checked_person_id;
                    IF check_person_id%FOUND THEN
                        OPEN check_member_id;
                        FETCH check_member_id INTO checked_member_id;
                            IF check_member_id%FOUND THEN
                                OPEN check_opp_id;
                                FETCH check_opp_id INTO checked_opp_id;
                                    IF check_opp_id%FOUND THEN
                                        IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN
                                            FOR opp in (
                                                SELECT OPPORTUNITY_TITLE,SUM(TIMESHEET_VOLUNTEER_HOURS) AS hours
                                                FROM VM_OPPORTUNITY
                                                INNER JOIN VM_TIMESHEET ON VM_OPPORTUNITY.OPPORTUNITY_ID = VM_TIMESHEET.OPPORTUNITY_ID
                                                INNER JOIN VM_PERSON ON VM_TIMESHEET.PERSON_ID = VM_PERSON.PERSON_ID
                                                WHERE VM_TIMESHEET.PERSON_ID = checked_member_id
                                                AND VM_TIMESHEET.OPPORTUNITY_ID = p_opportunity_ID
                                                AND TIMESHEET_VOLUNTEER_DATE
                                                BETWEEN to_date(p_start_date, 'DD-MM-YY') AND to_date(p_end_date, 'DD-MM-YY')
                                                GROUP BY OPPORTUNITY_TITLE
                                            ) LOOP
                                                DBMS_OUTPUT.PUT_LINE('Opportunity: ' || opp.OPPORTUNITY_TITLE || ' - Hours worked: ' || opp.hours);
                                                total_hours := total_hours + opp.hours;
                                            END LOOP;
                                        ELSIF p_start_date IS NULL AND p_end_date IS NULL THEN
                                            FOR opp in (
                                                SELECT OPPORTUNITY_TITLE,SUM(TIMESHEET_VOLUNTEER_HOURS) AS hours
                                                FROM VM_OPPORTUNITY
                                                INNER JOIN VM_TIMESHEET ON VM_OPPORTUNITY.OPPORTUNITY_ID = VM_TIMESHEET.OPPORTUNITY_ID
                                                INNER JOIN VM_PERSON ON VM_TIMESHEET.PERSON_ID = VM_PERSON.PERSON_ID
                                                WHERE VM_TIMESHEET.PERSON_ID = checked_member_id
                                                AND VM_TIMESHEET.OPPORTUNITY_ID = p_opportunity_ID
                                                GROUP BY OPPORTUNITY_TITLE
                                            ) LOOP
                                                DBMS_OUTPUT.PUT_LINE('Opportunity: ' || opp.OPPORTUNITY_TITLE || ' - Hours worked: ' || opp.hours);
                                                total_hours := total_hours + opp.hours;
                                            END LOOP;
                                        ELSIF p_start_date IS NULL AND p_end_date IS NOT NULL THEN
                                            FOR opp in (
                                                SELECT OPPORTUNITY_TITLE,SUM(TIMESHEET_VOLUNTEER_HOURS) AS hours
                                                FROM VM_OPPORTUNITY
                                                INNER JOIN VM_TIMESHEET ON VM_OPPORTUNITY.OPPORTUNITY_ID = VM_TIMESHEET.OPPORTUNITY_ID
                                                INNER JOIN VM_PERSON ON VM_TIMESHEET.PERSON_ID = VM_PERSON.PERSON_ID
                                                WHERE VM_TIMESHEET.PERSON_ID = checked_member_id AND TIMESHEET_VOLUNTEER_DATE < p_end_date
                                                AND VM_TIMESHEET.OPPORTUNITY_ID = p_opportunity_ID
                                                GROUP BY OPPORTUNITY_TITLE
                                            ) LOOP
                                                DBMS_OUTPUT.PUT_LINE('Opportunity: ' || opp.OPPORTUNITY_TITLE || ' - Hours worked: ' || opp.hours);
                                                total_hours := total_hours + opp.hours;
                                            END LOOP;
                                        ELSIF p_start_date IS NULL AND p_end_date IS NOT NULL THEN
                                            FOR opp in (
                                                SELECT OPPORTUNITY_TITLE,SUM(TIMESHEET_VOLUNTEER_HOURS) AS hours
                                                FROM VM_OPPORTUNITY
                                                INNER JOIN VM_TIMESHEET ON VM_OPPORTUNITY.OPPORTUNITY_ID = VM_TIMESHEET.OPPORTUNITY_ID
                                                INNER JOIN VM_PERSON ON VM_TIMESHEET.PERSON_ID = VM_PERSON.PERSON_ID
                                                WHERE VM_TIMESHEET.PERSON_ID = checked_member_id AND TIMESHEET_VOLUNTEER_DATE > p_start_date
                                                AND VM_TIMESHEET.OPPORTUNITY_ID = p_opportunity_ID
                                                GROUP BY OPPORTUNITY_TITLE
                                            ) LOOP
                                                DBMS_OUTPUT.PUT_LINE('Opportunity: ' || opp.OPPORTUNITY_TITLE || ' - Hours worked: ' || opp.hours);
                                                total_hours := total_hours + opp.hours;
                                            END LOOP;
                                        ELSE
                                            ex_error_msg := 'An error occured calculating worked hours!';
                                            RAISE ex_exception;
                                        END IF;
                                    ELSE
                                        ex_error_msg := 'Opportunity "' || p_opportunity_id || '" not found.';
                                        RAISE ex_exception;
                                    END IF;
                                CLOSE check_opp_id;
                            ELSE
                                ex_error_msg := 'Member "' || checked_person_id || '" not found.';
                                RAISE ex_exception;
                            END IF;
                        CLOSE check_member_id;
                    ELSE
                        ex_error_msg := 'Person with email "' || p_member_email || '" does not exist!';
                        RAISE ex_exception;
                    END IF;
                CLOSE check_person_id;
            END IF;

            RETURN total_hours;

            EXCEPTION
                WHEN ex_exception THEN
                    DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                    RETURN NULL;
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('An error occured returning hours!');
                    dbms_output.put_line('Error code: ' || sqlcode);
                    dbms_output.put_line('Error message: ' || sqlerrm);
                    RETURN NULL;
        END GET_MEMBER_HOURS_PF;

    function GET_MEMBER_HOURS_PF (
        p_member_email      IN VARCHAR,         -- Must not be NULL.
        p_start_date        IN DATE,
        p_end_date          IN DATE
    ) RETURN NUMBER
    IS
        ex_exception            EXCEPTION;
        ex_error_msg            VARCHAR (200);
        checked_person_id       NUMBER;
        checked_member_id       NUMBER;
        total_hours             NUMBER := 0;

        CURSOR check_member_id IS
            SELECT PERSON_ID FROM VM_MEMBER WHERE PERSON_ID = checked_person_id;

        CURSOR check_person_id IS
            SELECT PERSON_ID FROM VM_PERSON WHERE PERSON_EMAIL = p_member_email;

       BEGIN
            IF p_member_email IS NULL THEN
                ex_error_msg := 'Missing mandatory value for parameter "p_member_email" in GET_MEMBER_HOURS_PF.';
                RAISE ex_exception;
            ELSIF p_start_date > p_end_date THEN
                ex_error_msg := 'End date "' || p_end_date || '" must be later than the start date "' || p_start_date || '"';
                RAISE ex_exception;
            ELSE
                OPEN check_person_id;
                FETCH check_person_id INTO checked_person_id;
                    IF check_person_id%FOUND THEN
                        OPEN check_member_id;
                        FETCH check_member_id INTO checked_member_id;
                            IF check_member_id%FOUND THEN
                                IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN
                                    FOR opp in (
                                        SELECT OPPORTUNITY_TITLE,SUM(TIMESHEET_VOLUNTEER_HOURS) AS hours
                                        FROM VM_OPPORTUNITY
                                        INNER JOIN VM_TIMESHEET ON VM_OPPORTUNITY.OPPORTUNITY_ID = VM_TIMESHEET.OPPORTUNITY_ID
                                        INNER JOIN VM_PERSON ON VM_TIMESHEET.PERSON_ID = VM_PERSON.PERSON_ID
                                        WHERE VM_TIMESHEET.PERSON_ID = checked_member_id
                                        AND TIMESHEET_VOLUNTEER_DATE
                                        BETWEEN to_date(p_start_date, 'DD-MM-YY') AND to_date(p_end_date, 'DD-MM-YY')
                                        GROUP BY OPPORTUNITY_TITLE
                                    ) LOOP
                                        DBMS_OUTPUT.PUT_LINE('Opportunity: ' || opp.OPPORTUNITY_TITLE || ' - Hours worked: ' || opp.hours);
                                        total_hours := total_hours + opp.hours;
                                    END LOOP;
                                ELSIF p_start_date IS NULL AND p_end_date IS NULL THEN
                                    FOR opp in (
                                        SELECT OPPORTUNITY_TITLE,SUM(TIMESHEET_VOLUNTEER_HOURS) AS hours
                                        FROM VM_OPPORTUNITY
                                        INNER JOIN VM_TIMESHEET ON VM_OPPORTUNITY.OPPORTUNITY_ID = VM_TIMESHEET.OPPORTUNITY_ID
                                        INNER JOIN VM_PERSON ON VM_TIMESHEET.PERSON_ID = VM_PERSON.PERSON_ID
                                        WHERE VM_TIMESHEET.PERSON_ID = checked_member_id
                                        GROUP BY OPPORTUNITY_TITLE
                                    ) LOOP
                                        DBMS_OUTPUT.PUT_LINE('Opportunity: ' || opp.OPPORTUNITY_TITLE || ' - Hours worked: ' || opp.hours);
                                        total_hours := total_hours + opp.hours;
                                    END LOOP;
                                ELSIF p_start_date IS NULL AND p_end_date IS NOT NULL THEN
                                    FOR opp in (
                                        SELECT OPPORTUNITY_TITLE,SUM(TIMESHEET_VOLUNTEER_HOURS) AS hours
                                        FROM VM_OPPORTUNITY
                                        INNER JOIN VM_TIMESHEET ON VM_OPPORTUNITY.OPPORTUNITY_ID = VM_TIMESHEET.OPPORTUNITY_ID
                                        INNER JOIN VM_PERSON ON VM_TIMESHEET.PERSON_ID = VM_PERSON.PERSON_ID
                                        WHERE VM_TIMESHEET.PERSON_ID = checked_member_id AND TIMESHEET_VOLUNTEER_DATE < p_end_date
                                        GROUP BY OPPORTUNITY_TITLE
                                    ) LOOP
                                        DBMS_OUTPUT.PUT_LINE('Opportunity: ' || opp.OPPORTUNITY_TITLE || ' - Hours worked: ' || opp.hours);
                                        total_hours := total_hours + opp.hours;
                                    END LOOP;
                                ELSIF p_end_date IS NULL AND p_start_date IS NOT NULL THEN
                                    FOR opp in (
                                        SELECT OPPORTUNITY_TITLE,SUM(TIMESHEET_VOLUNTEER_HOURS) AS hours
                                        FROM VM_OPPORTUNITY
                                        INNER JOIN VM_TIMESHEET ON VM_OPPORTUNITY.OPPORTUNITY_ID = VM_TIMESHEET.OPPORTUNITY_ID
                                        INNER JOIN VM_PERSON ON VM_TIMESHEET.PERSON_ID = VM_PERSON.PERSON_ID
                                        WHERE VM_TIMESHEET.PERSON_ID = checked_member_id AND TIMESHEET_VOLUNTEER_DATE > p_start_date
                                        GROUP BY OPPORTUNITY_TITLE
                                    ) LOOP
                                        DBMS_OUTPUT.PUT_LINE('Opportunity: ' || opp.OPPORTUNITY_TITLE || ' - Hours worked: ' || opp.hours);
                                        total_hours := total_hours + opp.hours;
                                    END LOOP;
                                ELSE
                                    ex_error_msg := 'An error occured calculating worked hours!';
                                    RAISE ex_exception;
                                END IF;
                            ELSE
                                ex_error_msg := 'Member "' || checked_person_id || '" not found.';
                                RAISE ex_exception;
                            END IF;
                        CLOSE check_member_id;
                    ELSE
                        ex_error_msg := 'Person with email "' || p_member_email || '" does not exist!';
                        RAISE ex_exception;
                    END IF;
                CLOSE check_person_id;
            END IF;

            RETURN total_hours;

            EXCEPTION
                WHEN ex_exception THEN
                    DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                    RETURN NULL;
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('An error occured returning hours!');
                    dbms_output.put_line('Error code: ' || sqlcode);
                    dbms_output.put_line('Error message: ' || sqlerrm);
                    RETURN NULL;
        END GET_MEMBER_HOURS_PF;

    procedure SEARCH_OPPORTUNITIES_PP (
        p_member_email      IN VARCHAR      -- Must not be NULL
    )
    IS
        ex_exception EXCEPTION;
        ex_error_msg VARCHAR (200);
        checked_person_id NUMBER;
        checked_member_id NUMBER;
        
        memSkill VM_MEMSKILL.SKILL_NAME%TYPE;
        oppSkill VM_OPPSKILL.SKILL_NAME%TYPE;
        
        oppId VM_OPPSKILL.OPPORTUNITY_ID%TYPE;
        oppTitle VM_OPPORTUNITY.OPPORTUNITY_TITLE%TYPE;

        memCause VM_MEMCAUSE.CAUSE_NAME%TYPE;
        orgCause VM_ORGCAUSE.CAUSE_NAME%TYPE;
        
        orgId VM_ORGCAUSE.ORGANIZATION_ID%TYPE;
        orgTitle VM_ORGANIZATION.ORGANIZATION_NAME%TYPE;
        
        orgOppTitle VM_OPPORTUNITY.OPPORTUNITY_TITLE%TYPE;

        CURSOR check_person_id IS
            SELECT PERSON_ID FROM VM_PERSON WHERE PERSON_EMAIL = p_member_email;
        
        CURSOR check_member_id IS
            SELECT PERSON_ID FROM VM_MEMBER WHERE PERSON_ID = checked_person_id;
        
        CURSOR check_mem_skill IS
            SELECT SKILL_NAME
            FROM VM_MEMSKILL
            WHERE PERSON_ID = checked_person_id;

        CURSOR check_mem_cause IS
            SELECT CAUSE_NAME
            FROM VM_MEMCAUSE
            WHERE PERSON_ID = checked_person_id;

        CURSOR memOppSkill IS
            SELECT VM_OPPSKILL.SKILL_NAME, VM_OPPSKILL.OPPORTUNITY_ID, VM_OPPORTUNITY.OPPORTUNITY_TITLE
            INTO oppSkill, oppId, oppTitle
            FROM VM_OPPSKILL
            INNER JOIN VM_OPPORTUNITY ON VM_OPPSKILL.OPPORTUNITY_ID = VM_OPPORTUNITY.OPPORTUNITY_ID
            WHERE VM_OPPSKILL.SKILL_NAME = memSkill;

        CURSOR memOrgCause IS
            SELECT VM_ORGCAUSE.CAUSE_NAME, VM_ORGCAUSE.ORGANIZATION_ID, VM_ORGANIZATION.ORGANIZATION_NAME
            INTO orgCause, orgId, orgTitle
            FROM VM_ORGCAUSE
            INNER JOIN VM_ORGANIZATION ON VM_ORGCAUSE.ORGANIZATION_ID = VM_ORGANIZATION.ORGANIZATION_ID
            WHERE VM_ORGCAUSE.CAUSE_NAME = memCause;

        CURSOR get_org_opp IS
            SELECT OPPORTUNITY_TITLE
            FROM VM_OPPORTUNITY
            WHERE ORGANIZATION_ID = orgId;

        BEGIN
            IF p_member_email IS NULL THEN
                ex_error_msg := 'Missing mandatory value for parameter "p_member_email" in SEARCH_OPPORTUNITIES_PP.';
                RAISE ex_exception;
            ELSE
                OPEN check_person_id;
                FETCH check_person_id INTO checked_person_id;
                    IF check_person_id%FOUND THEN
                        OPEN check_member_id;
                        FETCH check_member_id INTO checked_member_id;
                            IF check_member_id%FOUND THEN
                                OPEN check_mem_skill;
                                LOOP
                                    FETCH check_mem_skill INTO memSKill;
                                        EXIT WHEN check_mem_skill%NOTFOUND;
                                        OPEN memOppSkill;
                                        LOOP
                                            FETCH memOppSkill INTO oppSkill, oppId, oppTitle;
                                                EXIT WHEN memOppSkill%NOTFOUND;
                                                DBMS_OUTPUT.PUT_LINE('Matching opportunity: "' || oppTitle || '" based on skill: "' || memSkill || '"');
                                                COMMIT;
                                            END LOOP;
                                        CLOSE memOppSkill;
                                    END LOOP;
                                CLOSE check_mem_skill;

                                OPEN check_mem_cause;
                                LOOP
                                    FETCH check_mem_cause INTO memCause;
                                        EXIT WHEN check_mem_cause%NOTFOUND;
                                        OPEN memOrgCause;
                                        LOOP
                                            FETCH memOrgCause INTO orgCause, orgId, orgTitle;
                                                EXIT WHEN memOrgCause%NOTFOUND;
                                                OPEN get_org_opp;
                                                LOOP
                                                    FETCH get_org_opp INTO orgOppTitle;
                                                        EXIT WHEN get_org_opp%NOTFOUND;
                                                        DBMS_OUTPUT.PUT_LINE('Matching opportunity: "' || orgOppTitle || '" based on cause: "' || memCause || '"');
                                                        COMMIT;
                                                    END LOOP;
                                                CLOSE get_org_opp;
                                            END LOOP;
                                        CLOSE memOrgCause;
                                    END LOOP;
                                CLOSE check_mem_cause;
                            ELSE
                                ex_error_msg := 'Member "' || p_member_email || '" not found.';
                                RAISE ex_exception;
                            END IF;
                        CLOSE check_member_id;
                    END IF;
                CLOSE check_person_id;
            END IF;

            EXCEPTION
                WHEN ex_exception THEN
                    DBMS_OUTPUT.PUT_LINE(ex_error_msg);
                    ROLLBACK;
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('An error occured searching for opportunities!');
                    dbms_output.put_line('Error code: ' || sqlcode);
                    dbms_output.put_line('Error message: ' || sqlerrm);
                    ROLLBACK;
        END SEARCH_OPPORTUNITIES_PP;
end volunteer3b_pkg;
