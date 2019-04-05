create or replace procedure ADD_MEMBER_SKILL_SP (
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

                        INSERT INTO VM_SKILL
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