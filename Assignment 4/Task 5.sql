CREATE ROLE roleViewer;
GRANT CREATE SESSION TO roleViewer;
BEGIN
    FOR i IN (SELECT * FROM user_tables)
    LOOP
        EXECUTE IMMEDIATE 'GRANT SELECT ON ' || i.table_name || ' TO roleViewer';
    END LOOP;
END;

CREATE ROLE roleAdmin;
GRANT CREATE SESSION TO roleAdmin;
GRANT EXECUTE ON VOLUNTEER3B_PKG TO roleAdmin;

create or replace package roleOppAdmin_pkg
IS
procedure CREATE_LOCATION_PP (
  p_location_id		    OUT	INTEGER,        -- an output parameter
  p_location_country	IN	VARCHAR,        -- must not be NULL
  p_location_postal_code IN	VARCHAR,        -- must not be NULL
  p_location_street1	IN	VARCHAR,
  p_location_street2	IN	VARCHAR,
  p_location_city	    IN	VARCHAR,
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
    p_location_country	    IN  VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_postal_code  IN	VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_street1	    IN	VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_street2	    IN	VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_city	        IN	VARCHAR,  -- passed through to CREATE_LOCATION_PP
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
    p_location_country	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_postal_code      IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street1	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street2	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_city	            IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
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
    p_location_country	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_postal_code      IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street1	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_street2	        IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
    p_location_city	            IN	VARCHAR,  -- passed to CREATE_LOCATION_SP
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
procedure ADD_OPP_SKILL_PP (
    p_opp_id        IN  INTEGER,    -- NOT NULL
    p_skill_name    IN  VARCHAR     -- NOT NULL
);
end roleOppAdmin_pkg;

CREATE ROLE roleOppAdmin;
GRANT CREATE SESSION TO roleOppAdmin;
GRANT EXECUTE ON roleOppAdmin_PKG TO roleOppAdmin;

create or replace package roleMember_pkg
IS
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
    p_location_country	    IN  VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_postal_code  IN	VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_street1	    IN	VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_street2	    IN	VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_city	        IN	VARCHAR,  -- passed through to CREATE_LOCATION_PP
    p_location_administrative_region IN VARCHAR, -- passed through to CREATE_LOCATION_SP
    p_member_password       IN  VARCHAR   -- NOT NULL  
);
procedure ADD_MEMBER_CAUSE_PP (
    p_person_id     IN  INTEGER,    -- NOT NULL
    p_cause_name    IN  VARCHAR     -- NOT NULL
);
procedure ADD_MEMBER_SKILL_PP (
    p_person_id     IN  INTEGER,    -- NOT NULL
    p_skill_name    IN  VARCHAR -- NOT NULL
);
procedure CREATE_COMMITMENT_PP (
    p_commitment_id     OUT INTEGER,    -- Output parameter
    p_member_email      IN  VARCHAR,    -- Not NULL
    p_opportunity_id    IN  VARCHAR,    -- Not NULL
    p_start_date        IN  DATE,       
    p_end_date          IN  DATE
);
end roleMember_pkg;

CREATE ROLE roleMember;
GRANT CREATE SESSION TO roleMember;
GRANT EXECUTE ON roleMember_PKG TO roleMember;