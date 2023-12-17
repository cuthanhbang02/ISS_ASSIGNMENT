BEGIN
SA_SYSDBA.CREATE_POLICY(
    policy_name => 'ACCESS_EMP_INFO',
    column_name => 'OLS_EMP'
);
END;

GRANT ACCESS_EMP_INFO_DBA TO SEC_MGR;
GRANT EXECUTE ON sa_components TO SEC_MGR;
GRANT EXECUTE ON sa_label_admin TO SEC_MGR;
GRANT EXECUTE ON sa_policy_admin TO SEC_MGR;

EXECUTE sa_components.create_level ('ACCESS_EMP_INFO',500,'TS','TOP_SECRET');

EXECUTE sa_components.create_level ('ACCESS_EMP_INFO',400,'S','SECRET');

EXECUTE sa_components.create_level ('ACCESS_EMP_INFO',300,'C','CONFIDENTIAL');

EXECUTE sa_components.create_level ('ACCESS_EMP_INFO',200,'P','PUBLIC');


-- create compartment
EXECUTE sa_components.create_compartment ('ACCESS_EMP_INFO',100,'PRJ','PROJECT');

EXECUTE sa_components.create_compartment ('ACCESS_EMP_INFO',200,'HUM','HUMAN');

EXECUTE sa_components.create_compartment ('ACCESS_EMP_INFO',300,'FIN','FINANCIAL');

-- create group
EXECUTE sa_components.create_group('ACCESS_EMP_INFO',1100,'LDR','LEADER',NULL);

EXECUTE sa_components.create_group('ACCESS_EMP_INFO',1200,'HR','HUMAN_RESOURCE','LDR');

EXECUTE sa_components.create_group('ACCESS_EMP_INFO',1300,'DEV','DEV_TEAM','LDR');


-- create data label
EXECUTE sa_label_admin.create_label ('ACCESS_EMP_INFO',1000,'C:PRJ:LDR,DEV');

EXECUTE sa_label_admin.create_label ('ACCESS_EMP_INFO',1100,'C:HUM:');

EXECUTE sa_label_admin.create_label ('ACCESS_EMP_INFO',1200,'S:HUM:HR');

EXECUTE sa_label_admin.create_label ('ACCESS_EMP_INFO',1300,'TS:HUM:LDR');

-- create role
CREATE ROLE NORMAL_EMP;
GRANT SELECT ON STAFF_USER TO NORMAL_EMP;
GRANT SELECT ON P_PROJECT TO NORMAL_EMP;
GRANT SELECT ON PROJECT_MEMBER TO NORMAL_EMP;
GRANT CREATE SESSION TO NORMAL_EMP;

CREATE ROLE PROJECT_MANAGER;
GRANT SELECT ON STAFF_USER TO PROJECT_MANAGER;
GRANT SELECT ON PROJECT_MEMBER TO PROJECT_MANAGER;
GRANT SELECT, UPDATE, INSERT, DELETE ON P_PROJECT TO PROJECT_MANAGER;
GRANT CREATE SESSION TO PROJECT_MANAGER;

CREATE ROLE HR_EMP;
GRANT SELECT, INSERT, UPDATE, DELETE ON STAFF_USER TO HR_EMP;
GRANT SELECT ON P_PROJECT TO HR_EMP;
GRANT CREATE SESSION TO HR_EMP;

CREATE ROLE HR_MANAGER;
GRANT SELECT, INSERT, UPDATE, DELETE ON STAFF_USER TO HR_MANAGER;
GRANT CREATE SESSION TO HR_MANAGER;

CREATE ROLE DIRECTOR;
GRANT ALL PRIVILEGES ON STAFF_USER TO DIRECTOR;
GRANT ALL PRIVILEGES ON P_PROJECT TO DIRECTOR;
GRANT ALL PRIVILEGES ON PROJECT_MEMBER TO DIRECTOR;
GRANT ALL PRIVILEGES ON DEPARTMENT TO DIRECTOR;
GRANT ALL PRIVILEGES ON DEPARTMENT_MEMBER TO DIRECTOR;
GRANT CREATE SESSION TO DIRECTOR;

-- assign role to user
GRANT NORMAL_EMP TO hung_iss, my_iss, thuy_iss, tung_iss, son_iss, dat_iss, ngan_iss, huyen_iss, viet_iss;

GRANT PROJECT_MANAGER TO dung_iss, huyen_iss;

GRANT HR_EMP TO hung_iss, my_iss;

GRANT HR_MANAGER TO loan_iss;

GRANT DIRECTOR TO thang_iss;

-- assign level to role
EXECUTE sa_user_admin.set_levels('ACCESS_EMP_INFO','NORMAL_EMP','C','P','C','P');

EXECUTE sa_user_admin.set_levels('ACCESS_EMP_INFO','PROJECT_MANAGER','TS','C','TS','C');

EXECUTE sa_user_admin.set_levels('ACCESS_EMP_INFO','HR_EMP','S','C','S','C');

EXECUTE sa_user_admin.set_levels('ACCESS_EMP_INFO','HR_MANAGER','TS','C','TS','C');

EXECUTE sa_user_admin.set_levels('ACCESS_EMP_INFO','DIRECTOR','TS','p','TS','TS');


-- assign compartment to role
EXECUTE sa_user_admin.set_compartments('ACCESS_EMP_INFO', 'NORMAL_EMP', 'PRJ', NULL, NULL, NULL);

EXECUTE sa_user_admin.set_compartments('ACCESS_EMP_INFO', 'PROJECT_MANAGER', 'PRJ,HUM', 'PRJ', NULL, NULL);

EXECUTE sa_user_admin.set_compartments('ACCESS_EMP_INFO', 'HR_EMP', 'HUM', 'HUM', NULL, NULL);

EXECUTE sa_user_admin.set_compartments('ACCESS_EMP_INFO', 'HR_MANAGER', 'HUM', 'HUM', NULL, NULL);

EXECUTE sa_user_admin.set_compartments('ACCESS_EMP_INFO', 'DIRECTOR', 'PRJ,HUM', 'PRJ,HUM', NULL, NULL);

-- assign group to role
EXECUTE sa_user_admin.set_groups('ACCESS_EMP_INFO', 'NORMAL_EMP', 'DEV', NULL, NULL, NULL);

EXECUTE sa_user_admin.set_groups('ACCESS_EMP_INFO', 'PROJECT_MANAGER', 'LDR', 'LDR', NULL, NULL);

EXECUTE sa_user_admin.set_groups('ACCESS_EMP_INFO', 'HR_EMP', 'HR', NULL, NULL, NULL);

EXECUTE sa_user_admin.set_groups('ACCESS_EMP_INFO', 'HR_MANAGER', 'LDR', 'LDR', NULL, NULL);

EXECUTE sa_user_admin.set_groups('ACCESS_EMP_INFO', 'DIRECTOR', 'LDR', 'LDR', NULL, NULL);

GRANT execute ON to_lbac_data_label TO SEC_MGR WITH GRANT OPTION;

CREATE OR REPLACE FUNCTION gen_personel_label(
    P_DIR CHAR,
    P_PER_DEPT CHAR,
    P_PER_DEPT_MANAGER CHAR,
    P_PRJ CHAR,
    P_PRJ_MANAGER CHAR
)
RETURN LBACSYS.LBAC_LABEL
AS
i_label varchar2(80);
BEGIN
--Determine level
IF P_DIR = 1 or P_PRJ_MANAGER = 1 or P_PER_DEPT_MANAGER = 1 THEN
    i_label := 'TS:HUM:LDR';
ELSIF P_PER_DEPT = 1 THEN
    i_label := 'S:HUM:HR';
ELSIF P_PRJ = 1 THEN
    i_label := 'C:HUM:';
ELSE
    i_label := '';
END IF;

RETURN TO_LBAC_DATA_LABEL('ACCESS_EMP_INFO',i_label);
END;

CREATE OR REPLACE FUNCTION gen_project_label
RETURN LBACSYS.LBAC_LABEL
AS
i_label varchar2(80);
BEGIN

RETURN TO_LBAC_DATA_LABEL('ACCESS_EMP_INFO','C:PRJ:LDR,DEV');
END;

GRANT execute ON gen_personel_label TO lbacsys;
GRANT execute ON gen_project_label TO lbacsys;