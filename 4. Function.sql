USE Student_Management
GO

-- With 1 student ID and 1 faculty ID, check if the student is in this department (returns true or false)
CREATE FUNCTION CHECK_FACULTY 
(
	@ID_STUDENT VARCHAR(50),
	@ID_FACULTY VARCHAR(50)
)
RETURNS VARCHAR(10)
AS 
	BEGIN
		DECLARE  @RESULT VARCHAR(10)
			SET @RESULT = 'FALSE'
				IF (EXISTS (SELECT * FROM STUDENT
								LEFT JOIN CLASS ON CLASS.ID = STUDENT.ID_CLASS
								LEFT JOIN FACULTY ON FACULTY.ID = CLASS.ID_FACULTY
								WHERE STUDENT.ID = @ID_STUDENT
								AND FACULTY.ID = @ID_FACULTY
							)
					)
			SET @RESULT = 'TRUE'
		ELSE 		
			SET @RESULT = 'FALSE'
		RETURN @RESULT
	END
GO

SELECT DBO.CHECK_FACULTY('0212003','CNTT')
SELECT DBO.CHECK_FACULTY('0212003','VL')
GO
-- Calculate a student's final exam score in a particular subject
CREATE FUNCTION LAST_TIME_SCORE
(
	@ID_STUDENT VARCHAR(10),
	@ID_SUBJECT VARCHAR(10)
)
RETURNS FLOAT
AS
	BEGIN
		DECLARE @SCORE FLOAT;
			SET @SCORE = 0
				SELECT TOP 1 @SCORE = RESULT.SCORE FROM RESULT
					WHERE RESULT.ID_STUDENT = @ID_STUDENT
					AND RESULT.ID_SUBJECT = @ID_SUBJECT
					ORDER BY RESULT.TEST_TIME DESC
		RETURN @SCORE
	END
GO

SELECT DBO.LAST_TIME_SCORE('0212002','THT01')
SELECT DBO.LAST_TIME_SCORE('0212003','THT02')
GO

-- Calculate the average score of a student (note: the average score is calculated based on the last exam)
CREATE FUNCTION AVERAGE_SCORE_CAL 
(
	@ID_STUDENT VARCHAR(10)
)
RETURNS FLOAT

	BEGIN
		DECLARE @AVERAGE_SCORE FLOAT;
			SET @AVERAGE_SCORE = 0
				SELECT @AVERAGE_SCORE = AVG(RESULT.SCORE) FROM RESULT
					LEFT JOIN (SELECT ID_SUBJECT, MAX(TEST_TIME) AS LAST_TIME FROM RESULT
								WHERE RESULT.ID_STUDENT = @ID_STUDENT
									GROUP BY ID_SUBJECT) TABLE2 
					ON RESULT.ID_SUBJECT = TABLE2.ID_SUBJECT AND RESULT.TEST_TIME = TABLE2.LAST_TIME
				WHERE ID_STUDENT = @ID_STUDENT
				AND RESULT.TEST_TIME = TABLE2.LAST_TIME
		RETURN @AVERAGE_SCORE
	END
GO

SELECT DBO.AVERAGE_SCORE_CAL('0212002') AS AVERAGE_SCORE
SELECT DBO.AVERAGE_SCORE_CAL('0212003') AS AVERAGE_SCORE
GO

-- Enter 1 student ID and 1 subject ID, and return this student's scores on the exams for that subject.
CREATE FUNCTION CHECK_SUBJECT_SCORE
(
	@ID_STUDENT VARCHAR(10),
	@ID_SUBJECT VARCHAR(10)
)
RETURNS FLOAT
AS
	BEGIN
		DECLARE @SCORE FLOAT
			SET @SCORE = 0
				SELECT @SCORE = RESULT.SCORE  FROM RESULT 
					WHERE RESULT.ID_STUDENT = @ID_STUDENT
					AND RESULT.ID_SUBJECT = @ID_SUBJECT
		RETURN @SCORE
	END
GO

SELECT DBO.CHECK_SUBJECT_SCORE('0212003', 'THT02') AS SUBJECT_SCORE
GO

-- Input 1 student, return the list of subjects that this student must study.
CREATE FUNCTION CHECK_SUBJECT_MUST_LEARN
(
	@ID_STUDENT VARCHAR(10)
)
RETURNS TABLE
RETURN
	SELECT SUBJECT.NAME FROM SUBJECT
		LEFT JOIN FACULTY ON FACULTY.ID = SUBJECT.ID_FACULTY
		LEFT JOIN CLASS ON CLASS.ID_FACULTY = FACULTY.ID
		LEFT JOIN COURSE ON COURSE.ID = CLASS.ID_COURSE
		LEFT JOIN STUDENT ON STUDENT.ID_CLASS = CLASS.ID
		WHERE STUDENT.ID = @ID_STUDENT

GO

SELECT * FROM DBO.CHECK_SUBJECT_MUST_LEARN('0212003')
GO