package com.valuevault.controllers;

import com.valuevault.config.DBConfig;
import com.valuevault.model.ItemDAO;
import com.valuevault.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/bids")
public class BidsServlet extends HttpServlet {

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

        String itemId = request.getParameter("itemId");
        List<Map<String, Object>> bids = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection()) {
            String sql =
                "SELECT b.id, b.user_id, b.item_id, b.bid_amount, b.status, b.created_at, " +
                "u.name AS user_name, u.role AS user_role, " +
                "i.title AS item_title, i.status AS item_status " +
                "FROM bids b " +
                "JOIN users u ON b.user_id = u.id " +
                "JOIN items i ON b.item_id = i.id";
            if (itemId != null && !itemId.isEmpty()) {
                sql += " WHERE b.item_id = ?";
            }
            sql += " ORDER BY b.created_at DESC";

            PreparedStatement ps = conn.prepareStatement(sql);
            if (itemId != null && !itemId.isEmpty()) {
                ps.setInt(1, Integer.parseInt(itemId));
            }
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> bid = new HashMap<>();
                bid.put("id",          rs.getInt("id"));
                bid.put("item_id",     rs.getInt("item_id"));
                bid.put("user_name",   rs.getString("user_name"));
                bid.put("user_status", "admin".equals(rs.getString("user_role")) ? "Verified Buyer" : "Standard");
                bid.put("bid_amount",  rs.getDouble("bid_amount"));
                bid.put("status",      rs.getString("status"));
                bid.put("created_at",  rs.getTimestamp("created_at"));
                bid.put("item_title",  rs.getString("item_title"));
                bid.put("item_status", rs.getString("item_status")); // needed to hide accept on ended items
                bids.add(bid);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("bids", bids);
        request.getRequestDispatcher("/WEB-INF/pages/admin_bids.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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

        String action = request.getParameter("action");
        String bidId  = request.getParameter("bidId");

        if (bidId == null || bidId.isEmpty()) {
            response.sendRedirect("bids");
            return;
        }

        try (Connection conn = DBConfig.getConnection()) {

            if ("accept".equals(action)) {

                // BUG FIX 5: Only accept if this bid is still pending (prevents double-click re-processing)
                PreparedStatement psCheck = conn.prepareStatement(
                    "SELECT b.item_id FROM bids b WHERE b.id = ? AND b.status = 'pending'");
                psCheck.setInt(1, Integer.parseInt(bidId));
                ResultSet rsCheck = psCheck.executeQuery();

                if (!rsCheck.next()) {
                    // Bid is not pending — already accepted/rejected or doesn't exist, do nothing
                    response.sendRedirect("bids");
                    return;
                }

                int itemId = rsCheck.getInt("item_id");

                // BUG FIX 2: Check if this item already has an accepted bid — block a second acceptance
                PreparedStatement psAlreadySold = conn.prepareStatement(
                    "SELECT COUNT(*) FROM bids WHERE item_id = ? AND status = 'accepted'");
                psAlreadySold.setInt(1, itemId);
                ResultSet rsAlreadySold = psAlreadySold.executeQuery();
                if (rsAlreadySold.next() && rsAlreadySold.getInt(1) > 0) {
                    // Item already has a winner — redirect without doing anything
                    response.sendRedirect("bids");
                    return;
                }

                // 1. Accept this bid
                PreparedStatement psAccept = conn.prepareStatement(
                    "UPDATE bids SET status = 'accepted' WHERE id = ?");
                psAccept.setInt(1, Integer.parseInt(bidId));
                psAccept.executeUpdate();

                // 2. Reject ALL other bids for the same item (pending or otherwise non-accepted)
                PreparedStatement psReject = conn.prepareStatement(
                    "UPDATE bids SET status = 'rejected' WHERE item_id = ? AND id != ? AND status = 'pending'");
                psReject.setInt(1, itemId);
                psReject.setInt(2, Integer.parseInt(bidId));
                psReject.executeUpdate();

                // 3. Mark the item as ended — removes it from shop
                ItemDAO itemDAO = new ItemDAO();
                itemDAO.endItem(itemId);

            } else if ("reject".equals(action)) {
                // Only reject if still pending — prevents re-rejecting an accepted bid
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE bids SET status = 'rejected' WHERE id = ? AND status = 'pending'");
                ps.setInt(1, Integer.parseInt(bidId));
                ps.executeUpdate();
            }

        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
        }

        response.sendRedirect("bids");
    }
}
