CREATE TABLE STAFF_USER(
    USER_ID                         CHAR(5),
    USERNAME                        VARCHAR2(50)    NOT NULL    UNIQUE,
    FIRST_NAME                      VARCHAR2(50)    NOT NULL,
    LAST_NAME                       VARCHAR2(50),
    EMAIL                           VARCHAR2(50),
    P_RANK                          VARCHAR2(7)     CHECK (P_RANK IN ('STAFF', 'MANAGER', 'INTERN')),
    SALARY                          NUMBER(9,0)     CHECK (SALARY > 0),
    TAXCODE                         VARCHAR2(20)    NOT NULL    UNIQUE,
    DIRECTOR_FLAG                   CHAR(1)         NOT NULL    CHECK (DIRECTOR_FLAG >= 0),
    HR_STAFF_FLAG                   CHAR(1)         NOT NULL    CHECK (HR_STAFF_FLAG >= 0),
    HR_MANAGER_FLAG                 CHAR(1)         NOT NULL    CHECK (HR_MANAGER_FLAG >= 0),
    DEPART_MEMBER_FLAG              CHAR(1)         NOT NULL    CHECK (DEPART_MEMBER_FLAG >= 0),   
    DEPART_MANAGER_FLAG             CHAR(1)         NOT NULL    CHECK (DEPART_MANAGER_FLAG >= 0),
    PROJECT_MEMBER_FLAG             CHAR(1)         NOT NULL    CHECK (PROJECT_MEMBER_FLAG >= 0),
    PROJECT_MANAGER_FLAG            CHAR(1)         NOT NULL    CHECK (PROJECT_MANAGER_FLAG >= 0),
    
    PRIMARY KEY (USER_ID),
    CHECK (DIRECTOR_FLAG + HR_STAFF_FLAG + DEPART_MEMBER_FLAG = 1),
    CHECK (DEPART_MANAGER_FLAG != 1 or PROJECT_MANAGER_FLAG != 1),
    CHECK (HR_STAFF_FLAG != 0 or HR_MANAGER_FLAG != 1),
    CHECK (DEPART_MEMBER_FLAG != 0 or DEPART_MANAGER_FLAG != 1),
    CHECK (PROJECT_MEMBER_FLAG != 0 or PROJECT_MANAGER_FLAG != 1)
);

CREATE TABLE P_PROJECT(
    PROJECT_ID          CHAR(5),
    MANAGER_ID          CHAR(5),
    P_NAME              VARCHAR2(200)   UNIQUE NOT NULL,
    START_DATE          DATE            NOT NULL,
    EXPECTED_END_DATE   DATE            NOT NULL,
    ACTUAL_END_DATE     DATE,
    BUDGET              NUMBER(12,0)    CHECK (BUDGET > 0),
    P_DESCRIPTION       VARCHAR2(1000),
    
    PRIMARY KEY (PROJECT_ID),
    FOREIGN KEY (MANAGER_ID) REFERENCES STAFF_USER(USER_ID) ON DELETE CASCADE,
    CHECK (EXPECTED_END_DATE > START_DATE),
    CHECK ((ACTUAL_END_DATE is null) or (ACTUAL_END_DATE > START_DATE))
);

CREATE TABLE PROJECT_MEMBER(
    PROJECT_ID  CHAR(5),
    USER_ID    CHAR(5),
    START_DATE  DATE        NOT NULL,
    END_DATE    DATE,
    
    PRIMARY KEY (PROJECT_ID, USER_ID),
    FOREIGN KEY (PROJECT_ID) REFERENCES P_PROJECT(PROJECT_ID) ON DELETE CASCADE,
    FOREIGN KEY (USER_ID) REFERENCES STAFF_USER(USER_ID) ON DELETE CASCADE,
    CHECK ((END_DATE is null) or (END_DATE > START_DATE))
);

CREATE TABLE DEPARTMENT(
    DEPARTMENT_ID           CHAR(5),
    MANAGER_ID              CHAR(5),
    D_NAME                  VARCHAR2(200)   UNIQUE NOT NULL,
    HR_DEPART_FLAG          CHAR(1)         CHECK (HR_DEPART_FLAG >= 0),
    NORMAL_DEPART_FLAG      CHAR(1)         CHECK (NORMAL_DEPART_FLAG >= 0),
    
    PRIMARY KEY (DEPARTMENT_ID),
    FOREIGN KEY (MANAGER_ID) REFERENCES STAFF_USER(USER_ID) ON DELETE CASCADE,
    CHECK (HR_DEPART_FLAG + NORMAL_DEPART_FLAG = 1) 
);

CREATE TABLE DEPARTMENT_MEMBER(
    DEPARTMENT_ID   CHAR(5),
    USER_ID        CHAR(5),
    START_DATE      DATE        NOT NULL,
    END_DATE        DATE,
    
    PRIMARY KEY (DEPARTMENT_ID, USER_ID),
    FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENT(DEPARTMENT_ID) ON DELETE CASCADE,
    FOREIGN KEY (USER_ID) REFERENCES STAFF_USER(USER_ID) ON DELETE CASCADE,
    CHECK ((END_DATE is null) or (END_DATE > START_DATE))
);

CREATE TABLE RECRUITMENT(
    JOB_ID              CHAR(5),
    MANAGER_ID          CHAR(5),
    DEPARTMENT_ID       CHAR(5),
    HR_STAFF_ID         CHAR(5),
    J_POSITION          VARCHAR2(200)   NOT NULL,
    START_DATE          DATE            NOT NULL,
    END_DATE            DATE,
    J_DESCRIPTION       VARCHAR2(1000),
    J_REQUIREMENTS      VARCHAR2(1000),
    J_RESPONSIBILITIES  VARCHAR2(1000),
    J_BENEFITS          VARCHAR2(1000),
    PRIMARY KEY (JOB_ID),
    FOREIGN KEY (MANAGER_ID) REFERENCES STAFF_USER(USER_ID) ON DELETE CASCADE,
    FOREIGN KEY (HR_STAFF_ID) REFERENCES STAFF_USER(USER_ID) ON DELETE CASCADE,
    FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENT(DEPARTMENT_ID) ON DELETE CASCADE,
    CHECK ((END_DATE is null) or (END_DATE > START_DATE))
);

CREATE TABLE RECRUITMENT_CANDIDATES(
    CAN_ID              CHAR(5),
    JOB_ID              CHAR(5),
    C_NAME              VARCHAR2(200)   NOT NULL,
    C_EMAIL             VARCHAR2(200)   NOT NULL,
    C_PHONE             VARCHAR2(200)   NOT NULL,
    C_CV                VARCHAR2(200)   NOT NULL,
    C_MESSAGE           VARCHAR2(200),
    APPLY_DATE          DATE            NOT NULL,
    EXPIRED_DATE        DATE            NOT NULL,
    PRIMARY KEY (CAN_ID),
    FOREIGN KEY (JOB_ID) REFERENCES RECRUITMENT(JOB_ID) ON DELETE CASCADE,
    CHECK (EXPIRED_DATE > APPLY_DATE)
);

CREATE TABLE RECRUITMENT_STAFF(
    JOB_ID          CHAR(5),
    USER_ID         CHAR(5),
    START_DATE      DATE        NOT NULL,
    END_DATE        DATE,
    
    PRIMARY KEY (JOB_ID, USER_ID),
    FOREIGN KEY (JOB_ID) REFERENCES RECRUITMENT(JOB_ID) ON DELETE CASCADE,
    FOREIGN KEY (USER_ID) REFERENCES STAFF_USER(USER_ID) ON DELETE CASCADE,
    CHECK ((END_DATE is null) or (END_DATE > START_DATE))
);