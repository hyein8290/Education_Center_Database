-- 교사, teacher

-- 담당과목 관리
-- 담당 개설과목 조회, 진행중인 담당 개설과목 조회, 선택 개설과목 상세정보 조회, 선택 개설과목 배점 정보 등록

-- 담당 개설과목 조회
CREATE OR REPLACE VIEW vwTeacherSubDetail
AS
SELECT t.seq                         AS teacherseq,
       t.name                        AS teachername,
       os.seq                        AS osseq, 
       c.name                        AS coursename, 
       oc.startdate||'~'||oc.enddate AS  ocdate, 
       r.name                        AS roomname,
       s.name                        AS subjectname,
       os.startdate||'~'||os.enddate AS osdate,
       tb.name                       AS textbookname,
       sg."cnt"                      AS cnt,
       CASE WHEN sysdate < os.startDate THEN '강의예정'
            WHEN sysdate BETWEEN os.startDate AND os.endDate THEN '강의중' 
            WHEN sysdate > os.endDate THEN '강의종료'
       END                           AS subjectStatus
FROM tblopensubject os INNER JOIN tblteacher T ON T.seq = os.teacherseq 
    INNER JOIN tblsubject S ON S.seq = os.subjectseq
    INNER JOIN tblopencourse oc ON os.opencourseseq = oc.seq
    INNER JOIN tblcourse C ON C.seq = oc.courseseq
    INNER JOIN tblroom R ON oc.roomseq = R.seq
    INNER JOIN tbltextbook tb ON tb.isbn = os.isbn
    INNER JOIN (SELECT oc.seq, COUNT(*) AS "cnt" FROM tblsugang sg INNER JOIN tblopencourse oc ON sg.opencourseseq = oc.seq GROUP BY oc.seq) sg ON oc.seq = sg.seq
ORDER BY oc.seq ASC, os.startdate ASC;

SELECT osSeq         AS "개설과정번호",
       courseName    AS "과정명",
       ocDate        AS "과정기간",
       roomName      AS "강의실명",
       subjectName   AS "과목명",
       subjectStatus AS "강의스케줄",
       osDate        AS "과목기간",
       textbookname  AS "교재명",
       cnt           AS "등록인원"
FROM vwTeacherSubDetail
WHERE teacherSeq = 201006
ORDER BY ocDate DESC, osDate ASC;


-- 진행중인 담당 개설과목 조회
SELECT osSeq         AS "개설과정번호",
       courseName    AS "과정명",
       ocDate        AS "과정기간",
       roomName      AS "강의실명",
       subjectName   AS "과목명",
       subjectStatus AS "강의스케줄",
       osDate        AS "과목기간",
       textbookname  AS "교재명",
       cnt           AS "등록인원"
FROM vwTeacherSubDetail
WHERE teacherSeq = 201006
      AND subjectStatus = '강의중'
ORDER BY ocDate DESC, osDate ASC;


-- 선택 개설과목 상세정보 조회
-- 기본정보, 성적정보, 교육생정보, 취업정보, 교사평가

-- 기본정보
CREATE OR REPLACE PROCEDURE procOpenSubPageInfoSection(
    pOpenSubjectSeq NUMBER,
    presult OUT SYS_REFCURSOR
)
IS
BEGIN

    OPEN presult
        FOR SELECT *
            FROM vwOpenSubPageInfoSection
            WHERE openSubjectSeq = pOpenSubjectSeq;

END procOpenSubPageInfoSection;

DECLARE
   vResult SYS_REFCURSOR;
BEGIN
   procOpenSubPageInfoSection(489, vResult);
END;

-- 성적정보
CREATE OR REPLACE PROCEDURE procOpenSubPageScoreSection(
    pOpenSubjectSeq NUMBER,
    presult OUT SYS_REFCURSOR
)
IS
BEGIN

    OPEN presult
        FOR SELECT *
            FROM vwOpenSubPageScoreSection
            WHERE openSubjectSeq = pOpenSubjectSeq;

END procOpenSubPageScoreSection;

DECLARE
   vResult SYS_REFCURSOR;
BEGIN
   procOpenSubPageScoreSection(489, vResult);
END;


-- 교육생정보
CREATE OR REPLACE PROCEDURE procOpenSubPageStudentSection(
    pOpenSubjectSeq NUMBER,
    presult OUT SYS_REFCURSOR
)
IS
BEGIN

    OPEN presult
        FOR SELECT *
            FROM vwOpenSubPageStudentSection
            WHERE openSubjectSeq = pOpenSubjectSeq;

END procOpenSubPageStudentSection;

DECLARE
   vResult SYS_REFCURSOR;
BEGIN
   procOpenSubPageStudentSection(489, vResult);
END;

-- 취업정보
CREATE OR REPLACE PROCEDURE procOpenSubPageJobSection(
    pOpenSubjectSeq NUMBER,
    presult OUT SYS_REFCURSOR
)
IS
BEGIN

    OPEN presult
        FOR SELECT *
            FROM vwOpenSubPageJobSection
            WHERE openSubjectSeq = pOpenSubjectSeq;

END procOpenSubPageJobSection;

DECLARE
   vResult SYS_REFCURSOR;
BEGIN
   procOpenSubPageJobSection(489, vResult);
END;

-- 교사평가
CREATE OR REPLACE PROCEDURE procOpenSubTeacherRate(
    pOpenSubjectSeq NUMBER,
    presult OUT SYS_REFCURSOR
)
IS
BEGIN

    OPEN presult
        FOR SELECT *
            FROM vwOpenSubTeacherRate
            WHERE openSubjectSeq = 680;

END procOpenSubTeacherRate;

DECLARE
   vResult SYS_REFCURSOR;
BEGIN
   procOpenSubTeacherRate(489, vResult);
END;

-- 선택 개설과목 배점 정보 등록
INSERT
INTO tblScoreRatio (openSubjectSeq, chulgyulRatio, pilgiRatio, silgiRatio)
VALUES (1,20,35,45);




-- 시험 및 성적 정보 관리
-- 선택 개설과목 시험정보 조회, 선택 개설과목 시험정보 등록, 선택 개설과목 시험정보 수정, 선택 개설과목 성적 등록, 선택 개설과목 성적 수정

-- 선택 개설과목 시험정보 조회
SELECT *
FROM vwOpenSubTestSection
WHERE openSubjectSeq = 489;


-- 선택 개설과목 시험정보 등록
INSERT INTO tblTest VALUES (seqTest.nextVal,1,'필기','/data/test/2010/1/2010-04-09_pilgi.pdf','2010-04-09');

-- 선택 개설과목 시험정보 수정
UPDATE tblTest
SET testFile = '/data/test/2010/1/2010-04-09_pilgi.pdf',
    testDate = '2010-04-09'
WHERE openSubjectSeq = 1
  AND type = '필기';

-- 선택 개설과목 성적 등록
INSERT INTO tblRecord VALUES (seqRecord.nextVal, 1, 1, 85);

-- 선택 개설과목 성적 수정
UPDATE tblRecord SET score = 90 WHERE sugangSeq = 1;





-- 상담 정보 관리
-- 상담 일지 조회, 상담 일지 등록, 상담 일지 수정, 상담 일지 삭제

-- 상담 일지 조회
SELECT 
    c.seq as 상담번호,
    t.name as 교사이름,
    sd.name as 학생이름,
    c.counseldate as 상담일,
    c.regdate as 등록일,
    c.contents as 상담내용
FROM tblCounsel c
    INNER JOIN tblOpenSubject os ON c.opensubjectSeq = os.seq
    INNER JOIN tblTeacher t ON t.seq = os.teacherSeq
    INNER JOIN tblSugang s ON s.seq = c.sugangseq
    INNER JOIN tblStudent sd ON sd.seq = s.studentSeq
WHERE t.seq = 201001 
ORDER BY c.counselDate DESC;

-- 상담 일지 등록
INSERT INTO tblCounseling (seq, subjectSeq, sugangSeq, counselDate, contents, regDate) 
VALUES (seq.nextVal, 20, 80, '2021-11-20','취업관련 내용', sysdate);

-- 상담 일지 수정
UPDATE tblCounsel SET contents = 'vlavla', regdate= sysdate WHERE seq = 1200;

-- 상담 일지 삭제
DELETE FROM tblCounsel WHERE seq ='tblConuseling pk';





-- 교사평가 기타의견 조회
SELECT tr.seq  AS "평가번호",
       c.name  AS "과정명",
       s.name  AS "과목명",
       os.startDate || '~' || os.endDate AS "과목기간",
       opinion AS "의견"
FROM tblTeacherRate tr
    INNER JOIN tblOpenSubject os ON os.seq = tr.openSubjectSeq
    INNER JOIN tblSubject s ON s.seq = os.subjectSeq
    INNER JOIN tblOpenCourse oc ON oc.seq = os.openCourseSeq
    INNER JOIN tblCourse c ON oc.courseSeq = c.seq
WHERE tr.opinion IS NOT NULL
      AND os.teacherSeq = 201001
ORDER BY 과목기간 DESC;





-- 특정 과목 조회
SELECT s.seq AS "교육생번호",
       s.name AS "교육생이름",
       s.regDate AS "등록일",
       sg.status AS "수강상태"
FROM tblStudent s
    INNER JOIN tblSugang sg ON sg.studentSeq = s.seq
    INNER JOIN tblOpenSubject os ON os.openCourseSeq = sg.openCourseSeq
WHERE os.teacherSeq = 201001 
      AND os.seq = 162
ORDER BY s.seq;





-- 성적 출력 
SELECT ocs.osseq       AS "과목번호",
       ocs.coursename  AS "과정명",
       ocs.ocdate      AS "과정기간",
       ocs.roomname    AS "강의실",
       ocs.subjectname AS "과목명",
       ocs.osdate      AS "과목기간",
       ss.studentseq   AS "교육생번호",
       s.name          AS "교육생이름",
       ss.chulgyul     AS "출결점수",
       ss.pilgi        AS "필기점수",
       ss.silgi        AS "실기점수"
FROM vwStudentScore ss
    INNER JOIN vwOpenCourseSubject ocs ON ocs.osseq = ss.openSubjectSeq
    INNER JOIN tblStudent s ON s.seq = ss.studentseq
WHERE ocs.teacherSeq = 201001;