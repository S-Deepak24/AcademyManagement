<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login — Academy Management</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, #1F3864 0%, #2E5D9E 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-card {
            background: white;
            border-radius: 16px;
            padding: 48px 40px;
            width: 380px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }

        .college-name {
            text-align: center;
            font-size: 13px;
            color: #666;
            margin-bottom: 4px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        h1 {
            text-align: center;
            color: #1F3864;
            font-size: 22px;
            margin-bottom: 8px;
        }

        .subtitle {
            text-align: center;
            color: #888;
            font-size: 13px;
            margin-bottom: 32px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #444;
            margin-bottom: 6px;
        }

        input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.2s;
            outline: none;
        }

        input:focus { border-color: #1F3864; }

        .btn-login {
            width: 100%;
            padding: 14px;
            background: #1F3864;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 8px;
            transition: background 0.2s;
        }

        .btn-login:hover { background: #2E5D9E; }

        .error {
            background: #fff0f0;
            color: #c0392b;
            padding: 10px 14px;
            border-radius: 8px;
            font-size: 13px;
            margin-bottom: 16px;
            border-left: 3px solid #c0392b;
        }

        .hint {
            text-align: center;
            font-size: 12px;
            color: #aaa;
            margin-top: 20px;
        }
    </style>
</head>
<body>
<div class="login-card">
    <p class="college-name">Bangalore Institute of Technology</p>
    <h1>🎓 Academy Management</h1>
    <p class="subtitle">Bangalore Institute of Technology</p>

    <% String error = (String) request.getAttribute("error");
       if (error != null) { %>
        <div class="error"><%= error %></div>
    <% } %>

    <form method="post" action="<%= request.getContextPath() %>/login">
        <div class="form-group">
            <label>Username</label>
            <input type="text" name="username"
                   placeholder="Enter username" required />
        </div>
        <div class="form-group">
            <label>Password</label>
            <input type="password" name="password"
                   placeholder="Enter password" required />
        </div>
        <button type="submit" class="btn-login">Login →</button>
    </form>

    <p class="hint">Default: admin / admin123</p>
</div>
</body>
</html>