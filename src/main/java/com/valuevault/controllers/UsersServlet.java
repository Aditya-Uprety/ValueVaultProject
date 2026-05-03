package com.valuevault.controllers;

import com.valuevault.config.DBConfig;
import com.valuevault.model.User;
import com.valuevault.model.UserDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/users")
public class UsersServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }
        User currentUser = (User) session.getAttribute("user");
        if (!"admin".equals(currentUser.getRole())) {
            response.sendRedirect("home");
            return;
        }

        ArrayList<Map<String, Object>> users = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT u.id, u.name, u.email, u.role, " +
                         "(SELECT COUNT(*) FROM bids b WHERE b.user_id = u.id) AS total_purchases, " +
                         "COALESCE((SELECT SUM(b.bid_amount) FROM bids b WHERE b.user_id = u.id AND b.status = 'accepted'), 0) AS total_spending " +
                         "FROM users u WHERE u.role != 'admin' ORDER BY u.id DESC";

            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> user = new HashMap<>();
                user.put("id", rs.getInt("id"));
                user.put("name", rs.getString("name"));
                user.put("email", rs.getString("email"));
                user.put("role", rs.getString("role"));
                user.put("status", "Active");
                user.put("total_purchases", rs.getInt("total_purchases"));
                // COALESCE ensures this is never null - safe to format
                user.put("total_spending", rs.getDouble("total_spending"));
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("users", users);
        request.getRequestDispatcher("/WEB-INF/pages/admin_users.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }
        User currentUser = (User) session.getAttribute("user");
        if (!"admin".equals(currentUser.getRole())) {
            response.sendRedirect("home");
            return;
        }

        String action = request.getParameter("action");
        String userId = request.getParameter("userId");

        if ("delete".equals(action) && userId != null) {
            try {
                UserDAO userDAO = new UserDAO();
                userDAO.deleteUser(Integer.parseInt(userId));
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("users");
    }
}