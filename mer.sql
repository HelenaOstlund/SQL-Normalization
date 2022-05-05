USE stidb;

DROP TABLE IF EXISTS Student;
CREATE TABLE Student AS SELECT DISTINCT Id, Name FROM UNF;
ALTER TABLE Student ADD PRIMARY KEY(Id);
ALTER TABLE Student MODIFY Id INTEGER NOT NULL AUTO_INCREMENT;
SELECT * FROM Student;
--------------------------------------------------------------------
DROP TABLE IF EXISTS School;
CREATE TABLE School AS
SELECT DISTINCT DISTINCT  0 AS Id, School AS Name, City FROM UNF;

SET @incrementValue = 0;
UPDATE School set Id = (select @incrementValue := @incrementValue + 1);
ALTER TABLE School ADD PRIMARY KEY(Id);
ALTER TABLE School MODIFY Id INTEGER NOT NULL AUTO_INCREMENT;

-----------------------------------------------------------------------------------
DROP TABLE IF EXISTS Student_School;
CREATE TABLE Student_School AS
SELECT DISTINCT UNF.Id AS StudentId, School.Id AS SchoolId FROM UNF
INNER JOIN School ON UNF.School = School.Name;

-----------------------------------------------------------------------------------
DROP VIEW IF EXISTS HobbyUNF;
CREATE VIEW HobbyUNF AS
SELECT Id, "We want first from all!" AS Cause, Hobbies, 
Trim(SUBSTRING_INDEX(Hobbies, ",", 1))  AS HOBBY FROM UNF
UNION
SELECT Id, "We want middle when three!", Hobbies, 
Trim(SUBSTRING_INDEX(SUBSTRING_INDEX(Hobbies, ",", -2),"," ,1))FROM UNF
WHERE (LENGTH(Hobbies) - LENGTH(REPLACE(Hobbies, ',', ''))=2)
UNION
SELECT Id, "We want last when more than one!", Hobbies, 
Trim(SUBSTRING_INDEX(Hobbies, ",", -1)) FROM UNF
WHERE (LENGTH(Hobbies) - LENGTH(REPLACE(Hobbies, ',', ''))>=1);

-----------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Hobby;
CREATE TABLE Hobby AS
SELECT DISTINCT 0 AS Id, Hobby AS Name FROM HobbyUNF WHERE Hobby <> "";
DELETE FROM Hobby WHERE Name = "Nothing";
SET @incrementValue = 0;
UPDATE Hobby SET Id = (SELECT @incrementValue := @incrementValue + 1);
ALTER TABLE Hobby ADD PRIMARY KEY(Id);
ALTER TABLE Hobby MODIFY Id INTEGER NOT NULL AUTO_INCREMENT;

---------------------------------------------------------------------------------
DROP TABLE IF EXISTS Student_Hobby;
CREATE TABLE Student_Hobby AS
SELECT HobbyUNF.Id as StudentId, Hobby.Id as HobbyId FROM HobbyUNF
INNER JOIN Hobby
ON HobbyUNF.Hobby = Hobby.Name;

----------------------------------------------------------------------------------
SELECT Student.Name, Group_concat(Hobby.Name) AS Hobbies
FROM Student
INNER JOIN Student_Hobby
ON Student.Id = Student_Hobby.StudentId
INNER JOIN Hobby
ON Student_Hobby.HobbyId = Hobby.Id
GROUP BY Student.Name;

----------------------------------------------------------------------------------
DROP TABLE IF EXISTS Grade;
CREATE TABLE Grade AS 
SELECT DISTINCT 0 As Id, 0 AS oldId, Grade As Grades FROM UNF;
SET @incrementValue = 0;
UPDATE Grade set OldId = (select @incrementValue := @incrementValue + 1);

UPDATE Grade SET Id = OldId;

UPDATE Grade
SET Id = 1
WHERE Grades = "Awessome";

UPDATE Grade
SET  Id = 2
WHERE Grades = "First-class";

UPDATE Grade
SET Id= 2
WHERE Grades = "Firstclass";

UPDATE Grade
SET Id = 9
WHERE Grades = "Eksellent";

UPDATE Grade
SET Id = 8
WHERE Grades = "Gorgetus";

SELECT * FROM Grade;
-----------------------------------------------------------------------
SELECT DISTINCT OldId FROM Grade
WHERE Grades IN ("Awessome", "First-class",  "Firstclass", "Eksellent", "Gorgetus");
----------------------------------------------------------------
DROP TABLE IF EXISTS Student_Grade;
CREATE TABLE Student_Grade AS
SELECT DISTINCT UNF.Id AS StudentId,
Grade.Id AS GradeId FROM UNF
INNER JOIN Grade
ON UNF.Grade = Grade.Grades;
DELETE FROM Grade
WHERE Grades IN ("Awessome", "First-class",  "Firstclass", "Eksellent", "Gorgetus");
ALTER TABLE Grade ADD PRIMARY KEY(Id);
ALTER TABLE Grade MODIFY Id INTEGER NOT NULL AUTO_INCREMENT;
------------------------------------------------------------------
DROP TABLE IF EXISTS Phone;
CREATE TABLE Phone AS
SELECT id as UserId, Name AS Name,'Job' AS Type, JobPhone AS Number 
FROM UNF
UNION SELECT id, Name, 'Home', HomePhone FROM UNF
UNION SELECT id, Name, 'Mobile1', MobilePhone1 FROM UNF
UNION SELECT id, Name, 'Mobile2', MobilePhone2 FROM UNF;

DELETE FROM Phone WHERE Number = "";
------------------------------------------------------------
SHOW TABLES;

DROP VIEW IF EXISTS StudentHobby;

CREATE VIEW StudentHobby AS
SELECT StudentId, Group_Concat(Hobby.Name) AS HobbyName
FROM Student_Hobby LEFT JOIN Hobby ON 
Student_Hobby.HobbyId = Hobby.Id GROUP BY StudentId;
---------------------------------------------------------------------------------------------

SELECT Student_School.StudentId, Student.Name, StudentHobby.HobbyName FROM Student_School 
LEFT JOIN StudentHobby 
ON Student_School.StudentId = StudentHobby.StudentId
LEFT JOIN Student ON Student_School.StudentId = Student.Id;

-----------------------------------------------------------------------------------------
DROP VIEW IF EXISTS STUDENT_GRADE_TEXT;
CREATE VIEW STUDENT_GRADE_TEXT AS
SELECT StudentId, Grades FROM Student_Grade 
LEFT JOIN Grade ON Student_Grade.GradeId = Grade.Id;

SELECT * FROM STUDENT_GRADE_TEXT;
------------------------------------------------------------------------------------------
DROP VIEW IF EXISTS UNFEN;
CREATE VIEW UNFEN AS
SELECT 
Student_School.StudentId, Student.Name, School.Name AS School, School.City, StudentHobby.HobbyName, Grades 
FROM Student_School 
LEFT JOIN School
ON Student_School.SchoolId = School.Id
LEFT JOIN StudentHobby 
ON Student_School.StudentId = StudentHobby.StudentId
LEFT JOIN Student 
ON Student_School.StudentId = Student.Id
LEFT JOIN STUDENT_GRADE_TEXT 
ON Student_School.StudentId = STUDENT_GRADE_TEXT.StudentId;

