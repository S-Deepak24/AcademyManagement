package com.academy.servlets;

import com.academy.db.DBConnection;
import com.academy.model.Student;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

@WebServlet("/students")
public class StudentServlet extends HttpServlet {

    // ── GET — fetch all students and show them ────────────
    @Override
    protected void doGet(HttpServletRequest req,
                         HttpServletResponse res)
            throws ServletException, IOException {

        // Check session — if not logged in, redirect to login
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedIn") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Use ArrayList (Collections — BIS402 Module 1) to hold students
        ArrayList<Student> studentList = new ArrayList<>();

        String action = req.getParameter("action");

        try (Connection conn = DBConnection.getConnection()) {

            if ("search".equals(action)) {
                // Search by USN or name
                String keyword = "%" + req.getParameter("keyword") + "%";
                String sql = "SELECT * FROM students WHERE " +
                        "usn LIKE ? OR full_name LIKE ? " +
                        "ORDER BY full_name";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, keyword);
                ps.setString(2, keyword);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    studentList.add(mapStudent(rs));
                }
                req.setAttribute("searchMode", true);

            } else {
                // Fetch all students with their dept name
                String sql = "SELECT s.*, d.dept_name " +
                        "FROM students s " +
                        "LEFT JOIN departments d ON s.dept_id = d.dept_id " +
                        "ORDER BY s.usn";
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    studentList.add(mapStudent(rs));
                }
            }

        } catch (Exception e) {
            req.setAttribute("error", "Database error: " + e.getMessage());
        }

        // Pass list to JSP
        req.setAttribute("studentList", studentList);
        req.getRequestDispatcher("/students.jsp").forward(req, res);
    }

    // ── POST — add a new student ──────────────────────────
    @Override
    protected void doPost(HttpServletRequest req,
                          HttpServletResponse res)
            throws ServletException, IOException {

        // Check session
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loggedIn") == null) {
            res.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");

        try (Connection conn = DBConnection.getConnection()) {

            if ("add".equals(action)) {
                // Insert new student
                String sql = "INSERT INTO students " +
                        "(usn, full_name, email, age, dept_id, current_sem) " +
                        "VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, req.getParameter("usn"));
                ps.setString(2, req.getParameter("fullName"));
                ps.setString(3, req.getParameter("email"));
                ps.setInt(4, Integer.parseInt(req.getParameter("age")));
                ps.setInt(5, Integer.parseInt(req.getParameter("deptId")));
                ps.setInt(6, Integer.parseInt(req.getParameter("currentSem")));
                ps.executeUpdate();
                req.setAttribute("success", "Student added successfully!");

            } else if ("delete".equals(action)) {
                // Delete student
                String sql = "DELETE FROM students WHERE student_id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, Integer.parseInt(req.getParameter("studentId")));
                ps.executeUpdate();
                req.setAttribute("success", "Student deleted successfully!");

            } else if ("update".equals(action)) {
                // Update student marks
                String sql = "UPDATE students SET full_name=?, email=?, " +
                        "age=?, dept_id=?, current_sem=? " +
                        "WHERE student_id=?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, req.getParameter("fullName"));
                ps.setString(2, req.getParameter("email"));
                ps.setInt(3, Integer.parseInt(req.getParameter("age")));
                ps.setInt(4, Integer.parseInt(req.getParameter("deptId")));
                ps.setInt(5, Integer.parseInt(req.getParameter("currentSem")));
                ps.setInt(6, Integer.parseInt(req.getParameter("studentId")));
                ps.executeUpdate();
                req.setAttribute("success", "Student updated successfully!");
            }

        } catch (Exception e) {
            req.setAttribute("error", "Error: " + e.getMessage());
        }

        // Redirect back to student list
        res.sendRedirect(req.getContextPath() + "/students");
    }

    // ── Helper — map ResultSet row to Student object ──────
    private Student mapStudent(ResultSet rs) throws Exception {
        Student s = new Student();
        s.setStudentId(rs.getInt("student_id"));
        s.setUsn(rs.getString("usn"));
        s.setFullName(rs.getString("full_name"));
        s.setEmail(rs.getString("email"));
        s.setAge(rs.getInt("age"));
        s.setCurrentSem(rs.getInt("current_sem"));
        s.setCgpa(rs.getDouble("cgpa"));
        return s;
    }
}