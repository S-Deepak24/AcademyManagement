# 🎓 Academics Management System

A full-stack Java web application for managing college academic records, built as a mini project for **Database Management Systems (BCS403)** and **Advanced Java (BIS402)** — 4th Semester ISE, Bangalore Institute of Technology.

---

## 📌 About the Project

The Academics Management System is a database-driven web application that digitizes and automates the academic operations of an educational institution. It manages students, instructors, departments, courses, enrollments, and semester results — all in a centralized MySQL database with a Java-based frontend.

**Key highlight:** The system implements the exact **VTU 10-point grading scheme** — automatically converting marks to grades, computing SGPA per semester using a stored procedure with a cursor, and maintaining CGPA for each student.

---

## ✨ Features

- 🔐 **Login System** — Session-based authentication with HTTP cookies
- 📊 **Live Dashboard** — Real-time stats, 🏆 Top 3 leaderboard, ⚠️ Backlog alerts
- 👥 **Student Management** — Add, search, update, delete students
- 📋 **Enrollment Management** — Enroll students in ISE 4th sem subjects, update marks
- 🎯 **Auto VTU Grading** — Marks → Grade → Grade Points → SGPA → CGPA (fully automatic)
- 📝 **Audit Log** — Every data change auto-logged via MySQL triggers
- 🖥️ **Swing Admin Panel** — Desktop UI for department and instructor management

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Database | MySQL 8.0 |
| Backend | Java Servlets (Jakarta EE 6.0) |
| Web Server | Apache Tomcat 10.1.54 |
| Frontend | JSP (JavaServer Pages) |
| Desktop UI | Java Swing |
| DB Driver | JDBC — MySQL Connector/J 8.0.33 |
| Build Tool | Apache Maven |
| IDE | IntelliJ IDEA Community 2026.1 |
| Java Version | JDK 22.0.1 |
| Version Control | Git + GitHub |

---

## 🗄️ Database Design

**7 Tables** — normalized up to 3NF

```
departments     → 2 depts: ISE and Mathematics
instructors     → 8 instructors, one per subject
students        → 4 students (group members)
courses         → 8 ISE 4th sem subjects
enrollments     → Weak entity, composite PK (student_id + course_id)
sgpa_records    → SGPA per student per semester
audit_log       → Auto-filled by triggers
```

**8 ISE 4th Sem Subjects:**

| Code | Subject | Credits |
|------|---------|---------|
| BCS401 | Design and Analysis of Algorithms | 4 |
| BIS402 | Advanced Java | 4 |
| BCS403 | Database Management Systems | 4 |
| BCSL404 | DAA Laboratory | 1 |
| BCS405A | Discrete Mathematical Structures | 3 |
| BCS406C | UI/UX | 1 |
| BEAB407 | Bio Inspired Engineering | 2 |
| BUH408 | Universal Human Values | 1 |

**VTU 10-Point Grading:**

| Marks | Grade | Points |
|-------|-------|--------|
| 90–100 | O | 10 |
| 80–89 | A+ | 9 |
| 70–79 | A | 8 |
| 60–69 | B+ | 7 |
| 55–59 | B | 6 |
| 50–54 | C | 5 |
| 40–49 | P | 4 |
| 0–39 | F | 0 |

> SGPA = Σ(Grade Points × Credits) / Σ(Credits)
> CGPA = Average of all SGPAs

**Database Features:**
- ✅ 3 Triggers (AFTER INSERT, UPDATE, DELETE on enrollments)
- ✅ Stored Procedure with Cursor (`calculate_sgpa`)
- ✅ 4 Views (marksheet, results, dept performance, course-instructor)
- ✅ 22+ SQL queries

---

## ⚙️ Setup Instructions

### Prerequisites
- Java JDK 22+
- MySQL 8.0
- Apache Tomcat 10.1
- IntelliJ IDEA (with Smart Tomcat plugin)
- Maven

### Step 1 — Database Setup
```sql
-- Open MySQL Workbench and run:
source academy_db_v2.sql
```

### Step 2 — Configure DB Connection
Open `src/main/java/com/academy/db/DBConnection.java` and update:
```java
private static final String URL      = "jdbc:mysql://localhost:3306/academy_db";
private static final String USER     = "root";
private static final String PASSWORD = "your_mysql_password";
```

### Step 3 — Run in IntelliJ
1. Open project in IntelliJ IDEA
2. Install **Smart Tomcat** plugin
3. Add Run Configuration:
   - Type: Smart Tomcat
   - Tomcat Server: path to your Tomcat folder
   - Deployment Directory: `src/main/webapp`
   - Context Path: `/academy`
   - Port: `8080`
4. Click ▶ Run

### Step 4 — Open in Browser
```
http://localhost:8080/academy/login
```
- Username: `admin`
- Password: `admin123`

---

## 📸 Application Flow

```
Login → Dashboard (live stats + leaderboard)
           ↓
    ┌──────┴──────┐
    ▼             ▼
Students      Enrollments
(CRUD)        (Marks entry)
                  ↓
           VTU Grade assigned
                  ↓
           Trigger → audit_log
                  ↓
           SGPA/CGPA updated
```

---

*Made with ☕ Java and 🗄️ MySQL*
