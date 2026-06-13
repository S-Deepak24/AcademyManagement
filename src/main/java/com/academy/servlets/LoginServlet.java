package com.academy.servlets;

import com.academy.db.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    // ── GET — show the login page ─────────────────────────
    @Override
    protected void doGet(HttpServletRequest req,
                         HttpServletResponse res)
            throws ServletException, IOException {
        req.getRequestDispatcher("/login.jsp").forward(req, res);
    }

    // ── POST — process login form ─────────────────────────
    @Override
    protected void doPost(HttpServletRequest req,
                          HttpServletResponse res)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        // Simple admin check
        // In real app this would query a users table
        if ("admin".equals(username) && "admin123".equals(password)) {

            // Create session
            HttpSession session = req.getSession();
            session.setAttribute("loggedIn", true);
            session.setAttribute("username", username);

            // Create cookie — stores username for 1 hour
            Cookie cookie = new Cookie("ACADEMY_USER", username);
            cookie.setMaxAge(60 * 60);
            res.addCookie(cookie);

            // Redirect to dashboard
            res.sendRedirect(req.getContextPath() + "/dashboard.jsp");

        } else {
            // Wrong credentials — go back to login with error
            req.setAttribute("error", "Invalid username or password!");
            req.getRequestDispatcher("/login.jsp").forward(req, res);
        }
    }
}