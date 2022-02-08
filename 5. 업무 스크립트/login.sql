-- 로그인, login


-- 관리자 로그인
CREATE OR REPLACE PROCEDURE procLogin_manager(
    pId tblManager.id%TYPE,
    pPassword tblManager.password%TYPE,
    pResult OUT NUMBER
)
AS
BEGIN
    SELECT COUNT(*) INTO pResult
    FROM tblManager
    WHERE id = pId
      AND password = pPassword;
END;

DECLARE
   vResult NUMBER;
BEGIN
   procLogin_manager('admin1', 'aaaa1234', vResult);
END;


-- 교사 로그인
CREATE OR REPLACE PROCEDURE procLogin_teacher(
    pTeacherSeq tblStudent.seq%TYPE,
    pSsn NUMBER,
    pResult OUT NUMBER
)
AS
BEGIN
    SELECT COUNT(*) INTO pResult
    FROM tblTeacher
    WHERE seq = pTeacherSeq
      AND SUBSTR(ssn, 8) = pSsn;
END;

DECLARE
   vResult NUMBER;
BEGIN
   procLogin_teacher(201001, 1541387, vResult);
END;


-- 교육생 로그인
CREATE OR REPLACE PROCEDURE procLogin_student(
    pStudentSeq tblStudent.seq%TYPE,
    pSsn NUMBER,
    pResult OUT NUMBER
)
AS
BEGIN
    SELECT COUNT(*) INTO pResult
    FROM tblStudent
    WHERE seq = pStudentSeq
      AND SUBSTR(ssn, 8) = pSsn;
END;

DECLARE
   vResult NUMBER;
BEGIN
   procLogin_student(20100001, 1017340, vResult);
END;
