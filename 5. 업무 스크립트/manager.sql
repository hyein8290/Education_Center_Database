-- 관리자, manager


-- 기초 정보 관리
-- 과정, 과목, 강의실, 교재


-- 과정 등록, 조회, 수정, 삭제

-- 과정 정보 등록
INSERT INTO tblCourse (seq, name, period) VALUES (seqCourse.nextVal, '테스트 과정', 7);

INSERT INTO tblEssentialSubject (seq, courseSeq, subjectSeq)
VALUES (seqEssentialSubject.nextVal,
			 (SELECT seq FROM tblCourse WHERE seq = '1'),
			 (SELECT seq FROM tblSubject WHERE seq = '22'));
             

-- 과정 정보 조회
SELECT seq    AS 과정번호,
       name   AS 과정이름,
       period AS 과정기간
FROM tblCourse
ORDER BY seq;


-- 과정 정보 세부정보 조회
-- 1. tblCourse에서 seq = 사용자가 선택한 과정번호로 조회한다.
SELECT seq    AS 과정번호,
       name   AS 과정이름,
       period AS 과정기간
FROM tblCourse
WHERE seq = 7;

-- 2. tblEssentialSubject에서 courseSeq = 사용자가 선택한 과정번호로 조회한다. 
SELECT * FROM tblessentialsubject WHERE courseseq = 7;


-- 과정 정보 수정
INSERT INTO tblEssentialSubject (seq,courseSeq,subjectSeq)
VALUES(seqEssentialSubject.nextVal,7,7); 

INSERT INTO tblEssentialSubject (seq,courseSeq,subjectSeq)
VALUES(seqEssentialSubject.nextVal,7,8);

DELETE FROM tblEsssentialsubject WHERE courseSeq = 7 AND subjectSeq = 5;

UPDATE tblCourse
SET name = '재밌고 즐거운 테스트 과정'
WHERE seq = 1;

UPDATE tblCourse
SET period = 5.5 --[5.5|6|7]
WHERE seq = 1;


-- 과정 정보 삭제
DELETE FROM tblessentialsubject WHERE courseseq = 7;
DELETE FROM tblCourse WHERE seq = 18;



-- 과목 등록, 조회, 수정, 삭제

-- 과목 정보 등록
INSERT INTO tblSubject (seq,name) VALUES (seqSubject.nextval, '자료구조');


-- 과목 정보 조회
SELECT seq  AS 과목번호,
       name AS 과목이름
FROM tblSubject;

CREATE OR REPLACE PROCEDURE procGetAvailTextbook(
    pSubjectSeq NUMBER,
    pResult OUT SYS_REFCURSOR
    )
IS
BEGIN

    OPEN pResult
        FOR
        SELECT *
        FROM tblTextBook
        WHERE subjectSeq = pSubjectSeq;

END;

DECLARE
    vSubjectSeq NUMBER := 3;
    vResult SYS_REFCURSOR;
    vRow tblTextbook%ROWTYPE;
BEGIN

    procGetAvailTextbook(vSubjectSeq, vResult);

    LOOP
        FETCH vResult INTO vRow;
        EXIT WHEN vResult%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(vRow.isbn || ' | ' || vRow.name || ' | ' || vRow.publisher);

    END LOOP;

END;


-- 과목 정보 수정
UPDATE tblSubject SET name = '자료구조' WHERE seq = 56;

-- 과목 정보 삭제
DELETE FROM tblSubject WHERE seq = 56;




-- 강의실 등록, 조회, 수정, 삭제

-- 강의실 정보 등록
INSERT INTO tblRoom VALUES (seqTblRoom.nextVal,'7강의실',26);

-- 강의실 정보 조회
SELECT seq AS 강의실번호,
       name AS 강의실명,
       person AS 정원 
FROM tblRoom;

-- 강의실 정보 수정
UPDATE tblRoom SET name = '7강의실' WHERE seq = 7;
UPDATE tblRoom SET name = '8강의실' , person =30 WHERE seq = 7;

-- 강의실 정보 삭제
DELETE FROM tblRoom WHERE seq= 7;




-- 교재 등록, 조회, 수정, 삭제

-- 교재 정보 등록
INSERT INTO tblTextbook(isbn, name, publisher, subjectSeq) 
	VALUES 
	(9788994735382, 
	'교재 테스트', 
	'테스트퍼블리셔', 
	(SELECT seq FROM tblSubject WHERE name = 'JAVA'));
    
-- 교재 정보 조회
SELECT t.isbn      AS "ISBN",
       t.name      AS "교재",
       t.publisher AS "출판사",
       s.name      AS "과목명"
FROM tblTextbook t INNER JOIN tblSubject s ON s.seq = t.subjectseq;

-- 교재 정보 수정
UPDATE tblTextbook SET name = '자바스크립트는 왜 저럴까?'  WHERE isbn = 9788994735381;

UPDATE tblTextBook 
SET isbn = 9788994733382 , name = '교재 테스트2' , publisher = '테스트 퍼블리셔2'  
WHERE isbn = 9788994735382;

-- 교재 정보 삭제
DELETE FROM tblTextBook WHERE isbn = 9788994733382;





-- 교사 계정 관리
-- 교사 명단 조회, 신규 교사 등록, 교사 검색, 교사 상세정보 조회 (개인정보), 교사 상세정보 수정 (개인정보), 
-- 교사 상세정보 조회 (강의정보), 교사 삭제

-- 교사 명단 조회
SELECT seq     AS 교사번호,
       name    AS 이름,
       ssn     AS 주민번호, 
       regDate AS 등록일,
       address AS 주소
FROM tblTeacher;

-- 신규 교사 등록
INSERT INTO tblTeacher VALUES (202112,'홍길동','123245-2345441','010-1111-2222','2021-12-02','서울특별시 도봉구');

-- 교사 검색
SELECT * FROM tblteacher WHERE seq = 201001;

SELECT * FROM tblteacher WHERE name = '허준혁';

SELECT * FROM tblteacher WHERE ssn = '871211-1541387';

SELECT * FROM tblteacher WHERE tel = '010-0873-8367';

-- 교사 상세정보 조회 (개인정보)
SELECT * FROM tblTeacher WHERE seq = 2021112;

-- 교사 상세정보 수정 (개인정보)
UPDATE tblTeacher SET name = '아무개' WHERE seq = 202112;
UPDATE tblTeacher SET ssn = '111111-1111111' WHERE seq = 202112;
UPDATE tblTeacher SET regDate = '2021-12-31' WHERE seq = 202112;
UPDATE tblTeacher SET address  = '경기도 의정부시' WHERE seq = 202112;

-- 교사 상세정보 조회 (강의정보)
SELECT 
    s.seq "과목번호", 
    s.name "과목명"
FROM tblteacher T INNER JOIN tblavailablesubject avs ON T.seq = avs.teacherseq
    INNER JOIN tblsubject S ON avs.subjectseq = S.seq
        WHERE T.seq = 201802;

SELECT
    s.name "개설과목명",
    os.startdate "과목시작날짜",
    os.enddate "과목종료날짜",
    c.name "과정명",
    oc.startdate "과정시작날짜",
    oc.enddate "과정종료날짜",
    tb.name "교재명",
    r.name "강의실",
    (CASE
        WHEN sysdate BETWEEN oc.startdate AND oc.enddate THEN '진행중'
        ELSE '종료'
    END) AS "진행여부"
FROM tblopensubject os INNER JOIN tblopencourse oc ON os.opencourseseq = oc.seq
    INNER JOIN tblsubject S ON S.seq = os.subjectseq
        INNER JOIN tblcourse C ON C.seq = oc.courseseq
            INNER JOIN tbltextbook tb ON tb.isbn = os.isbn
                INNER JOIN tblroom R ON R.seq = oc.roomseq
                    WHERE os.teacherseq = 201802
                        ORDER BY oc.startdate ASC, os.startdate ASC;
                        
-- 교사 삭제
DELETE tblTeacher WHERE seq = 202112;





-- 개설과정 관리
-- 개설과정 등록, 개설과정 목록 조회, 개설과정 상세정보 조회, 개설과정 수정, 개설과정 삭제


-- 개설과정 등록
INSERT INTO tblOpenCourse(seq, courseSeq, roomSeq, maxPerson, startDate, endDate)
VALUES (seqOpenCourse.nextVal,
        (SELECT seq
         FROM tblCourse
         WHERE name = '입력된 과정명'),
        (SELECT seq
         FROM tblRoom
         WHERE name = '입력된 강의실명'),
        입력된 최대정원,
        to_date('입력된 시작일', 'yyyy-mm-dd'),
        add_months(to_date('입력된 시작일', 'yyyy-mm-dd'),
        (SELECT period FROM tblCourse WHERE name = '입력된 과정명'));
        
-- 개설과정 목록 조회
CREATE OR REPLACE VIEW vwOpenCrs
AS
SELECT
    oc.seq AS "과정번호",
    c.name AS "과정이름",
    c.period AS "기간",
    r.name AS "강의실",
    COUNT(*) AS "등록 인원"
FROM tblopencourse oc INNER JOIN tblroom R ON oc.roomseq = R.seq
    INNER JOIN tblsugang S ON S.opencourseseq = oc.seq
        INNER JOIN tblcourse C ON C.seq = oc.courseseq
                GROUP BY oc.seq, c.name, c.period, r.name
                    ORDER BY oc.seq ASC;

SELECT * FROM vwOpenCrs;

-- 개설과정 상세정보 조회
CREATE OR REPLACE VIEW vwSubjectTeacherTextbook
AS
SELECT
    vo."개설과정번호",
    s.name AS "과목명",
    os.startdate || '~' || os.enddate AS "과목기간",
    b.name AS "교재명",
    t.name AS "교사명"
FROM vwopencourseroom vo INNER JOIN tblopensubject os ON os.opencourseseq = vo."개설과정번호"
        INNER JOIN tblsubject s ON os.subjectseq = s.seq
            INNER JOIN tbltextbook b ON os.isbn = b.isbn
                INNER JOIN tblteacher T ON os.teacherseq = T.seq;
                
SELECT
    "과목명",
    "과목기간",
    "교재명",
    "교사명"
FROM vwSubjectTeacherTextbook
    WHERE "개설과정번호" = 1;

SELECT
    st.name, 
    st.ssn, 
    st.tel, 
    st.regdate, 
    sg.status 
FROM tblstudent st INNER JOIN tblsugang sg ON sg.studentseq = st.seq
    WHERE sg.opencourseseq = 1;

SELECT * FROM vwOpenCourseRoom WHERE 개설과정번호 = 1


-- 개설과정 수정
-- 과정명, 과정기간(시작일, 종료일), 강의실명

-- 과정명
UPDATE tblOpenCourse SET name = '개설 과정 이름'
WHERE seq = 136; -- 선택된 개설과정번호

-- 과정 시작일, 종료일
UPDATE tblOpenCourse 
SET startDate = '시작일'
		endDate = add_months(to_date('시작일', 'yyyy-mm-dd'), 
												 (SELECT period 
													FROM tblCourse c 
														INNER JOIN tblOpenCourse oc ON oc.courseSeq = c.seq
												  WHERE oc.seq = 136))
WHERE seq = 136; -- 선택된 개설과정번호

UPDATE tblOpenCourse 
SET endDate = '종료일'
		startDate = add_months(to_date('종료일', 'yyyy-mm-dd'), 
												  (SELECT period 
													 FROM tblCourse c 
														INNER JOIN tblOpenCourse oc ON oc.courseSeq = c.seq
												   WHERE oc.seq = 136) * (-1))
WHERE seq = 136; -- 선택된 개설과정번호

-- 강의실명
UPDATE tblOpenCourse SET roomSeq = (SELECT seq FROM tblRoom WHERE name = '강의실명')
WHERE seq = 136; -- 선택된 개설과정번호


-- 개설과정 삭제
DELETE FROM tblOpenCourse WHERE seq = 136; 




-- 개설과목 관리
-- 개설과목 등록, 개설과목 조회, 개설과목 수정, 개설과목 삭제


-- 개설과목 등록
INSERT INTO tblOpenSubject (seq, openCourseSeq, subjectSeq, teacherSeq, isbn, startDate, endDate) 
VALUES (seqOpenSubject.nextVal,
        133, 
        (SELECT seq FROM tblSubject WHERE name = 'JAVA'), 
        (SELECT seq FROM tblTeacher WHERE name = '허준혁'), 
		(SELECT isbn FROM tblTextBook WHERE name = '오늘부터 개발자'), 
		'2021-12-03','2021-12-23');
                
-- 개설과목 조회
SELECT c.name AS "개설과정명",
       oc.startDate || '~' || oc.endDate AS "개설과정기간",
       s.name AS "개설과목명",
       os.startDate || '~' || os.endDate AS "개설과목기간",
       tb.name AS "교재명",
       t.name AS "교사명"
FROM tblOpenSubject os
    INNER JOIN tblOpenCourse oc ON os.openCourseSeq = oc.seq
    INNER JOIN tblCourse c ON c.seq = oc.courseSeq
    INNER JOIN tblSubject s ON s.seq = os.subjectSeq
    LEFT OUTER JOIN tblTextbook tb ON tb.isbn = os.isbn
    INNER JOIN tblTeacher t ON t.seq = os.teacherSeq
ORDER BY oc.seq DESC, 개설과목기간 ASC;

SELECT
    "개설과정명",
    "과정기간",
    "강의실명",
    "등록인원"
FROM vwOpenCourseRoom;

SELECT
    "과목명",
    "과목기간",
    "교재명",
    "교사명"
FROM vwSubjectTeacherTextbook;


-- 개설과목 수정
-- 개설과목명, 과목시작일, 과목종료일, 교재명, 교사명

-- 개설과목명
UPDATE tblOpenSubject 
SET name = '개설 과목 이름'
WHERE seq = 1;

-- 과목 시작일
UPDATE tblOpenSubject 
SET startDate = '시작일'
WHERE seq = 1;

-- 과정 종료일
UPDATE tblOpenSubject 
SET endDate = '종료일'
WHERE seq = 1;

-- 교재명
UPDATE tblOpenSubject 
SET isbn = '선택한 교재의 isbn'
WHERE seq = 1;

-- 교사명
UPDATE tblOpenSubject 
SET teacherSeq = '선택한 교사의 번호'
WHERE seq = 1;


-- 개설과목 삭제
DELETE FROM tblOpenSubject WHERE seq = 1; 





-- 교육생 관리 
-- 교육생 명단 조회, 신규 교육생 등록, 교육생 검색, 교육생 상세정보 조회 (개인정보), 교육생 상세정보 수정 (개인정보),
-- 교육생 상세정보 조회 (수강정보), 교육생 상세정보 수정 (수강정보), 교육생 삭제


-- 교육생 명단 조회
CREATE OR REPLACE VIEW vwStudent
AS
SELECT
    seq,
    name,
    ssn,
    tel,
    regdate
FROM tblStudent;

CREATE OR REPLACE VIEW vwSugangCount
AS
SELECT
    tblStudent.seq AS stseq,
    COUNT(*) AS cnt
FROM tblStudent INNER JOIN tblSugang
    ON tblSugang.studentSeq = tblStudent.seq
        GROUP BY tblstudent.seq;

CREATE OR REPLACE VIEW vwStudentSugang
AS
SELECT
    *
FROM vwStudent s INNER JOIN vwSugangCount c
    ON s.seq=c.stseq;


SELECT
    seq,
    name,
    ssn,
    tel,
    regdate,
    cnt
FROM vwStudentSugang;


-- 신규 교육생 등록
INSERT(seqStudent.nextVal,'교육생이름','주민번호','전화번호','등록일');


-- 교육생 검색
SELECT * FROM tblStudent WHERE seq = '교육생 번호(seq)';

SELECT * FROM tblStudent WHERE name = '교육생 이름(name)';

SELECT * FROM tblStudent WHERE ssn like  '교육생 주민번호(ssn)';

SELECT * FROM tblStudent WHERE tel like  '교육생 전화번호(tel)';


-- 교육생 상세정보 조회 (개인정보)
SELECT
    st.seq AS 교육생번호, 
    st.name AS 교육생이름, 
    st.ssn AS 주민등록번호, 
    st.tel AS 전화번호, 
    st.regdate AS 등록일, 
    cnt AS 수강횟수
FROM tblstudent st 
    INNER JOIN (SELECT studentSeq, COUNT(*) AS cnt FROM tblSugang GROUP BY studentSeq) sg 
        ON sg.studentSeq = st.seq
            WHERE st.seq = '교육생 번호';
            
            
-- 교육생 상세정보 수정 (개인정보)
UPDATE tblStudent SET seq  = '변경할 값' WHERE seq = '변경할 선정값';

UPDATE tblStudent SET ssn = '변경할 값' WHERE seq = '변경할 선정값(기본키)';

UPDATE tblStudent SET tel  = '변경할 값' WHERE seq = '변경할 선정값(기본키)';

-- 교육생 상세정보 조회 (수강정보)
SELECT oc.seq                            AS 개설과목번호,
       co.name                           AS 과정명,
       oc.startDate || '~' || oc.endDate AS 과정기간,
       ro.name                           AS 강의실,
       os.seq                            AS 개설과목번호,
       sb.name                           AS 과목명,
       os.startDate || '~' || os.endDate AS 과목기간
FROM tblStudent st
        INNER JOIN tblSugang su ON su.studentSeq = st.seq
        INNER JOIN tblOpenCourse oc ON oc.seq = su.openCourseSeq
        INNER JOIN tblCourse co ON co.seq = oc.courseSeq
        INNER JOIN tblRoom ro ON ro.seq = oc.roomSeq
        INNER JOIN tblOpenSubject os ON os.openCourseSeq = oc.seq
        INNER JOIN tblSubject sb ON sb.seq = os.subjectSeq
WHERE st.seq = 20100001;


-- 교육생 상세정보 수정 (수강정보)
UPDATE tblStudent SET 수료여부 ='변경할 값' WHERE 교육생번호 = '해당 테이블 기본키';
UPDATE tblOpenCourse SET 수료날짜 ='변경할 값' WHERE 교육생번호 = '해당 테이블 기본키';

-- 교육생 삭제
DELETE FROM tblStudent WHERE seq = '20100001';



-- 시험 관리 및 성적 조회
-- 개설과정 시험 정보 조회, 성적 정보 조회 (과목), 성적 정보 조회 (교육생)

-- 개설과정 시험 정보 조회
SELECT 
    os.seq AS 개설과목번호, 
    sb.name AS 과목명, 
    os.startDate || '~' || os.endDate AS 과목기간, 
    tc.name AS 교사이름, 
    osas.avgChulgyul AS 출결평균, 
    osas.avgPilgi AS 필기평균, 
    osas.avgSilgi AS 실기평균
FROM tblOpenSubject os 
    INNER JOIN tblSubject sb ON sb.seq = os.subjectSeq 
    INNER JOIN tblTeacher tc ON tc.seq = os.teacherSeq 
    INNER JOIN vwOpenSubAvgScore osas ON osas.openSubjectseq = os.seq 
ORDER BY openSubjectSeq;


-- 성적 정보 조회 (과목)
SELECT st.name   AS 교육생이름,
      chulgyul  AS 출결점수,
      pilgi     AS 필기점수,
      silgi     AS 실기점수,
      su.status AS 등록상태
FROM tblOpenSubject os
        INNER JOIN tblOpenCourse oc ON oc.seq = os.openCourseSeq
        INNER JOIN tblSugang su ON su.openCourseSeq = oc.seq
        INNER JOIN tblStudent st ON st.seq = su.studentSeq
        LEFT OUTER JOIN vwStudentScore vss ON vss.studentSeq = st.seq
                                          AND vss.sugangSeq = su.seq
                                          AND vss.openSubjectSeq = os.seq
WHERE os.seq = 508;


-- 성적 정보 조회 (교육생)
SELECT name AS 교육생이름,
       ssn  AS 주민번호
FROM tblStudent
WHERE seq = 20100001;

SELECT sb.name                           AS 과목명,
      vss.chulgyul                      AS 출결점수,
      vss.pilgi                         AS 필기점수,
      vss.silgi                         AS 실기점수,
      os.startDate || '~' || os.endDate AS 과목기간,
      tc.name                           AS 교사명,
      tb.name                           AS 교재명,
      oc.seq                            AS 과정번호,
      co.name                           AS 과정명,
      oc.startDate || '~' || oc.endDate AS 과정기간
FROM vwStudentScore vss
        INNER JOIN tblOpenSubject os ON os.seq = vss.openSubjectSeq
        INNER JOIN tblSubject sb ON sb.seq = os.subjectSeq
        INNER JOIN tblTeacher tc ON tc.seq = os.teacherSeq
        INNER JOIN tblOpenCourse oc ON oc.seq = os.seq
        INNER JOIN tblCourse co ON co.seq = oc.courseSeq
        INNER JOIN tblTextbook tb ON tb.isbn = os.isbn
WHERE studentSeq = 20100001;



-- 출결 관리
-- 출결 조회, 출결 조회 (기간별), 이용자 출결 조회, 이용자 출결 조회 (기간별)

-- 출결 조회
SELECT st.name AS 이름,
       vsa.normal AS 정상,
       vsa.late AS 지각,
       vsa.early AS 조퇴,
       vsa.goout AS 외출,
       vsa.sick AS 병가,
       vsa.ebsence AS 결석
FROM vwStudentAttend vsa
    INNER JOIN tblSugang s ON s.seq = vsa.sugangSeq
    INNER JOIN tblStudent st ON st.seq = s.StudentSeq;
    
-- 출결 조회 (기간별)
SELECT st.name AS 이름,
       vsa.normal AS 정상,
       vsa.late AS 지각,
       vsa.early AS 조퇴,
       vsa.goout AS 외출,
       vsa.sick AS 병가,
       vsa.ebsence AS 결석,
       oc.startDate ||'~'|| oc.endDate AS 과정기간
FROM vwStudentAttend vsa
    INNER JOIN tblSugang s ON s.seq = vsa.sugangSeq
    INNER JOIN tblStudent st ON st.seq = s.StudentSeq
    INNER JOIN tblOpenCourse oc ON s.OpenCourseSeq = oc.seq
WHERE oc.endDate BETWEEN '10/08/09' AND '11/08/09';


-- 이용자 출결 조회
SELECT DISTINCT sb.name                                    AS subjectName,
                st.name                                    AS studentName,
                TO_CHAR(at.regDate, 'yyyy-mm-dd')          AS regDate,
                CASE
                    WHEN at.type = '퇴근'
                        AND TO_CHAR(at.regDate, 'hh24:mi:ss') <= '17:50:00'
                        THEN '조퇴'
                    WHEN at.type = '출근'
                        AND TO_CHAR(at.regDate, 'hh24:mi:ss') >= '09:05:00'
                        THEN '지각'
                    WHEN at.type = '병가' THEN '병가'
                    ELSE '정상'
                    END                                    AS status,
                CASE WHEN at.type = '외출' THEN 'Y' END AS goOut
FROM tblAttend at
         INNER JOIN tblSugang su ON su.seq = at.sugangSeq
         INNER JOIN tblStudent st ON st.seq = su.studentSeq
         INNER JOIN tblOpenSubject os ON os.seq = at.openSubjectSeq
         INNER JOIN tblsubject sb ON sb.seq = os.subjectSeq
WHERE studentSeq = 20100001
ORDER BY regDate;

-- 이용자 출결 조회 (기간별)
SELECT DISTINCT sb.name                                    AS subjectName,
                st.name                                    AS studentName,
                TO_CHAR(at.regDate, 'yyyy-mm-dd')          AS regDate,
                CASE
                    WHEN at.type = '퇴근'
                        AND TO_CHAR(at.regDate, 'hh24:mi:ss') <= '17:50:00'
                        THEN '조퇴'
                    WHEN at.type = '출근'
                        AND TO_CHAR(at.regDate, 'hh24:mi:ss') >= '09:05:00'
                        THEN '지각'
                    WHEN at.type = '병가' THEN '병가'
                    ELSE '정상'
                    END                                    AS status,
                CASE WHEN at.type = '외출' THEN 'Y' END AS goOut
FROM tblAttend at
         INNER JOIN tblSugang su ON su.seq = at.sugangSeq
         INNER JOIN tblStudent st ON st.seq = su.studentSeq
         INNER JOIN tblOpenSubject os ON os.seq = at.openSubjectSeq
         INNER JOIN tblsubject sb ON sb.seq = os.subjectSeq
WHERE studentSeq = 20100001
      AND at.regDate BETWEEN '2010-04-01' AND '2021-04-30'
ORDER BY regDate;



-- 상담 일지 관리
-- 상담 일지 조회, 상담 일지 삭제

-- 상담 일지 조회
SELECT
    c.seq AS "상담번호",
    t.seq AS "교사번호",
    t.name AS "교사명",
    st.seq AS "교육생번호",
    st.name AS "교육생명",
    co.name AS "수강과정명",
    c.counseldate AS "상담날짜",
    c.contents AS "상담내용",
    c.regdate "작성날짜"
FROM tblcounsel c
    INNER JOIN tblopensubject os ON c.opensubjectseq = os.seq
    INNER JOIN tblTeacher t ON t.seq = os.teacherseq
    INNER JOIN tblSugang sg ON c.sugangseq = sg.seq
    INNER JOIN tblStudent st ON sg.studentseq = st.seq
    INNER JOIN tblopencourse oc ON oc.seq = os.opencourseseq
    INNER JOIN tblCourse co ON co.seq = oc.courseseq
    ORDER BY c.seq ASC;
    
-- 상담 일지 삭제
DELETE FROM tblCounsel WHERE seq = '상담 번호'; 



-- 취업 정보
-- 취업 정보 기록 조회
SELECT
        st.seq as "교육생번호",
        st.name as "교육생이름",
        co.name as "수강과정명",
        i.category as "취업분야",
        c.name as "기업이름",
        i.ibsadate as "입사날짜",
        i.career as "경력구분",
        i.salary as "연봉"
FROM tblStudent st
      INNER JOIN tblSugang s ON st.seq = s.studentseq
      INNER JOIN tblJobInfo i ON s.seq = i.sugangseq
      INNER JOIN tblcompany c ON c.seq = i.companyseq
      INNER JOIN tblopencourse opco ON s.opencourseseq = opco.seq
      INNER JOIN tblcourse co ON opco.courseseq = co.seq;
      
      
      
-- 교사 평가 관리
-- 교사 평가 점수 조회, 특정 교사의 평가 점수 상세 조회, 특정 교사의 개설과목 평가 점수 상세 조회, 개설과목 교사평가 완료 여부 조회

-- 교사 평가 점수 조회
SELECT t.seq AS 교사번호,
       t.name AS 교사이름,
       ROUND(AVG(r.Q1),2) AS "Q1 평균점수",
       ROUND(AVG(r.Q2),2) AS "Q2 평균점수",
       ROUND(AVG(r.Q3),2) AS "Q3 평균점수",
       ROUND(AVG(r.Q4),2) AS "Q4 평균점수",
       ROUND(AVG(r.Q5),2) AS "Q5 평균점수",
       ROUND(AVG((r.Q1+r.Q2+r.Q3+r.Q4+r.Q5) / 5), 2) AS "전체 평균 점수"
FROM tblTeacherRate r 
	INNER JOIN tblOpenSubject o ON o.seq = r.openSubjectSeq 
	INNER JOIN tblTeacher t ON t.seq = o.teacherSeq
GROUP BY rollup(t.seq, t.name)
HAVING t.name IS NOT NULL
       OR (t.seq IS NULL AND t.name is NULL);


-- 특정 교사의 평가 점수 상세 조회
SELECT s.seq AS "과목번호",
       s.name AS "과목명",
       ROUND(AVG(r.Q1),2) AS "Q1 평균점수",
       ROUND(AVG(r.Q2),2) AS "Q2 평균점수",
       ROUND(AVG(r.Q3),2) AS "Q3 평균점수",
       ROUND(AVG(r.Q4),2) AS "Q4 평균점수",
       ROUND(AVG(r.Q5),2) AS "Q5 평균점수",
       ROUND(AVG((r.Q1+r.Q2+r.Q3+r.Q4+r.Q5) / 5), 2) AS "전체 평균 점수"
FROM tblOpenSubject os
    INNER JOIN tblSubject s ON s.seq = os.subjectSeq
	  INNER JOIN tblTeacherRate r ON r.openSubjectSeq = os.seq
WHERE os.teacherSeq = 201001 -- 선택된 교사 번호
GROUP BY rollup(s.seq, s.name)
HAVING s.name IS NOT NULL
       OR (s.seq IS NULL AND s.name is NULL)
ORDER BY s.seq;


-- 특정 교사의 개설과목 평가 점수 상세 조회
SELECT os.seq AS "개설과목번호",
       s.name AS "개설과목명",
       CASE WHEN os.endDate IS NOT NULL THEN os.startDate || '~' || os.endDate
            ELSE NULL
       END AS "과목기간",
       ROUND(AVG(r.Q1),2) AS "Q1 평균점수",
       ROUND(AVG(r.Q2),2) AS "Q2 평균점수",
       ROUND(AVG(r.Q3),2) AS "Q3 평균점수",
       ROUND(AVG(r.Q4),2) AS "Q4 평균점수",
       ROUND(AVG(r.Q5),2) AS "Q5 평균점수",
       ROUND(AVG((r.Q1+r.Q2+r.Q3+r.Q4+r.Q5) / 5) ,2) AS "전체 평균 점수"
FROM tblOpenSubject os
    INNER JOIN tblTeacherRate r ON r.openSubjectSeq = os.seq
    INNER JOIN tblTeacher t ON t.seq = os.teacherSeq
    INNER JOIN tblSubject s ON s.seq = os.subjectSeq
WHERE t.seq = 201001 --선택된 교사번호
      AND s.seq = 1  --선택된 과목번호
GROUP BY rollup(os.seq, s.name, os.startDate, os.endDate)
HAVING os.enddate IS NOT NULL
       OR (os.seq IS NULL AND os.enddate IS NULL)
ORDER BY os.seq DESC nulls LAST;


-- 개설과목 교사평가 완료 여부 조회
SELECT oc.seq AS "개설과정번호",
       os.seq AS "개설과목번호",
       s.seq AS "학생번호",
       s.name AS "학생이름",
       CASE WHEN tr.sugangSeq IS NOT NULL THEN 'Y' END AS "평가완료여부"
FROM tblOpenCourse oc
    INNER JOIN tblSugang sg ON sg.openCourseSeq = oc.seq
    INNER JOIN tblOpenSubject os ON os.openCourseSeq = oc.seq
    INNER JOIN tblStudent s ON s.seq = sg.studentSeq
    LEFT OUTER JOIN tblTeacherRate tr ON tr.sugangSeq = sg.seq
WHERE os.teacherSeq = 201001 
      AND sg.status <> '중도포기'
GROUP BY oc.seq, os.seq, s.seq, s.name, tr.sugangSeq
ORDER BY os.seq DESC, oc.seq, s.seq;





-- 데이터 통계
-- 이용 인원 집계(연간), 이용 인원 집계 (월간), 과정 평가 통계, 취업 통계

-- 이용 인원 집계(연간)
SELECT to_char(a.regDate, 'YYYY') || '년도' AS 연도,
       COUNT(*) AS "전체 인원수",
       COUNT(CASE WHEN substr(st.ssn, 8, 1) = 1 THEN 1 END) AS "[남자]",
       COUNT(CASE WHEN substr(st.ssn, 8, 1) = 2 THEN 1 END) AS "[여자]",
       COUNT(CASE WHEN to_char(a.regDate, 'YYYY') - (19 || substr(st.ssn, 1, 2)) + 1 BETWEEN 10 AND 19 THEN 1 END) AS "[10대]",
       COUNT(CASE WHEN to_char(a.regDate, 'YYYY') - (19 || substr(st.ssn, 1, 2)) + 1 BETWEEN 20 AND 29 THEN 1 END) AS "[20대]",
       COUNT(CASE WHEN to_char(a.regDate, 'YYYY') - (19 || substr(st.ssn, 1, 2)) + 1 BETWEEN 30 AND 39 THEN 1 END) AS "[30대]",
       COUNT(CASE WHEN to_char(a.regDate, 'YYYY') - (19 || substr(st.ssn, 1, 2)) + 1 BETWEEN 40 AND 49 THEN 1 END) AS "[40대]",
       COUNT(CASE WHEN to_char(a.regDate, 'YYYY') - (19 || substr(st.ssn, 1, 2)) + 1 BETWEEN 50 AND 59 THEN 1 END) AS "[50대]"
FROM tblAttend a
    INNER JOIN tblSugang s ON s.seq = a.sugangSeq
    INNER JOIN tblStudent st ON st.seq = s.studentSeq
WHERE a.type = '출근'
GROUP BY to_char(a.regDate, 'YYYY')
ORDER BY 연도 DESC;


-- 이용 인원 집계 (월간)
SELECT to_char(a.regDate, 'MM') || '월' AS 월,
       COUNT(*) AS "전체 인원수",
       COUNT(CASE WHEN substr(st.ssn, 8, 1) = 1 THEN 1 END) AS "[남자]",
       COUNT(CASE WHEN substr(st.ssn, 8, 1) = 2 THEN 1 END) AS "[여자]",
       COUNT(CASE WHEN to_char(a.regDate, 'YYYY') - (19 || substr(st.ssn, 1, 2)) + 1 BETWEEN 10 AND 19 THEN 1 END) AS "[10대]",
       COUNT(CASE WHEN to_char(a.regDate, 'YYYY') - (19 || substr(st.ssn, 1, 2)) + 1 BETWEEN 20 AND 29 THEN 1 END) AS "[20대]",
       COUNT(CASE WHEN to_char(a.regDate, 'YYYY') - (19 || substr(st.ssn, 1, 2)) + 1 BETWEEN 30 AND 39 THEN 1 END) AS "[30대]",
       COUNT(CASE WHEN to_char(a.regDate, 'YYYY') - (19 || substr(st.ssn, 1, 2)) + 1 BETWEEN 40 AND 49 THEN 1 END) AS "[40대]",
       COUNT(CASE WHEN to_char(a.regDate, 'YYYY') - (19 || substr(st.ssn, 1, 2)) + 1 BETWEEN 50 AND 59 THEN 1 END) AS "[50대]"
FROM tblAttend a
    INNER JOIN tblSugang s ON s.seq = a.sugangSeq
    INNER JOIN tblStudent st ON st.seq = s.studentSeq
WHERE a.type = '출근'
      AND to_char(a.regDate, 'YYYY') = '2020' -- 선택한 연도
GROUP BY to_char(a.regDate, 'MM')
ORDER BY 월 ASC;

-- 과정 평가 통계
SELECT oc.seq AS "개설과정번호",
       oc.name AS "개설과정명",
       oc.startDate || '~' || oc.endDate AS "과정기간",
       ROUND(AVG(ocas.avgChulgyul + ocas.avgPilgi + ocas.avgSilgi), 2) AS "전체평균점수",
       ROUND(SUM(sa.normal) / (oc.endDate - oc.startDate + 1) / (oc.personnel - oc.giveup) * 100, 2) || '%' AS "출석률",
       oc.completed AS "이수인원",
       oc.giveup AS "중도포기인원",
       ROUND(oc.giveup / oc.personnel * 100 , 2) || '%' AS "중도포기율",
       ROUND(AVG(j.salary)) || '만원' AS "평균연봉"
FROM vwOpenCoursePersonnel oc
    INNER JOIN vwOpenCourAvgScore ocas ON ocas.openCourseSeq = oc.seq
    INNER JOIN tblSugang sg ON sg.openCourseSeq = oc.seq
    INNER JOIN vwStudentAttend sa ON sa.sugangSeq = sg.seq
    INNER JOIN tblJobInfo j ON j.sugangSeq = sg.seq
GROUP BY oc.seq, oc.name, oc.startDate, oc.endDate, oc.personnel, oc.completed, oc.giveup
HAVING oc.startDate BETWEEN '2021-05-20' AND '2021-05-25' --입력한 날짜
ORDER BY oc.seq DESC;

-- 취업 통계
SELECT TO_CHAR(oc.endDate, 'yyyy')                          AS 연도,
      COUNT(su.seq)                                        AS 이수인원,
      COUNT(ji.seq)                                        AS 취업자수,
      ROUND(COUNT(ji.seq) / COUNT(su.seq) * 100, 1) || '%' AS 취업률,
      ROUND(AVG(ji.salary)) || '만원'                        AS 평균연봉
FROM tblSugang su
        INNER JOIN tblOpenCourse oc ON oc.seq = su.openCourseSeq
        LEFT OUTER JOIN tblJobInfo ji ON ji.sugangSeq = su.seq
WHERE su.status = '이수완료'
GROUP BY TO_CHAR(oc.endDate, 'yyyy');





-- 회사 정보
-- 기업 정보 조회, 등록, 수정, 삭제

-- 기업 정보 조회
SELECT seq   AS "기업번호",
       name  AS "기업이름",
       type  AS "업종",
       scale AS "기업규모"
FROM tblCompany;

-- 기업 정보 등록
INSERT INTO tblCompany VALUES (seqCompany.nextval, '추가기업', '홈페이지 유지보수', '중소기업');

-- 기업 정보 수정
UPDATE tblCompany SET name = '추가기업' WHERE seq = 기업번호;
UPDATE tblCompany SET type = '플랫폼 제작 및 운영업' WHERE seq = 기업번호;
UPDATE tblCompany SET scale = '대기업' WHERE seq = 기업번호;

-- 기업 정보 삭제
DELETE FROM tblCompany WHERE seq = 3236;