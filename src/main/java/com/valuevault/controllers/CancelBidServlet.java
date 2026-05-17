package com.valuevault.controllers;

import com.valuevault.config.DBConfig;
import com.valuevault.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/cancel-bid")
public class CancelBidServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        User user = (User) session.getAttribute("user");
        String bidIdStr = request.getParameter("bidId");

        if (bidIdStr == null) {
            response.sendRedirect("my-bids");
            return;
        }

        try {
            int bidId = Integer.parseInt(bidIdStr);

            try (Connection conn = DBConfig.getConnection()) {

                // Only allow cancellation if bid belongs to user AND is still 'pending'
                // This blocks cancellation of accepted bids (auction already won)
                String checkSql =
                    "SELECT b.id, b.item_id FROM bids b " +
                    "JOIN items i ON b.item_id = i.id " +
                    "WHERE b.id = ? AND b.user_id = ? AND b.status = 'pending' AND i.status = 'active'";
                PreparedStatement checkPs = conn.prepareStatement(checkSql);
                checkPs.setInt(1, bidId);
                checkPs.setInt(2, user.getId());
                ResultSet rs = checkPs.executeQuery();

                if (rs.next()) {
                    int itemId = rs.getInt("item_id");

                    // Delete the bid
                    String deleteSql = "DELETE FROM bids WHERE id = ?";
                    PreparedStatement deletePs = conn.prepareStatement(deleteSql);
                    deletePs.setInt(1, bidId);
                    deletePs.executeUpdate();

                    // Recalculate current_bid from remaining bids after cancellation
                    // If no bids remain, reset to starting_price
                    String recalcSql =
                        "UPDATE items SET current_bid = COALESCE(" +
                        "  (SELECT MAX(b2.bid_amount) FROM bids b2 WHERE b2.item_id = ?)," +
                        "  (SELECT starting_price FROM items WHERE id = ?)" +
                        ") WHERE id = ?";
                    PreparedStatement recalcPs = conn.prepareStatement(recalcSql);
                    recalcPs.setInt(1, itemId);
                    recalcPs.setInt(2, itemId);
                    recalcPs.setInt(3, itemId);
                    recalcPs.executeUpdate();
                }
                // If bid is accepted or item is ended — silently do nothing (cancellation blocked)
            }

        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect("my-bids");
    }
}
