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
import java.util.List;
import java.util.Map;

@WebServlet("/admin-dashboard")
public class AdminDashboardServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }
        User user = (User) session.getAttribute("user");
        if (!"admin".equals(user.getRole())) {
            response.sendRedirect("home");
            return;
        }

        try (Connection conn = DBConfig.getConnection()) {

            // Active listings count
            PreparedStatement ps1 = conn.prepareStatement(
                "SELECT COUNT(*) FROM items WHERE status = 'active'");
            ResultSet rs1 = ps1.executeQuery();
            int activeListings = rs1.next() ? rs1.getInt(1) : 0;

            // Pending bids count
            PreparedStatement ps2 = conn.prepareStatement(
                "SELECT COUNT(*) FROM bids WHERE status = 'pending'");
            ResultSet rs2 = ps2.executeQuery();
            int pendingBids = rs2.next() ? rs2.getInt(1) : 0;

            // Total revenue: sum of accepted bids
            PreparedStatement ps3 = conn.prepareStatement(
                "SELECT COALESCE(SUM(bid_amount), 0) FROM bids WHERE status = 'accepted'");
            ResultSet rs3 = ps3.executeQuery();
            double totalRevenue = rs3.next() ? rs3.getDouble(1) : 0.0;

            // Recent 5 listings (any status)
            List<Map<String, Object>> recentItems = new ArrayList<>();
            PreparedStatement ps4 = conn.prepareStatement(
                "SELECT id, title, starting_price, current_bid, status FROM items ORDER BY created_at DESC LIMIT 5");
            ResultSet rs4 = ps4.executeQuery();
            while (rs4.next()) {
                Map<String, Object> item = new HashMap<>();
                item.put("id",             rs4.getInt("id"));
                item.put("title",          rs4.getString("title"));
                item.put("starting_price", rs4.getDouble("starting_price"));
                item.put("current_bid",    rs4.getDouble("current_bid"));
                item.put("status",         rs4.getString("status"));
                recentItems.add(item);
            }

            request.setAttribute("activeListings", activeListings);
            request.setAttribute("pendingBids",    pendingBids);
            request.setAttribute("totalRevenue",   totalRevenue);
            request.setAttribute("recentItems",    recentItems);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("activeListings", 0);
            request.setAttribute("pendingBids",    0);
            request.setAttribute("totalRevenue",   0.0);
            request.setAttribute("recentItems",    new ArrayList<>());
        }

        request.getRequestDispatcher("/WEB-INF/pages/admin_dashboard.jsp").forward(request, response);
    }
}
