<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, java.sql.*, com.academy.db.DBConnection" %>
<%
    // Session check
    if (session.getAttribute("loggedIn") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String username = (String) session.getAttribute("username");

    // Fetch live counts from DB
    ArrayList<String[]> topStudents = new ArrayList<>();
    ArrayList<String[]> backlogStudents = new ArrayList<>();
    int totalStudents = 0, totalCourses = 0,
        totalDepts = 0, totalEnrollments = 0;
    double avgCgpa = 0;

    try (Connection conn = DBConnection.getConnection()) {
        ResultSet rs;

        rs = conn.createStatement().executeQuery(
            "SELECT COUNT(*) FROM students");
        if (rs.next()) totalStudents = rs.getInt(1);

        rs = conn.createStatement().executeQuery(
            "SELECT COUNT(*) FROM courses");
        if (rs.next()) totalCourses = rs.getInt(1);

        rs = conn.createStatement().executeQuery(
            "SELECT COUNT(*) FROM departments");
        if (rs.next()) totalDepts = rs.getInt(1);

        rs = conn.createStatement().executeQuery(
            "SELECT COUNT(*) FROM enrollments");
        if (rs.next()) totalEnrollments = rs.getInt(1);

        rs = conn.createStatement().executeQuery(
            "SELECT ROUND(AVG(cgpa),2) FROM students WHERE cgpa > 0");
            if (rs.next()) avgCgpa = rs.getDouble(1);

            // Leaderboard — top 3 students by CGPA
            rs = conn.createStatement().executeQuery(
                 "SELECT usn, full_name, cgpa FROM students " +
                 "WHERE cgpa > 0 ORDER BY cgpa DESC LIMIT 3");
            while (rs.next()) {
                 topStudents.add(new String[]{
                     rs.getString("usn"),
                     rs.getString("full_name"),
                     rs.getString("cgpa")
                 });
            }

            // Backlog — students with any F grade
            rs = conn.createStatement().executeQuery(
                 "SELECT DISTINCT s.usn, s.full_name, c.course_code " +
                 "FROM students s " +
                 "JOIN enrollments e ON s.student_id = e.student_id " +
                 "JOIN courses c ON e.course_id = c.course_id " +
                 "WHERE e.grade = 'F'");
            while (rs.next()) {
                 backlogStudents.add(new String[]{
                     rs.getString("usn"),
                     rs.getString("full_name"),
                     rs.getString("course_code")
                 });
            }

    } catch (Exception e) {
          out.println("DB Error: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard — Academy Management</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Segoe UI',sans-serif;
               background:#f0f4f8; min-height:100vh; }

        .navbar {
            background:#1F3864; color:white;
            padding:16px 32px;
            display:flex; justify-content:space-between;
            align-items:center;
        }
        .navbar h2 { font-size:18px; }
        .navbar a {
            color:white; text-decoration:none;
            font-size:13px; margin-left:24px;
            padding:8px 16px; border-radius:6px;
            background:rgba(255,255,255,0.15);
            transition:background 0.2s;
        }
        .navbar a:hover { background:rgba(255,255,255,0.25); }

        .container { padding:32px; }

        .welcome {
            font-size:22px; font-weight:600;
            color:#1F3864; margin-bottom:24px;
        }

        .cards {
            display:grid;
            grid-template-columns:repeat(auto-fit,minmax(180px,1fr));
            gap:20px; margin-bottom:32px;
        }

        .card {
            background:white; border-radius:12px;
            padding:24px; text-align:center;
            box-shadow:0 2px 12px rgba(0,0,0,0.08);
            border-top:4px solid #1F3864;
        }
        .card.green  { border-top-color:#27ae60; }
        .card.orange { border-top-color:#e67e22; }
        .card.purple { border-top-color:#8e44ad; }
        .card.teal   { border-top-color:#16a085; }

        .card .number {
            font-size:42px; font-weight:700;
            color:#1F3864; line-height:1;
        }
        .card.green  .number { color:#27ae60; }
        .card.orange .number { color:#e67e22; }
        .card.purple .number { color:#8e44ad; }
        .card.teal   .number { color:#16a085; }

        .card .label {
            font-size:13px; color:#888;
            margin-top:8px; font-weight:500;
        }

        .quick-links {
            background:white; border-radius:12px;
            padding:24px;
            box-shadow:0 2px 12px rgba(0,0,0,0.08);
        }
        .quick-links h3 {
            color:#1F3864; margin-bottom:16px;
            font-size:16px;
        }
        .link-grid {
            display:grid;
            grid-template-columns:repeat(auto-fit,minmax(160px,1fr));
            gap:12px;
        }
        .link-btn {
            display:block; padding:14px;
            background:#1F3864; color:white;
            text-decoration:none; border-radius:8px;
            text-align:center; font-size:14px;
            font-weight:500;
            transition:background 0.2s;
        }
        .link-btn:hover { background:#2E5D9E; }
        .link-btn.green  { background:#27ae60; }
        .link-btn.green:hover  { background:#219a52; }
        .link-btn.orange { background:#e67e22; }
        .link-btn.orange:hover { background:#ca6f1e; }
        .link-btn.red    { background:#c0392b; }
        .link-btn.red:hover    { background:#a93226; }

        .footer {
            text-align:center; padding:24px;
            color:#aaa; font-size:12px;
        }
    </style>
</head>
<body>

<div class="navbar">
    <h2>🎓 Academy Management System</h2>
    <div>
        <a href="students">👥 Students</a>
        <a href="enrollments">📋 Enrollments</a>
        <a href="logout">Logout</a>
    </div>
</div>

<div class="container">
    <p class="welcome">Welcome back, <%= username %> 👋</p>

    <div class="cards">
        <div class="card">
            <div class="number"><%= totalStudents %></div>
            <div class="label">Total Students</div>
        </div>
        <div class="card green">
            <div class="number"><%= totalDepts %></div>
            <div class="label">Departments</div>
        </div>
        <div class="card orange">
            <div class="number"><%= totalCourses %></div>
            <div class="label">Courses</div>
        </div>
        <div class="card purple">
            <div class="number"><%= totalEnrollments %></div>
            <div class="label">Enrollments</div>
        </div>
        <div class="card teal">
            <div class="number"><%= avgCgpa %></div>
            <div class="label">Avg CGPA</div>
        </div>
    </div>

    <% if (!backlogStudents.isEmpty()) { %>
    <div style="background:#fdedec; border-left:4px solid #c0392b;
                border-radius:8px; padding:16px 20px; margin-bottom:24px;">
        <strong style="color:#922b21; font-size:14px;">
            ⚠️ Students at Risk (<%= backlogStudents.size() %> backlog<%= backlogStudents.size() > 1 ? "s" : "" %>)
        </strong>
        <div style="margin-top:8px; font-size:13px; color:#7b241c;">
            <% for (String[] b : backlogStudents) { %>
                <div style="padding:4px 0;">
                    <strong><%= b[0] %></strong> — <%= b[1] %> failed
                    <strong><%= b[2] %></strong>
                </div>
            <% } %>
        </div>
    </div>
    <% } %>

    <div style="background:white; border-radius:12px; padding:24px;
                margin-bottom:24px; box-shadow:0 2px 12px rgba(0,0,0,0.08);">
        <h3 style="color:#1F3864; margin-bottom:16px; font-size:16px;">
            🏆 Top Performers (CGPA)
        </h3>
        <% if (topStudents.isEmpty()) { %>
            <p style="color:#aaa; font-size:13px;">No results computed yet.</p>
        <% } else {
            String[] medals = {"🥇", "🥈", "🥉"};
            for (int i = 0; i < topStudents.size(); i++) {
                String[] t = topStudents.get(i);
        %>
            <div style="display:flex; align-items:center; gap:12px;
                        padding:10px 0; border-bottom:1px solid #f0f0f0;">
                <span style="font-size:24px;"><%= medals[i] %></span>
                <div style="flex:1;">
                    <div style="font-weight:600; font-size:14px; color:#333;">
                        <%= t[1] %>
                    </div>
                    <div style="font-size:12px; color:#888;"><%= t[0] %></div>
                </div>
                <div style="font-size:20px; font-weight:700; color:#1F3864;">
                    <%= t[2] %>
                </div>
            </div>
        <% } } %>
    </div>

    <div class="quick-links">
        <h3>Quick Actions</h3>
        <div class="link-grid">
            <a href="students" class="link-btn">👥 View Students</a>
            <a href="students?action=add" class="link-btn green">
                ➕ Add Student</a>
            <a href="enrollments" class="link-btn orange">
                📋 View Enrollments</a>
            <a href="enrollments?action=marks" class="link-btn purple">
                ✏️ Update Marks</a>
        </div>
    </div>
</div>

<div class="footer">
    Bangalore Institute of Technology &nbsp;·&nbsp;
    Dept. of ISE &nbsp;·&nbsp;2024–25
</div>

</body>
</html>