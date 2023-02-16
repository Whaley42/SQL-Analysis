
-- Retrieve the student id and student name of those who have enrolled in at least one course 
-- offered by the Computer Science department AND have not enrolled in any Physics courses.
SELECT distinct(s.Sid), s.Fname, s.Lname
FROM student s, enroll e, course c
WHERE s.Sid = e.Sid AND e.Courseid = c.Courseid AND c.Dept = "Computer science" 
AND s.Sid NOT IN (SELECT e.Sid
					FROM course c, enroll e 
					WHERE c.Courseid = e.Courseid AND c.dept = "Physics");

-- Retrieve all of the student information for all students who have not taken any courses in the F22 quarter
SELECT *
FROM student s, enroll e
WHERE s.Sid = e.Sid AND e.quart <> "F22";


-- List the book information for books that have two authors: “Stephen King” and “Dean Koontz”.  

SELECT b.Isbn, b.Title, b.Publisher
FROM BOOK b, book_authors ba
WHERE b.Isbn = ba.Isbn AND b.Isbn IN (SELECT ba.Isbn
										FROM book_authors ba
                                        GROUP BY ba.Isbn 
                                        HAVING SUM(ba.Fname = "Stephen" AND ba.Lname = "King") >= 1
                                        AND SUM(ba.Fname = "Dean" AND ba.Lname = "Koontz") >= 1)
GROUP BY b.Isbn;


-- Retrieve all student information along with the course_id, quarter and grade for those students 
-- who have taken the same course more than twice.

SELECT s.Sid, s.Fname, s.Lname, e.Courseid, e.Quart, e.Grade
FROM Student s,(SELECT a.Sid, a.Courseid, a.Quart, a.Grade
				FROM enroll a, (SELECT Sid, Courseid
								FROM enroll
								GROUP BY Sid, Courseid
								HAVING count(*) > 1 ) b
				WHERE a.Sid = b.Sid
				AND a.Courseid = b.Courseid) e
WHERE s.Sid = e.Sid;








	