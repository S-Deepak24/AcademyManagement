<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.*, java.sql.*, com.academy.db.DBConnection" %>
<%
    if (session.getAttribute("loggedIn") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    ArrayList<HashMap<String, String>> enrollmentList =
        (ArrayList<HashMap<String, String>>)
        request.getAttribute("enrollmentList");
    if (enrollmentList == null) enrollmentList = new ArrayList<>();

    // Fetch students and courses for enroll form dropdowns
    ArrayList<String[]> students = new ArrayList<>();
    ArrayList<String[]> courses  = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection()) {
        ResultSet rs = conn.createStatement().executeQuery(
            "SELECT student_id, usn, full_name FROM students ORDER BY usn");
        while (rs.next()) {
            students.add(new String[]{
                rs.getString("student_id"),
                rs.getString("usn") + " — " + rs.getString("full_name")
            });
        }
        rs = conn.createStatement().executeQuery(
            "SELECT course_id, course_code, course_name, sem " +
            "FROM courses ORDER BY course_code");
        while (rs.next()) {
            courses.add(new String[]{
                rs.getString("course_id"),
                rs.getString("course_code") + " — " +
                rs.getString("course_name"),
                rs.getString("sem")
            });
        }
    } catch (Exception e) { }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Enrollments — Academy Management</title>
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

        .panels {
            display:grid;
            grid-template-columns:1fr 1fr;
            gap:20px; margin-bottom:24px;
        }

        .panel {
            background:white; border-radius:12px;
            padding:24px;
            box-shadow:0 2px 12px rgba(0,0,0,0.08);
        }
        .panel h3 {
            color:#1F3864; font-size:15px;
            margin-bottom:16px;
        }

        .form-group { margin-bottom:12px; }
        .form-group label {
            display:block; font-size:12px;
            font-weight:600; color:#555;
            margin-bottom:4px;
        }
        .form-group input,
        .form-group select {
            width:100%; padding:10px 12px;
            border:2px solid #e0e0e0;
            border-radius:6px; font-size:13px; outline:none;
        }
        .form-group input:focus,
        .form-group select:focus { border-color:#1F3864; }

        .btn {
            padding:10px 20px; border:none;
            border-radius:6px; font-size:13px;
            font-weight:600; cursor:pointer;
            margin-top:4px;
        }
        .btn-primary { background:#1F3864; color:white; }
        .btn-primary:hover { background:#2E5D9E; }
        .btn-green { background:#27ae60; color:white; }
        .btn-green:hover { background:#219a52; }

        /* Grade badge */
        .grade {
            display:inline-block;
            padding:3px 10px; border-radius:20px;
            font-size:12px; font-weight:700;
        }
        .g-O  { background:#eafaf1; color:#1e8449; }
        .g-Ap { background:#ebf5fb; color:#1a5276; }
        .g-A  { background:#d6eaf8; color:#1a5276; }
        .g-Bp { background:#fef9e7; color:#7d6608; }
        .g-B  { background:#fef5e4; color:#7d6608; }
        .g-C  { background:#fdf2e9; color:#784212; }
        .g-P  { background:#f9ebea; color:#922b21; }
        .g-F  { background:#fdedec; color:#922b21; }
        .g-na { background:#f2f3f4; color:#717d7e; }

        /* Table */
        .table-wrap {
            background:white; border-radius:12px;
            box-shadow:0 2px 12px rgba(0,0,0,0.08);
            overflow:hidden;
        }
        table { width:100%; border-collapse:collapse; }
        thead { background:#1F3864; color:white; }
        th { padding:14px 16px; text-align:left;
             font-size:13px; font-weight:600; }
        td { padding:11px 16px; font-size:13px;
             border-bottom:1px solid #f0f0f0; }
        tr:hover td { background:#f8f9ff; }

        .marks-input {
            width:70px; padding:6px 8px;
            border:2px solid #e0e0e0;
            border-radius:4px; font-size:13px;
            text-align:center; outline:none;
        }
        .marks-input:focus { border-color:#1F3864; }

        .btn-save {
            padding:6px 12px; font-size:11px;
            border:none; border-radius:4px;
            background:#1F3864; color:white;
            cursor:pointer; font-weight:600;
        }
        .btn-save:hover { background:#2E5D9E; }
    </style>
</head>
<body>

<div class="navbar">
    <h2>🎓 Academy Management System</h2>
    <div>
        <a href="dashboard.jsp">🏠 Dashboard</a>
        <a href="students">👥 Students</a>
        <a href="logout">Logout</a>
    </div>
</div>

<div class="container">
    <p class="page-title">📋 Enrollment Management</p>

    <div class="panels">

        <!-- Enroll Student -->
        <div class="panel">
            <h3>➕ Enroll Student in Course</h3>
            <form method="post"
                  action="<%= request.getContextPath() %>/enrollments">
                <input type="hidden" name="action" value="enroll"/>
                <div class="form-group">
                    <label>Student</label>
                    <select name="studentId" required>
                        <option value="">Select student</option>
                        <% for (String[] s : students) { %>
                            <option value="<%= s[0] %>">
                                <%= s[1] %>
                            </option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Course</label>
                    <select name="courseId" required
                            onchange="setSem(this)">
                        <option value="">Select course</option>
                        <% for (String[] c : courses) { %>
                            <option value="<%= c[0] %>"
                                    data-sem="<%= c[2] %>">
                                <%= c[1] %>
                            </option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label>Semester</label>
                    <input type="number" name="sem" id="semField"
                           min="1" max="8" placeholder="4" required/>
                </div>
                <button type="submit" class="btn btn-green">
                    Enroll →
                </button>
            </form>
        </div>

        <!-- VTU Grading Reference -->
        <div class="panel">
            <h3>📊 VTU Grading Reference</h3>
            <table>
                <thead>
                    <tr><th>Marks</th><th>Grade</th><th>Points</th></tr>
                </thead>
                <tbody>
                    <tr><td>90 – 100</td>
                        <td><span class="grade g-O">O</span></td>
                        <td>10</td></tr>
                    <tr><td>80 – 89</td>
                        <td><span class="grade g-Ap">A+</span></td>
                        <td>9</td></tr>
                    <tr><td>70 – 79</td>
                        <td><span class="grade g-A">A</span></td>
                        <td>8</td></tr>
                    <tr><td>60 – 69</td>
                        <td><span class="grade g-Bp">B+</span></td>
                        <td>7</td></tr>
                    <tr><td>55 – 59</td>
                        <td><span class="grade g-B">B</span></td>
                        <td>6</td></tr>
                    <tr><td>50 – 54</td>
                        <td><span class="grade g-C">C</span></td>
                        <td>5</td></tr>
                    <tr><td>40 – 49</td>
                        <td><span class="grade g-P">P</span></td>
                        <td>4</td></tr>
                    <tr><td>0 – 39</td>
                        <td><span class="grade g-F">F</span></td>
                        <td>0</td></tr>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Enrollment Table with inline marks update -->
    <div class="table-wrap">
        <table>
            <thead>
                <tr>
                    <th>USN</th>
                    <th>Student</th>
                    <th>Course</th>
                    <th>Sem</th>
                    <th>Marks</th>
                    <th>Grade</th>
                    <th>Points</th>
                    <th>Update</th>
                </tr>
            </thead>
            <tbody>
                <% if (enrollmentList.isEmpty()) { %>
                    <tr>
                        <td colspan="8"
                            style="text-align:center;
                                   padding:32px; color:#aaa;">
                            No enrollments found
                        </td>
                    </tr>
                <% } else {
                    for (HashMap<String,String> e : enrollmentList) {
                        String grade = e.get("grade");
                        String gc = grade == null ? "g-na" :
                                    grade.equals("O")  ? "g-O"  :
                                    grade.equals("A+") ? "g-Ap" :
                                    grade.equals("A")  ? "g-A"  :
                                    grade.equals("B+") ? "g-Bp" :
                                    grade.equals("B")  ? "g-B"  :
                                    grade.equals("C")  ? "g-C"  :
                                    grade.equals("P")  ? "g-P"  :
                                    grade.equals("F")  ? "g-F"  : "g-na";
                %>
                    <tr>
                        <td><strong><%= e.get("usn") %></strong></td>
                        <td><%= e.get("fullName") %></td>
                        <td><%= e.get("courseCode") %></td>
                        <td><%= e.get("sem") %></td>
                        <td><%= e.get("marks") != null ?
                                e.get("marks") : "—" %></td>
                        <td>
                            <span class="grade <%= gc %>">
                                <%= grade != null ? grade : "—" %>
                            </span>
                        </td>
                        <td><%= e.get("gradePoints") != null ?
                                e.get("gradePoints") : "—" %></td>
                        <td>
                            <form method="post" action="<%=
                                request.getContextPath()%>/enrollments"
                                style="display:flex;gap:6px;">
                                <input type="hidden"
                                       name="action" value="updateMarks"/>
                                <input type="hidden" name="studentId"
                                       value="<%= e.get("studentId") %>"/>
                                <input type="hidden" name="courseId"
                                       value="<%= e.get("courseId") %>"/>
                                <input type="hidden" name="sem"
                                       value="<%= e.get("sem") %>"/>
                                <input type="number"
                                       name="marks"
                                       class="marks-input"
                                       min="0" max="100"
                                       placeholder="0-100"/>
                                <button type="submit"
                                        class="btn-save">Save</button>
                            </form>
                        </td>
                    </tr>
                <% } } %>
            </tbody>
        </table>
    </div>
</div>

<script>
    // Auto-fill semester when course is selected
    function setSem(sel) {
        var opt = sel.options[sel.selectedIndex];
        var sem = opt.getAttribute('data-sem');
        if (sem) document.getElementById('semField').value = sem;
    }
</script>

</body>
</html>