package com.valuevault.model;

import com.valuevault.config.DBConfig;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;

public class UserDAO {

    // Hash password using SHA-256
    private String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 not available", e);
        }
    }

    public boolean registerUser(User user) {
        try (Connection conn = DBConfig.getConnection()) {
            // Check if email already exists
            String checkSql = "SELECT id FROM users WHERE email = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setString(1, user.getEmail());
            ResultSet checkRs = checkPs.executeQuery();
            if (checkRs.next()) {
                return false; // Email already exists
            }

            String sql = "INSERT INTO users (name, email, password, role, security_question, security_answer) VALUES (?, ?, ?, 'user', ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, hashPassword(user.getPassword()));
            ps.setString(4, user.getSecurityQuestion());
            // Hash the security answer too (case-insensitive: store lowercase)
            ps.setString(5, hashPassword(user.getSecurityAnswer().trim().toLowerCase()));
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public User loginUser(String email, String password) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, hashPassword(password));
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                User user = mapRowToUser(rs);
                return user;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public User getUserById(int id) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT * FROM users WHERE id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRowToUser(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Look up user by email and return their security question.
     * Returns null if email not found.
     */
    public String getSecurityQuestion(String email) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT security_question FROM users WHERE email = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("security_question");
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Verify security answer for a given email.
     * Answer is compared case-insensitively.
     */
    public boolean verifySecurityAnswer(String email, String answer) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT security_answer FROM users WHERE email = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String stored = rs.getString("security_answer");
                String hashed = hashPassword(answer.trim().toLowerCase());
                return hashed.equals(stored);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Reset password for a user identified by email.
     */
    public boolean resetPassword(String email, String newPassword) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "UPDATE users SET password = ? WHERE email = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, hashPassword(newPassword));
            ps.setString(2, email);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // BUG FIX 7: Added AND role != 'admin' — admin accounts can never be deleted
    public boolean deleteUser(int id) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql = "DELETE FROM users WHERE id = ? AND role != 'admin'";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private User mapRowToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setName(rs.getString("name"));
        user.setEmail(rs.getString("email"));
        user.setRole(rs.getString("role"));
        try { user.setSecurityQuestion(rs.getString("security_question")); } catch (SQLException ignored) {}
        return user;
    }
}
