package com.academy.servlets;

import com.academy.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;

@WebServlet("/enrollments")
public class EnrollmentServlet extends HttpServlet {

    // ── GET — show all enrollments ────────────────────────
    @Override
    protected void doGet(HttpServletRequest req,
                         HttpServletResponse res)
            throws ServletException, IOException {

        // Session check
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedIn") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Use HashMap (Collections — BIS402 Module 1)
        ArrayList<HashMap<String, String>> enrollmentList = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection()) {

            // ── includes student_id and course_id for update form ──
            String sql = "SELECT s.usn, s.full_name, c.course_code, " +
                    "c.course_name, c.credits, e.marks, " +
                    "e.grade, e.grade_points, e.sem, " +
                    "e.student_id, e.course_id, " +
                    "i.full_name AS instructor_name " +
                    "FROM enrollments e " +
                    "JOIN students s ON e.student_id = s.student_id " +
                    "JOIN courses c  ON e.course_id  = c.course_id " +
                    "LEFT JOIN instructors i ON c.instructor_id = i.instructor_id " +
                    "ORDER BY s.usn, c.course_code";

            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                HashMap<String, String> row = new HashMap<>();
                row.put("usn",         rs.getString("usn"));
                row.put("fullName",    rs.getString("full_name"));
                row.put("courseCode",  rs.getString("course_code"));
                row.put("courseName",  rs.getString("course_name"));
                row.put("credits",     rs.getString("credits"));
                row.put("marks",       rs.getString("marks"));
                row.put("grade",       rs.getString("grade"));
                row.put("gradePoints", rs.getString("grade_points"));
                row.put("sem",         rs.getString("sem"));
                row.put("studentId",   rs.getString("student_id"));
                row.put("courseId",    rs.getString("course_id"));
                row.put("instructorName", rs.getString("instructor_name"));
                enrollmentList.add(row);
            }

        } catch (Exception e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
        }

        req.setAttribute("enrollmentList", enrollmentList);
        req.getRequestDispatcher("/enrollment.jsp").forward(req, res);
    }

    // ── POST — update marks or enroll student ─────────────
    @Override
    protected void doPost(HttpServletRequest req,
                          HttpServletResponse res)
            throws ServletException, IOException {

        // Session check
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedIn") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        try (Connection conn = DBConnection.getConnection()) {

            if ("updateMarks".equals(action)) {

                int marks     = Integer.parseInt(req.getParameter("marks"));
                int studentId = Integer.parseInt(req.getParameter("studentId"));
                int courseId  = Integer.parseInt(req.getParameter("courseId"));

                // Convert marks to VTU grade and grade points
                String grade;
                int gradePoints;

                if      (marks >= 90) { grade = "O";  gradePoints = 10; }
                else if (marks >= 80) { grade = "A+"; gradePoints = 9;  }
                else if (marks >= 70) { grade = "A";  gradePoints = 8;  }
                else if (marks >= 60) { grade = "B+"; gradePoints = 7;  }
                else if (marks >= 55) { grade = "B";  gradePoints = 6;  }
                else if (marks >= 50) { grade = "C";  gradePoints = 5;  }
                else if (marks >= 40) { grade = "P";  gradePoints = 4;  }
                else                  { grade = "F";  gradePoints = 0;  }

                // Update marks — fires our trigger automatically!
                String sql = "UPDATE enrollments " +
                        "SET marks=?, grade=?, grade_points=? " +
                        "WHERE student_id=? AND course_id=?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, marks);
                ps.setString(2, grade);
                ps.setInt(3, gradePoints);
                ps.setInt(4, studentId);
                ps.setInt(5, courseId);
                ps.executeUpdate();

                // Call stored procedure to recalculate SGPA
                int sem = Integer.parseInt(req.getParameter("sem"));
                CallableStatement cs = conn.prepareCall(
                        "{CALL calculate_sgpa(?, ?)}"
                );
                cs.setInt(1, studentId);
                cs.setInt(2, sem);
                cs.execute();

            } else if ("enroll".equals(action)) {

                // Enroll a new student into a course
                String sql = "INSERT INTO enrollments " +
                        "(student_id, course_id, sem) " +
                        "VALUES (?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(req.getParameter("studentId")));
                ps.setInt(2, Integer.parseInt(req.getParameter("courseId")));
                ps.setInt(3, Integer.parseInt(req.getParameter("sem")));
                ps.executeUpdate();
            }

        } catch (Exception e) {
            req.setAttribute("error", "Error: " + e.getMessage());
        }

        res.sendRedirect(req.getContextPath() + "/enrollments");
    }
}