-- 교육생 인적사항 정보 조회
SELECT * FROM tblstudent;

-- 교육생 개인 수강정보 조회

SELECT 
   s.studentSeq AS 학번, 
   d.name AS 이름, 
   c.name AS 과정명, 
   c.period AS 과정기간, 
   o.roomSeq AS 강의실번호, 
   j.subjectSeq AS 과목번호, 
   j.startDate AS 과목시작날짜, 
   j.endDate AS 과목종료날짜 
FROM tblSugang s 
   INNER JOIN tblOpenCourse o ON o.seq = s.openCourseSeq 
   INNER JOIN tblStudent d ON d.seq = s.studentSeq 
   INNER JOIN tblCourse c ON c.seq = o.courseSeq 
   INNER JOIN tblOpenSubject j ON o.seq = j.openCourseSeq 
WHERE s.studentSeq = (SELECT seq FROM tblStudent WHERE seq = '201001');


-- 교육생 개인 성적정보 조회


SELECT
    st.name AS 학생이름,
    ROUND(AVG(vos.avgchulgyul)) AS 출결점수,
    ROUND(AVG(vos.avgpilgi)) AS 필기점수 ,
    ROUND(AVG(vos.avgsilgi)) AS 실기점수
    
FROM vwOpensubavgscore vos 
INNER JOIN tblOpenSubject os ON os.seq = vos.opensubjectseq
INNER JOIN tblsubject s ON s.seq = os.subjectseq
INNER JOIN tblAttend a on os.seq = a.opensubjectseq
INNER JOIN tblSugang sg ON sg.seq = a.sugangseq
INNER JOIN tblstudent st ON st.seq = sg.studentseq
GROUP BY st.name;



--당일 교육생 출결 조회

SELECT (SELECT TO_CHAR(regDate, 'hh24:mi')
        FROM tblAttend
        WHERE sugangSeq = 3697
          AND TO_CHAR(regDate, 'yyyy-mm-dd') = '2021-12-07'
          AND type = '출근') AS 입실,
       (SELECT TO_CHAR(regDate, 'hh24:mi')
        FROM tblAttend
        WHERE sugangSeq = 3697
          AND TO_CHAR(regDate, 'yyyy-mm-dd') = '2021-12-07'
          AND type = '퇴근') AS 퇴실,
       (SELECT TO_CHAR(regDate, 'hh24:mi')
        FROM tblAttend
        WHERE sugangSeq = 3697
          AND TO_CHAR(regDate, 'yyyy-mm-dd') = '2021-12-07'
          AND type = '외출') AS 외출,
       (SELECT TO_CHAR(regDate, 'hh24:mi')
        FROM tblAttend
        WHERE sugangSeq = 3697
          AND TO_CHAR(regDate, 'yyyy-mm-dd') = '2021-12-07'
          AND type = '복귀') AS 복귀
FROM dual;


-- 교육생 과목 출결 조회
SELECT normal  AS 정상,
       late    AS 지각,
       early   AS 조퇴,
       goOut   AS 외출,
       sick    AS 병가,
       ebsence AS 결석
FROM vwStudentAttend sa
WHERE sugangSeq = 3697
  AND openSubjectSeq = 681;


-- 교육생 과정 출결 조회

SELECT SUM(normal)  AS 정상,
       SUM(late)    AS 지각,
       SUM(early)   AS 조퇴,
       SUM(goOut)   AS 외출,
       SUM(아픔)    AS 병가,
       SUM(ebsence) AS 결석
FROM vwStudentAttend sa
         INNER JOIN tblSugang su ON su.seq = sa.sugangSeq
         INNER JOIN tblOpenCourse oc ON oc.seq = su.openCourseSeq
WHERE su.seq = 3697


-- 교육생 조원평가 등록

INSERT INTO tblTeamRate (seq,teamSeq,sugangSeq,score,opinion) 
VALUES (tblTeamRateSeq.nextVal,조편성번호,수강번호,4,'완전 좋았어요');


-- 교육생 취업정보 등록

INSERT INTO tblJobInfo 
   (seq,sugangSeq,companySeq,ibsaDate,career,salary)
Values 
   (seqJobInfo.nextVal,'수강번호','취업분야','기업번호','2019-02-20','경력',5000);


-- 교육생 취업정보 조회

CREATE OR REPLACE VIEW vwJobInfoYearSalary
AS
SELECT
    TO_CHAR(ji.ibsadate, 'yyyy') AS "연도",
    ROUND(AVG(ji.salary)) AS "평균연봉",
    ROUND(AVG(CASE
        WHEN c.scale = '대기업' THEN ji.salary
    END)) AS "대기업",
    ROUND(AVG(CASE
        WHEN c.scale = '중견기업' THEN ji.salary
    END)) AS "중견기업",
    ROUND(AVG(CASE
        WHEN NOT c.scale IN ('대기업', '중견기업') THEN ji.salary
    END)) AS "기타"
FROM tbljobinfo ji INNER JOIN tblcompany c ON ji.companyseq = c.seq 
    GROUP BY TO_CHAR(ji.ibsadate, 'yyyy')
        ORDER BY TO_CHAR(ji.ibsadate, 'yyyy') ASC;

SELECT * FROM vwJobInfoYearSalary;


-- 교육생 과정별 취업정보 조회

SELECT c.seq AS "과정번호",
       c.name AS "과정명",
       ROUND(COUNT(j.seq) / COUNT(DECODE(s.status, '이수완료', 1)) * 100, 1) || '%' AS "취업율",
       ROUND(AVG(j.salary)) || '만원' AS "평균연봉"
FROM tblOpenCourse oc
    INNER JOIN tblCourse c ON c.seq = oc.courseSeq
    INNER JOIN tblSugang s ON s.openCourseSeq = oc.seq
    LEFT OUTER JOIN tblJobInfo j ON j.sugangSeq = s.seq
GROUP BY c.seq, c.name
ORDER BY c.seq ASC;


-- 교육생 연도별 취업정보 조회


CREATE OR REPLACE VIEW vwSugangEndYearCnt
AS
SELECT 
    TO_CHAR(enddate, 'yyyy') AS "year", 
    COUNT(*) AS "cnt" 
FROM tblsugang sg INNER JOIN tblopencourse oc ON sg.opencourseseq = oc.seq
    WHERE sg.status = '이수완료'
        GROUP BY TO_CHAR(enddate, 'yyyy') 
            ORDER BY TO_CHAR(enddate, 'yyyy') ASC;

SELECT * FROM vwSugangEndYearCnt;


-- 교육생 연도별, 기업별 취업정보 조회

CREATE OR REPLACE VIEW vwJobInfoYearRatio
AS
SELECT
    TO_CHAR(ji.ibsadate, 'yyyy') AS "year", 
    ROUND(COUNT(CASE
        WHEN c.scale = '대기업' THEN 1
    END)/COUNT(*) * 100, 2) AS "l",
    ROUND(COUNT(CASE
        WHEN c.scale = '중견기업' THEN 1
    END)/COUNT(*) * 100, 2) AS "m",
    ROUND(COUNT(CASE
        WHEN NOT c.scale IN ('대기업', '중견기업') THEN 1
    END)/COUNT(*)* 100, 2) AS "etc"
FROM tbljobinfo ji INNER JOIN tblcompany c ON ji.companyseq = c.seq 
    GROUP BY TO_CHAR(ji.ibsadate, 'yyyy')
        ORDER BY TO_CHAR(ji.ibsadate, 'yyyy') ASC;


-- 교육생 전체 취업정보 조회

 CREATE OR REPLACE VIEW vwJobInfoYearStat
AS
SELECT
    vj."year" AS "연도",
    vj."cnt" AS "취업자",
    vs."cnt" AS "이수자",
    ROUND(vj."cnt"/vs."cnt" * 100, 2)||'%' AS "취업률",
    vr."l"||'%' AS "대기업",
    vr."m"||'%' AS "중견기업",

    vr."etc"||'%' AS "기타" 
FROM vwJobInfoYearCnt vj INNER JOIN vwSugangEndYearCnt vs ON vs."year" = vj."year"
    INNER JOIN vwJobInfoYearRatio vr ON vr."year" = vj."year";

SELECT * FROM vwJobInfoYearStat;


-- 교육생 취업정보 등록
INSERT INTO tblJobInfo 
   (seq,sugangSeq,companySeq,ibsaDate,career,salary)
Values 
   (seqJobInfo.nextVal,'수강번호','취업분야','기업번호','2019-02-20','경력',5000);


-- 교육생 취업정보 삭제


DELETE FROM tblJobInfo WHERE seq = '삭제할번호'


-- 교육생 교사평가 등록

INSERT INTO 
tblTeacherRate(seq,openSubjectSeq,suangSeq,Q1,Q2,Q3,Q4,Q5,opinion) 
VALUES (tblTeacherRateSeq.nextVal, 과목 번호,수강 번호,3,3,4,2,5,null );