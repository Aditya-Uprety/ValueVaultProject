package com.valuevault.controllers;

import com.valuevault.config.DBConfig;
import com.valuevault.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/items")
public class ItemsServlet extends HttpServlet {

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

        String search = request.getParameter("search");
        ArrayList<Map<String, Object>> items = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection()) {
            String sql;
            PreparedStatement ps;

            if (search != null && !search.trim().isEmpty()) {
                sql = "SELECT * FROM items WHERE title LIKE ? OR description LIKE ? ORDER BY created_at DESC";
                ps = conn.prepareStatement(sql);
                ps.setString(1, "%" + search + "%");
                ps.setString(2, "%" + search + "%");
            } else {
                sql = "SELECT * FROM items ORDER BY created_at DESC";
                ps = conn.prepareStatement(sql);
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("id",            rs.getInt("id"));
                item.put("title",         rs.getString("title"));
                item.put("status",        rs.getString("status"));
                item.put("current_price", rs.getDouble("current_bid"));
                items.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("items",  items);
        request.setAttribute("search", search);
        request.getRequestDispatcher("/WEB-INF/pages/admin_items.jsp").forward(request, response);
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
        String itemId = request.getParameter("itemId");

        if ("delete".equals(action) && itemId != null && !itemId.isEmpty()) {
            try (Connection conn = DBConfig.getConnection()) {
                int id = Integer.parseInt(itemId);

                // Safety check: only allow deleting active items that have no accepted bids
                // Items with accepted bids are already sold — they should not be deletable
                String checkSql =
                    "SELECT COUNT(*) FROM bids WHERE item_id = ? AND status = 'accepted'";
                PreparedStatement checkPs = conn.prepareStatement(checkSql);
                checkPs.setInt(1, id);
                ResultSet rs = checkPs.executeQuery();

                if (rs.next() && rs.getInt(1) > 0) {
                    // Item has an accepted bid — it's already sold, block deletion
                    response.sendRedirect("items?error=sold");
                    return;
                }

                // Safe to delete — cascade will also remove all associated bids
                String deleteSql = "DELETE FROM items WHERE id = ?";
                PreparedStatement deletePs = conn.prepareStatement(deleteSql);
                deletePs.setInt(1, id);
                deletePs.executeUpdate();

            } catch (NumberFormatException | SQLException e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect("items");
    }
}
