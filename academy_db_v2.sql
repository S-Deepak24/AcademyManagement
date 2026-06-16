-- ============================================================
--  ACADEMY MANAGEMENT SYSTEM — v2 (ISE-focused)
--  Subject : DBMS (BCS403) | BIT, Dept. of ISE
--  Team    : Deepak S (1BI24IS045), Dhanush M (1BI24IS048),
--            Gowri Shankar N (1BI24IS059), Madhu Manjunatha N (1BI25IS405)
--  Guide   : Mrs. Prakruthi D P
-- ============================================================
--  NEW IN v2:
--  - Only 2 departments: ISE and Mathematics
--  - 8 instructors (1 per subject, 7 ISE + 1 Maths)
--  - courses.instructor_id FK -> instructors (TAUGHT BY relationship)
-- ============================================================

DROP DATABASE IF EXISTS academy_db;
CREATE DATABASE academy_db;
USE academy_db;

-- ============================================================
--  PHASE 1 : CREATE TABLES
-- ============================================================

CREATE TABLE departments (
    dept_id     INT          PRIMARY KEY AUTO_INCREMENT,
    dept_name   VARCHAR(80)  NOT NULL UNIQUE,
    hod_name    VARCHAR(100)
);

CREATE TABLE instructors (
    instructor_id INT          PRIMARY KEY AUTO_INCREMENT,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    dept_id       INT          NOT NULL,
    hire_date     DATE,
    salary        DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE students (
    student_id      INT          PRIMARY KEY AUTO_INCREMENT,
    usn             VARCHAR(15)  NOT NULL UNIQUE,
    full_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    age             INT          CHECK (age >= 16),
    dept_id         INT,
    current_sem     INT          CHECK (current_sem BETWEEN 1 AND 8),
    enrollment_date DATE         DEFAULT (CURRENT_DATE),
    cgpa            DECIMAL(4,2) DEFAULT 0.00,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- courses now links to BOTH departments (OFFERS) and instructors (TAUGHT BY)
CREATE TABLE courses (
    course_id     INT          PRIMARY KEY AUTO_INCREMENT,
    course_code   VARCHAR(10)  NOT NULL UNIQUE,
    course_name   VARCHAR(100) NOT NULL,
    dept_id       INT          NOT NULL,
    instructor_id INT,
    sem           INT          CHECK (sem BETWEEN 1 AND 8),
    credits       INT          DEFAULT 3,
    max_students  INT          DEFAULT 60,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (instructor_id) REFERENCES instructors(instructor_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE enrollments (
    student_id  INT     NOT NULL,
    course_id   INT     NOT NULL,
    sem         INT     NOT NULL CHECK (sem BETWEEN 1 AND 8),
    marks       INT     CHECK (marks BETWEEN 0 AND 100),
    grade       VARCHAR(2),
    grade_points INT,
    enrolled_date DATE  DEFAULT (CURRENT_DATE),
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(course_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE sgpa_records (
    record_id    INT          PRIMARY KEY AUTO_INCREMENT,
    student_id   INT          NOT NULL,
    sem          INT          NOT NULL CHECK (sem BETWEEN 1 AND 8),
    sgpa         DECIMAL(4,2) NOT NULL,
    calculated_at DATETIME    DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_student_sem (student_id, sem),
    FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE audit_log (
    log_id      INT          PRIMARY KEY AUTO_INCREMENT,
    table_name  VARCHAR(50)  NOT NULL,
    operation   VARCHAR(10)  NOT NULL,
    changed_by  VARCHAR(100),
    changed_at  DATETIME     DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);

-- ============================================================
--  PHASE 2 : DEPARTMENTS (only 2 now)
-- ============================================================

INSERT INTO departments (dept_name, hod_name) VALUES
    ('Information Science and Engineering', 'Dr. Ramesh Kumar'),
    ('Mathematics',                         'Dr. Meena Iyer');

-- ============================================================
--  PHASE 3 : INSTRUCTORS — 1 per subject (7 ISE + 1 Maths)
--  Placeholder names — edit later with real teacher names
-- ============================================================

INSERT INTO instructors (full_name, email, dept_id, hire_date, salary) VALUES
    ('Dr. Mercy S (DAA)',         'ise.faculty1@bit.edu', 1, '2018-07-01', 80000.00), -- BCS401
    ('Prof. Priya N V (Adv Java)',    'ise.faculty2@bit.edu', 1, '2019-01-15', 78000.00), -- BIS402
    ('Prof. Prakruthi D P (DBMS)',        'prakruthi.dp@bit.edu', 1, '2017-06-01', 82000.00), -- BCS403
    ('Prof. Pavithra N (DAA Lab)',     'ise.faculty4@bit.edu', 1, '2020-08-10', 70000.00), -- BCSL404
    ('Prof. Vedashree (DMS)',         'maths.faculty@bit.edu', 2, '2016-07-01', 75000.00), -- BCS405A
    ('Prof. Prameela R (UI/UX)',       'ise.faculty6@bit.edu', 1, '2021-01-10', 68000.00), -- BCS406C
    ('Prof. Padmanabha J (Bio Inspired)','ise.faculty7@bit.edu', 1, '2019-09-01', 71000.00), -- BEAB407
    ('Prof. Shilpa T (UHV)',         'ise.faculty8@bit.edu', 1, '2018-03-15', 69000.00); -- BUH408

-- ============================================================
--  PHASE 4 : ISE 4TH SEM COURSES — linked to instructors
--  instructor_id 1-8 maps to the 8 rows inserted above in order
-- ============================================================

INSERT INTO courses (course_code, course_name, dept_id, instructor_id, sem, credits, max_students) VALUES
('BCS401',  'Design and Analysis of Algorithms', 1, 1, 4, 4, 60),
('BIS402',  'Advanced Java',                     1, 2, 4, 4, 60),
('BCS403',  'Database Management Systems',       1, 3, 4, 4, 60),
('BCSL404', 'DAA Laboratory',                    1, 4, 4, 1, 60),
('BCS405A', 'Discrete Mathematical Structures',  2, 5, 4, 3, 60),
('BCS406C', 'UI/UX',                             1, 6, 4, 1, 60),
('BEAB407', 'Bio Inspired Engineering',          1, 7, 4, 2, 60),
('BUH408',  'Universal Human Values',            1, 8, 4, 1, 60);

-- ============================================================
--  PHASE 5 : YOUR 4 GROUP MEMBERS AS STUDENTS
-- ============================================================

INSERT INTO students (usn, full_name, email, age, dept_id, current_sem, enrollment_date) VALUES
('1BI24IS045', 'Deepak S',           'sdeepak24006@gmail.com',      20, 1, 4, '2024-08-01'),
('1BI24IS048', 'Dhanush M',          'mdhanush69@gmail.com',         20, 1, 4, '2024-08-01'),
('1BI24IS059', 'Gowri Shankar N',    'gowrishankar032006@gmail.com', 20, 1, 4, '2024-08-01'),
('1BI25IS405', 'Madhu Manjunatha N', 'mmadhu24065@gmail.com',        20, 1, 4, '2024-08-01');

-- ============================================================
--  PHASE 6 : ENROLLMENTS (4 students x 8 subjects = 32 rows)
--  Course IDs: 1=BCS401, 2=BIS402, 3=BCS403, 4=BCSL404,
--              5=BCS405A, 6=BCS406C, 7=BEAB407, 8=BUH408
-- ============================================================

INSERT INTO enrollments (student_id, course_id, sem, marks, grade, grade_points) VALUES
-- Deepak S (student_id = 1)
(1, 1, 4,  88, 'A+', 9),
(1, 2, 4,  85, 'A+', 9),
(1, 3, 4,  92, 'O',  10),
(1, 4, 4,  80, 'A+', 9),
(1, 5, 4,  75, 'A',  8),
(1, 6, 4,  82, 'A+', 9),
(1, 7, 4,  78, 'A',  8),
(1, 8, 4,  90, 'O',  10),

-- Dhanush M (student_id = 2)
(2, 1, 4,  82, 'A+', 9),
(2, 2, 4,  88, 'A+', 9),
(2, 3, 4,  85, 'A+', 9),
(2, 4, 4,  78, 'A',  8),
(2, 5, 4,  80, 'A+', 9),
(2, 6, 4,  75, 'A',  8),
(2, 7, 4,  72, 'A',  8),
(2, 8, 4,  88, 'A+', 9),

-- Gowri Shankar N (student_id = 3)
(3, 1, 4,  78, 'A',  8),
(3, 2, 4,  80, 'A+', 9),
(3, 3, 4,  88, 'A+', 9),
(3, 4, 4,  75, 'A',  8),
(3, 5, 4,  70, 'A',  8),
(3, 6, 4,  78, 'A',  8),
(3, 7, 4,  68, 'B+', 7),
(3, 8, 4,  85, 'A+', 9),

-- Madhu Manjunatha N (student_id = 4)
(4, 1, 4,  75, 'A',  8),
(4, 2, 4,  78, 'A',  8),
(4, 3, 4,  82, 'A+', 9),
(4, 4, 4,  72, 'A',  8),
(4, 5, 4,  68, 'B+', 7),
(4, 6, 4,  80, 'A+', 9),
(4, 7, 4,  74, 'A',  8),
(4, 8, 4,  82, 'A+', 9);

-- ============================================================
--  PHASE 7 : TRIGGERS
-- ============================================================

DELIMITER $$

CREATE TRIGGER trg_enroll_insert
AFTER INSERT ON enrollments FOR EACH ROW
BEGIN
    INSERT INTO audit_log(table_name,operation,changed_by,description) VALUES(
        'enrollments','INSERT',CURRENT_USER(),
        CONCAT('Student ID ',NEW.student_id,' enrolled in Course ID ',NEW.course_id,
               ' | Sem:',NEW.sem,' | Marks:',IFNULL(NEW.marks,'NULL'),
               ' | Grade:',IFNULL(NEW.grade,'NULL'))
    );
END$$

CREATE TRIGGER trg_enroll_update
AFTER UPDATE ON enrollments FOR EACH ROW
BEGIN
    INSERT INTO audit_log(table_name,operation,changed_by,description) VALUES(
        'enrollments','UPDATE',CURRENT_USER(),
        CONCAT('Student ID ',NEW.student_id,' | Course ID ',NEW.course_id,
               ' | Marks:',IFNULL(OLD.marks,'NULL'),' -> ',IFNULL(NEW.marks,'NULL'),
               ' | Grade:',IFNULL(OLD.grade,'NULL'),' -> ',IFNULL(NEW.grade,'NULL'),
               ' | GradePoints:',IFNULL(OLD.grade_points,'NULL'),' -> ',IFNULL(NEW.grade_points,'NULL'))
    );
END$$

CREATE TRIGGER trg_enroll_delete
AFTER DELETE ON enrollments FOR EACH ROW
BEGIN
    INSERT INTO audit_log(table_name,operation,changed_by,description) VALUES(
        'enrollments','DELETE',CURRENT_USER(),
        CONCAT('Student ID ',OLD.student_id,' removed from Course ID ',OLD.course_id,
               ' | Grade was:',IFNULL(OLD.grade,'NULL'))
    );
END$$

DELIMITER ;

-- ============================================================
--  PHASE 8 : STORED PROCEDURE WITH CURSOR
-- ============================================================

DELIMITER $$

CREATE PROCEDURE calculate_sgpa(IN p_student_id INT, IN p_sem INT)
BEGIN
    DECLARE v_grade_points  INT;
    DECLARE v_credits       INT;
    DECLARE v_total_points  DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total_credits INT           DEFAULT 0;
    DECLARE v_sgpa          DECIMAL(4,2);
    DECLARE v_cgpa          DECIMAL(4,2);
    DECLARE done            BOOLEAN DEFAULT FALSE;

    DECLARE cur_sem CURSOR FOR
        SELECT e.grade_points, c.credits
        FROM   enrollments e
        JOIN   courses c ON e.course_id = c.course_id
        WHERE  e.student_id = p_student_id
          AND  e.sem = p_sem
          AND  e.grade_points IS NOT NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_sem;
    sem_loop: LOOP
        FETCH cur_sem INTO v_grade_points, v_credits;
        IF done THEN LEAVE sem_loop; END IF;
        SET v_total_points  = v_total_points  + (v_grade_points * v_credits);
        SET v_total_credits = v_total_credits + v_credits;
    END LOOP;
    CLOSE cur_sem;

    SET v_sgpa = IF(v_total_credits > 0, ROUND(v_total_points/v_total_credits,2), 0.00);

    INSERT INTO sgpa_records (student_id, sem, sgpa)
    VALUES (p_student_id, p_sem, v_sgpa)
    ON DUPLICATE KEY UPDATE sgpa=v_sgpa, calculated_at=CURRENT_TIMESTAMP;

    SELECT ROUND(AVG(sgpa),2) INTO v_cgpa
    FROM sgpa_records WHERE student_id = p_student_id;

    UPDATE students SET cgpa = v_cgpa WHERE student_id = p_student_id;

    SELECT s.usn, s.full_name, p_sem AS semester, v_sgpa AS sgpa, v_cgpa AS cgpa
    FROM students s WHERE s.student_id = p_student_id;
END$$

DELIMITER ;

-- ============================================================
--  PHASE 9 : VIEWS
-- ============================================================

-- Marksheet now also shows which instructor teaches the course
CREATE VIEW vw_marksheet AS
SELECT s.usn, s.full_name AS student_name, d.dept_name,
       s.current_sem AS sem, c.course_code, c.course_name,
       c.credits, i.full_name AS instructor_name,
       e.marks, e.grade, e.grade_points
FROM enrollments e
JOIN students s    ON e.student_id = s.student_id
JOIN courses c     ON e.course_id  = c.course_id
LEFT JOIN departments d ON s.dept_id = d.dept_id
LEFT JOIN instructors i ON c.instructor_id = i.instructor_id
ORDER BY s.usn, c.course_code;

CREATE VIEW vw_results AS
SELECT s.usn, s.full_name, d.dept_name, sr.sem, sr.sgpa, s.cgpa
FROM sgpa_records sr
JOIN students s    ON sr.student_id = s.student_id
LEFT JOIN departments d ON s.dept_id = d.dept_id
ORDER BY s.usn, sr.sem;

CREATE VIEW vw_dept_performance AS
SELECT d.dept_name,
       COUNT(DISTINCT s.student_id) AS total_students,
       ROUND(AVG(s.cgpa),2)         AS avg_cgpa,
       MAX(s.cgpa)                  AS highest_cgpa,
       MIN(s.cgpa)                  AS lowest_cgpa
FROM departments d
LEFT JOIN students s ON s.dept_id = d.dept_id
GROUP BY d.dept_id, d.dept_name;

-- NEW: course-wise view showing subject + instructor
CREATE VIEW vw_course_instructor AS
SELECT c.course_code, c.course_name, c.credits, c.sem,
       d.dept_name AS offered_by_dept,
       i.full_name AS instructor_name,
       di.dept_name AS instructor_dept
FROM courses c
LEFT JOIN departments d  ON c.dept_id = d.dept_id
LEFT JOIN instructors i  ON c.instructor_id = i.instructor_id
LEFT JOIN departments di ON i.dept_id = di.dept_id
ORDER BY c.course_code;

-- ============================================================
--  PHASE 10 : CALCULATE SGPA FOR ALL 4 MEMBERS
-- ============================================================

CALL calculate_sgpa(1, 4);
CALL calculate_sgpa(2, 4);
CALL calculate_sgpa(3, 4);
CALL calculate_sgpa(4, 4);

-- ============================================================
--  PHASE 11 : FINAL VERIFICATION
-- ============================================================

-- Departments
SELECT * FROM departments;

-- Instructors with their department
SELECT i.instructor_id, i.full_name, d.dept_name
FROM instructors i JOIN departments d ON i.dept_id = d.dept_id;

-- Courses with instructor assigned
SELECT * FROM vw_course_instructor;

-- Students with CGPA
SELECT student_id, usn, full_name, cgpa FROM students ORDER BY usn;

-- Full marksheet with instructor names
SELECT * FROM vw_marksheet;

-- Results (SGPA + CGPA)
SELECT * FROM vw_results;

-- Department performance
SELECT * FROM vw_dept_performance;

-- Row count check
SELECT 'departments'  AS tbl, COUNT(*) AS total FROM departments  UNION ALL
SELECT 'instructors', COUNT(*) FROM instructors UNION ALL
SELECT 'students',    COUNT(*) FROM students    UNION ALL
SELECT 'courses',     COUNT(*) FROM courses     UNION ALL
SELECT 'enrollments', COUNT(*) FROM enrollments UNION ALL
SELECT 'sgpa_records',COUNT(*) FROM sgpa_records UNION ALL
SELECT 'audit_log',   COUNT(*) FROM audit_log;

-- ============================================================
--  END OF SCRIPT v2
--  7 tables | 3 triggers | 1 stored procedure with cursor
--  4 views  | 2 departments | 8 instructors | 8 courses
--  4 students | 32 enrollments
-- ============================================================
