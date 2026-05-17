package com.valuevault.model;

import com.valuevault.config.DBConfig;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;

public class UserDAO {

    // Maximum failed attempts before account is temporarily locked
    private static final int MAX_ATTEMPTS  = 5;
    // Lock duration in minutes
    private static final int LOCKOUT_MINS  = 15;

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

    /**
     * Attempts to log in with the given credentials.
     * Returns a LoginResult containing the outcome and any relevant message.
     * Tracks failed attempts; locks account after MAX_ATTEMPTS failures.
     */
    public LoginResult loginUser(String email, String password) {
        try (Connection conn = DBConfig.getConnection()) {

            // Step 1: Fetch the user row by email alone
            String fetchSql = "SELECT * FROM users WHERE email = ?";
            PreparedStatement fetchPs = conn.prepareStatement(fetchSql);
            fetchPs.setString(1, email);
            ResultSet rs = fetchPs.executeQuery();

            if (!rs.next()) {
                // Email not found — generic message, no attempt tracking
                return new LoginResult(null, "Invalid email or password.");
            }

            // Step 2: Check if the account is currently locked
            Timestamp lockoutUntil = rs.getTimestamp("lockout_until");
            if (lockoutUntil != null && lockoutUntil.after(new Timestamp(System.currentTimeMillis()))) {
                // Still within the lock window — calculate remaining minutes
                long millisLeft = lockoutUntil.getTime() - System.currentTimeMillis();
                long minsLeft   = (millisLeft / 60000) + 1; // round up
                return new LoginResult(null,
                    "Your account has been temporarily locked due to too many failed login attempts. " +
                    "Please try again in " + minsLeft + " minute" + (minsLeft == 1 ? "" : "s") + ".");
            }

            int userId         = rs.getInt("id");
            int failedAttempts = rs.getInt("failed_attempts");
            String storedHash  = rs.getString("password");

            // Step 3: Check the password
            String submittedHash = hashPassword(password);
            if (!submittedHash.equals(storedHash)) {
                // Wrong password — increment attempt counter
                failedAttempts++;

                if (failedAttempts >= MAX_ATTEMPTS) {
                    // Lock the account for LOCKOUT_MINS minutes
                    Timestamp lockUntil = new Timestamp(
                        System.currentTimeMillis() + (long) LOCKOUT_MINS * 60 * 1000);
                    String lockSql =
                        "UPDATE users SET failed_attempts = ?, lockout_until = ? WHERE id = ?";
                    PreparedStatement lockPs = conn.prepareStatement(lockSql);
                    lockPs.setInt(1, failedAttempts);
                    lockPs.setTimestamp(2, lockUntil);
                    lockPs.setInt(3, userId);
                    lockPs.executeUpdate();

                    return new LoginResult(null,
                        "Too many failed login attempts. Your account has been locked for " +
                        LOCKOUT_MINS + " minutes. Please try again later.");
                } else {
                    // Not yet locked — update counter only
                    int attemptsLeft = MAX_ATTEMPTS - failedAttempts;
                    String updateSql =
                        "UPDATE users SET failed_attempts = ?, lockout_until = NULL WHERE id = ?";
                    PreparedStatement updatePs = conn.prepareStatement(updateSql);
                    updatePs.setInt(1, failedAttempts);
                    updatePs.setInt(2, userId);
                    updatePs.executeUpdate();

                    return new LoginResult(null,
                        "Invalid email or password. " + attemptsLeft +
                        " attempt" + (attemptsLeft == 1 ? "" : "s") + " remaining before your account is locked.");
                }
            }

            // Step 4: Password correct — reset attempt counter and return user
            String resetSql =
                "UPDATE users SET failed_attempts = 0, lockout_until = NULL WHERE id = ?";
            PreparedStatement resetPs = conn.prepareStatement(resetSql);
            resetPs.setInt(1, userId);
            resetPs.executeUpdate();

            User user = mapRowToUser(rs);
            return new LoginResult(user, null);

        } catch (SQLException e) {
            e.printStackTrace();
            return new LoginResult(null, "A system error occurred. Please try again.");
        }
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
     * Also clears any lockout state on password reset.
     */
    public boolean resetPassword(String email, String newPassword) {
        try (Connection conn = DBConfig.getConnection()) {
            String sql =
                "UPDATE users SET password = ?, failed_attempts = 0, lockout_until = NULL WHERE email = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, hashPassword(newPassword));
            ps.setString(2, email);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // Added AND role != 'admin' — admin accounts can never be deleted
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

    // Inner result class 
    /**
     * Wraps the outcome of a login attempt.
     * user is non-null on success; errorMessage is non-null on failure.
     */
    public static class LoginResult {
        private final User   user;
        private final String errorMessage;

        public LoginResult(User user, String errorMessage) {
            this.user         = user;
            this.errorMessage = errorMessage;
        }

        public User   getUser()         { return user; }
        public String getErrorMessage() { return errorMessage; }
        public boolean isSuccess()      { return user != null; }
    }
}
