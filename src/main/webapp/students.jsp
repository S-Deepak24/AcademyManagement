<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, com.academy.model.Student" %>
<%@ page import="java.sql.*, com.academy.db.DBConnection" %>
<%
    if (session.getAttribute("loggedIn") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    // Fetch departments for dropdown
    ArrayList<String[]> depts = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection()) {
        ResultSet rs = conn.createStatement().executeQuery(
            "SELECT dept_id, dept_name FROM departments ORDER BY dept_name");
        while (rs.next()) {
            depts.add(new String[]{
                rs.getString("dept_id"),
                rs.getString("dept_name")
            });
        }
    } catch (Exception e) { }

    ArrayList<Student> studentList =
        (ArrayList<Student>) request.getAttribute("studentList");
    if (studentList == null) studentList = new ArrayList<>();

    String error   = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Students — Academy Management</title>
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
            font-size:13px; margin-left:16px;
            padding:8px 14px; border-radius:6px;
            background:rgba(255,255,255,0.15);
        }
        .navbar a:hover { background:rgba(255,255,255,0.25); }

        .container { padding:28px; }

        .page-title {
            font-size:20px; font-weight:600;
            color:#1F3864; margin-bottom:20px;
        }

        .alert {
            padding:12px 16px; border-radius:8px;
            margin-bottom:16px; font-size:13px;
        }
        .alert.success {
            background:#eafaf1; color:#1e8449;
            border-left:3px solid #27ae60;
        }
        .alert.error {
            background:#fff0f0; color:#c0392b;
            border-left:3px solid #c0392b;
        }

        /* Add student form */
        .add-form {
            background:white; border-radius:12px;
            padding:24px; margin-bottom:24px;
            box-shadow:0 2px 12px rgba(0,0,0,0.08);
        }
        .add-form h3 {
            color:#1F3864; margin-bottom:16px;
            font-size:15px;
        }
        .form-grid {
            display:grid;
            grid-template-columns:repeat(auto-fit,minmax(180px,1fr));
            gap:12px; margin-bottom:16px;
        }
        .form-group label {
            display:block; font-size:12px;
            font-weight:600; color:#555;
            margin-bottom:4px;
        }
        .form-group input,
        .form-group select {
            width:100%; padding:10px 12px;
            border:2px solid #e0e0e0;
            border-radius:6px; font-size:13px;
            outline:none;
        }
        .form-group input:focus,
        .form-group select:focus {
            border-color:#1F3864;
        }
        .btn {
            padding:10px 20px; border:none;
            border-radius:6px; font-size:13px;
            font-weight:600; cursor:pointer;
        }
        .btn-primary {
            background:#1F3864; color:white;
        }
        .btn-primary:hover { background:#2E5D9E; }

        /* Search bar */
        .search-bar {
            display:flex; gap:10px;
            margin-bottom:16px;
        }
        .search-bar input {
            flex:1; padding:10px 14px;
            border:2px solid #e0e0e0;
            border-radius:6px; font-size:13px;
            outline:none;
        }
        .search-bar input:focus { border-color:#1F3864; }

        /* Table */
        .table-wrap {
            background:white; border-radius:12px;
            box-shadow:0 2px 12px rgba(0,0,0,0.08);
            overflow:hidden;
        }
        table {
            width:100%; border-collapse:collapse;
        }
        thead { background:#1F3864; color:white; }
        th { padding:14px 16px; text-align:left;
             font-size:13px; font-weight:600; }
        td { padding:12px 16px; font-size:13px;
             border-bottom:1px solid #f0f0f0; }
        tr:hover td { background:#f8f9ff; }

        .badge {
            padding:3px 10px; border-radius:20px;
            font-size:11px; font-weight:600;
        }
        .badge-O  { background:#eafaf1; color:#1e8449; }
        .badge-A  { background:#ebf5fb; color:#1a5276; }
        .badge-B  { background:#fef9e7; color:#7d6608; }
        .badge-F  { background:#fdedec; color:#922b21; }
        .badge-na { background:#f2f3f4; color:#717d7e; }

        .btn-sm {
            padding:5px 10px; font-size:11px;
            border-radius:4px; border:none;
            cursor:pointer; font-weight:600;
        }
        .btn-danger {
            background:#fdedec; color:#c0392b;
        }
    </style>
</head>
<body>

<div class="navbar">
    <h2>🎓 Academy Management System</h2>
    <div>
        <a href="dashboard.jsp">🏠 Dashboard</a>
        <a href="enrollments">📋 Enrollments</a>
        <a href="logout">Logout</a>
    </div>
</div>

<div class="container">
    <p class="page-title">👥 Student Management</p>

    <% if (error != null) { %>
        <div class="alert error"><%= error %></div>
    <% } %>
    <% if (success != null) { %>
        <div class="alert success"><%= success %></div>
    <% } %>

    <!-- Add Student Form -->
    <div class="add-form">
        <h3>➕ Add New Student</h3>
        <form method="post" action="<%= request.getContextPath() %>/students">
            <input type="hidden" name="action" value="add"/>
            <div class="form-grid">
                <div class="form-group">
                    <label>USN</label>
                    <input type="text" name="usn"
                           placeholder="1BI24IS001" required/>
                </div>
                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text" name="fullName"
                           placeholder="Student name" required/>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email"
                           placeholder="email@bit.edu" required/>
                </div>
                <div class="form-group">
                    <label>Age</label>
                    <input type="number" name="age"
                           min="16" max="30" placeholder="20" required/>
                </div>
                <div class="form-group">
                    <label>Department</label>
                    <select name="deptId" required>
                        <option value="">Select dept</option>
                        <% for (String[] d : depts) { %>
                            <option value="<%= d[0] %>">
                                <%= d[1] %>
                            </option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Current Semester</label>
                    <select name="currentSem" required>
                        <% for (int i = 1; i <= 8; i++) { %>
                            <option value="<%= i %>">Sem <%= i %></option>
                        <% } %>
                    </select>
                </div>
            </div>
            <button type="submit" class="btn btn-primary">
                Add Student
            </button>
        </form>
    </div>

    <!-- Search -->
    <form method="get"
          action="<%= request.getContextPath() %>/students"
          class="search-bar">
        <input type="hidden" name="action" value="search"/>
        <input type="text" name="keyword"
               placeholder="Search by USN or name..."/>
        <button type="submit" class="btn btn-primary">Search</button>
        <a href="<%= request.getContextPath() %>/students"
           class="btn btn-primary">Clear</a>
    </form>

    <!-- Student Table -->
    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>USN</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Age</th>
                    <th>Sem</th>
                    <th>CGPA</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% if (studentList.isEmpty()) { %>
                    <tr>
                        <td colspan="7" style="text-align:center;
                            padding:32px; color:#aaa;">
                            No students found
                        </td>
                    </tr>
                <% } else {
                    for (Student s : studentList) {
                        double cgpa = s.getCgpa();
                        String badgeClass = cgpa >= 9 ? "badge-O" :
                                            cgpa >= 8 ? "badge-A" :
                                            cgpa >= 6 ? "badge-B" :
                                            cgpa > 0  ? "badge-F" : "badge-na";
                %>
                    <tr>
                        <td><strong><%= s.getUsn() %></strong></td>
                        <td><%= s.getFullName() %></td>
                        <td><%= s.getEmail() %></td>
                        <td><%= s.getAge() %></td>
                        <td>Sem <%= s.getCurrentSem() %></td>
                        <td>
                            <span class="badge <%= badgeClass %>">
                                <%= cgpa > 0 ? cgpa : "—" %>
                            </span>
                        </td>
                        <td>
                            <form method="post"
                                action="<%= request.getContextPath()%>/students"
                                style="display:inline;">
                                <input type="hidden" name="action"
                                       value="delete"/>
                                <input type="hidden" name="studentId"
                                       value="<%= s.getStudentId() %>"/>
                                <button type="submit"
                                        class="btn-sm btn-danger"
                                        onclick="return confirm(
                                        'Delete <%= s.getFullName() %>?')">
                                    Delete
                                </button>
                            </form>
                        </td>
                    </tr>
                <% } } %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>