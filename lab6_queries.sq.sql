-- ============================================
-- VUA-SEN307 Lab 6: Aggregates, Grouping and Subqueries
-- Name: YOUR NAME   Matric: VUG/SEN/25/14777
-- ============================================

USE sen307_vug_sen_25_14777;
-- Task 1: Students per course (including courses with zero students)
SELECT c.course_title, COUNT(e.student_id) AS total_students
FROM Course c
LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_title
ORDER BY total_students DESC;
-- Explanation: This counts the students in each course. LEFT JOIN keeps
-- courses that have no enrolments, GROUP BY makes one row per course, and
-- ORDER BY puts the biggest courses first. An empty course gives 0 and not 1
-- because the LEFT JOIN row has NULL in e.student_id, and
-- COUNT(e.student_id) skips NULL values.

-- Task 2: Courses with more than N students (HAVING)
-- Threshold 3
SELECT c.course_title, COUNT(e.student_id) AS total_students
FROM Course c
LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_title
HAVING COUNT(e.student_id) > 3;

-- Threshold 5
SELECT c.course_title, COUNT(e.student_id) AS total_students
FROM Course c
LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_title
HAVING COUNT(e.student_id) > 5;

-- Threshold 7
SELECT c.course_title, COUNT(e.student_id) AS total_students
FROM Course c
LEFT JOIN Enrolment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_title
HAVING COUNT(e.student_id) > 7;
-- Explanation: These are the same query with only the number changed. HAVING
-- filters the groups after the counting is done, so fewer courses remain as
-- the threshold goes up. HAVING is used and not WHERE because the count only
-- exists after GROUP BY, so it cannot be checked row by row.

-- Task 3: Average number of courses per student (including students with 0)
SELECT ROUND(AVG(course_count), 2) AS avg_courses_per_student
FROM (
    SELECT s.student_id, COUNT(e.course_id) AS course_count
    FROM Student s
    LEFT JOIN Enrolment e ON s.student_id = e.student_id
    GROUP BY s.student_id
) AS per_student;
-- Explanation: The inner query counts how many courses each student takes.
-- LEFT JOIN keeps students with no courses, so they count as 0. The outer
-- query averages those counts and ROUND limits the answer to 2 decimal places.
-- An INNER JOIN would leave out the students with 0 courses and give a
-- higher, wrong average.

-- Task 4: Students not enrolled in any course (non-correlated subquery)
SELECT student_id, full_name
FROM Student
WHERE student_id NOT IN (SELECT student_id FROM Enrolment);
-- Explanation: The inner query runs once and returns the ids of all enrolled
-- students. The outer query keeps only the students whose id is not in that
-- list. This gives the same students as Week 7 Task 3b, which used a LEFT
-- JOIN with IS NULL, so both methods reach the same answer.

-- Task 5: Student with the most enrolments in each department
-- (correlated subquery, ties allowed)
SELECT d.dept_name, s.full_name,
       (SELECT COUNT(*) FROM Enrolment e
        WHERE e.student_id = s.student_id) AS courses
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
WHERE (SELECT COUNT(*) FROM Enrolment e
       WHERE e.student_id = s.student_id)
    = (SELECT MAX(t.cnt)
       FROM (SELECT s2.dept_id, COUNT(e2.student_id) AS cnt
             FROM Student s2
             LEFT JOIN Enrolment e2 ON s2.student_id = e2.student_id
             GROUP BY s2.student_id, s2.dept_id) AS t
       WHERE t.dept_id = s.dept_id)
ORDER BY d.dept_name;
-- Explanation: For each student, the first subquery counts their enrolments.
-- The last subquery finds the highest enrolment count among students in the
-- same department by using s.dept_id from the outer query, so it runs again
-- for every outer row. A student is kept only if their count equals that
-- department maximum. If two students tie, both are shown.


