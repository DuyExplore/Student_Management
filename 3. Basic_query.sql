 USE Student_Management
 GO
 
 -- List of students from Faculty of "CNTT" class 2002-2006
 SELECT STUDENT.* FROM STUDENT
 LEFT JOIN CLASS ON CLASS.ID = STUDENT.ID_CLASS
 LEFT JOIN COURSE ON COURSE.ID = CLASS.ID_COURSE
 LEFT JOIN FACULTY ON FACULTY.ID = CLASS.ID_FACULTY
 WHERE 
 FACULTY.ID = 'CNTT'
AND COURSE.YEAR_BEGIN = 2002
AND COURSE.YEAR_END = 2006

-- Indicate the information (ID_STUDENT, full name, year of birth) of students who study earlier than the prescribed age
-- (according to the prescribed age, students must be 18 years old when starting the course)
SELECT STUDENT.ID, NAME, YEAR_BIRTH FROM STUDENT
LEFT JOIN CLASS ON CLASS.ID = STUDENT.ID_CLASS
LEFT JOIN COURSE ON COURSE.ID = CLASS.ID_COURSE
WHERE COURSE.YEAR_BEGIN - STUDENT.YEAR_BIRTH  < 18 

-- Indicate students of the 'CNTT', class 2002-2006 have not studied 'Cấu trúc dữ liệu 1'
SELECT DISTINCT STUDENT.* FROM STUDENT
LEFT JOIN CLASS ON STUDENT.ID_CLASS = CLASS.ID
LEFT JOIN COURSE ON COURSE.ID = CLASS.ID_COURSE
LEFT JOIN FACULTY ON FACULTY.ID = CLASS.ID_FACULTY
LEFT JOIN SUBJECT ON SUBJECT.ID_FACULTY = FACULTY.ID
WHERE 
CLASS.ID_FACULTY = 'CNTT'
AND SUBJECT.ID NOT LIKE N'Cấu trúc dữ liệu 1'
AND COURSE.YEAR_BEGIN = 2002
AND COURSE.YEAR_END = 2006

-- Show that the student failed to pass the exam (SCORE <5) in 'Cấu trúc dữ liệu 1' but did not retake the exam.
SELECT * FROM STUDENT
LEFT JOIN RESULT ON STUDENT.ID = RESULT.ID_STUDENT
LEFT JOIN SUBJECT ON SUBJECT.ID = RESULT.ID_SUBJECT
WHERE SUBJECT.NAME = N'Cấu trúc dữ liệu 1'
AND RESULT.SCORE < 5  
AND RESULT.TEST_TIME = 1 
AND STUDENT.ID NOT IN
		(
			SELECT STUDENT.ID FROM STUDENT
			LEFT JOIN RESULT ON STUDENT.ID = RESULT.ID_STUDENT
			LEFT JOIN SUBJECT ON SUBJECT.ID = RESULT.ID_SUBJECT
			WHERE SUBJECT.NAME LIKE N'Cấu trúc dữ liệu 1'
			AND RESULT.TEST_TIME > 1
		)

-- For each class in the 'CNTT' FACULTY, indicate the class ID, course ID, program NAME and number of students in that class
SELECT CLASS.ID, COURSE.ID, FACULTY.NAME, PROGRAM.NAME, COUNT(STUDENT.ID) AS NUMBER_OF_STUDENTS FROM CLASS
LEFT JOIN FACULTY ON FACULTY.ID = CLASS.ID_FACULTY
LEFT JOIN STUDENT ON CLASS.ID = STUDENT.ID_CLASS
LEFT JOIN PROGRAM ON PROGRAM.ID = CLASS.ID_PROGRAM
LEFT JOIN COURSE ON COURSE.ID = CLASS.ID_COURSE
WHERE FACULTY.ID = 'CNTT'
GROUP BY CLASS.ID, COURSE.ID, FACULTY.NAME, PROGRAM.NAME

-- Indicate the average score of the student with code 0212003 (the average score is only calculated on the student's last exam)
SELECT AVG(RESULT.SCORE) AS AVERAGE_SCORE FROM RESULT
LEFT JOIN (SELECT ID_SUBJECT, MAX(TEST_TIME) AS LAST_TIME FROM RESULT
WHERE RESULT.ID_STUDENT = '0212003'
GROUP BY ID_SUBJECT) TABLE2 
ON RESULT.ID_SUBJECT = TABLE2.ID_SUBJECT AND RESULT.TEST_TIME = TABLE2.LAST_TIME
WHERE ID_STUDENT = '0212003'
AND RESULT.TEST_TIME = TABLE2.LAST_TIME

-- W2: INTEGRATION QUERY
SELECT AVG(RESULT.SCORE) AS AVERAGE_SCORE FROM RESULT
WHERE RESULT.ID_STUDENT = '0212003'
	AND RESULT.TEST_TIME = (SELECT  MAX(TEST_TIME) AS LAST_TIME FROM RESULT RESULT2
								WHERE RESULT.ID_STUDENT = RESULT2.ID_STUDENT
								AND RESULT.ID_SUBJECT = RESULT2.ID_SUBJECT)
