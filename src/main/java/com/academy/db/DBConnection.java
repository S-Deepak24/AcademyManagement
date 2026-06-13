package com.academy.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    // ── Database credentials ──────────────────────────────
    private static final String URL      = "jdbc:mysql://localhost:3306/academy_db";
    private static final String USER     = "root";
    private static final String PASSWORD = "Deepak24@2006";

    // ── Get a connection to MySQL ─────────────────────────
    public static Connection getConnection() {
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            System.out.println("MySQL Driver not found: " + e.getMessage());
        } catch (SQLException e) {
            System.out.println("DB Connection failed: " + e.getMessage());
        }
        return conn;
    }

    // ── Test connection (run this to verify) ──────────────
    public static void main(String[] args) {
        Connection conn = getConnection();
        if (conn != null) {
            System.out.println("✅ Connected to academy_db successfully!");
        } else {
            System.out.println("❌ Connection failed. Check credentials.");
        }
    }
}