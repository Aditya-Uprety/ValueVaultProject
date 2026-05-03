package com.valuevault.controllers;

import com.valuevault.config.DBConfig;
import com.valuevault.model.User;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/my-bids")
public class MyBidsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        User user = (User) session.getAttribute("user");
        List<Map<String, Object>> bids = new ArrayList<>();

        try (Connection conn = DBConfig.getConnection()) {
            String sql = "SELECT b.id, b.bid_amount, b.status, " +
                         "i.title AS item_title, i.current_bid AS current_high_bid, " +
                         "i.image_url, i.id AS item_id, i.status AS item_status, " +
                         "(SELECT MAX(b2.bid_amount) FROM bids b2 WHERE b2.item_id = i.id) AS max_bid " +
                         "FROM bids b " +
                         "JOIN items i ON b.item_id = i.id " +
                         "WHERE b.user_id = ? " +
                         "ORDER BY b.created_at DESC";

            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, user.getId());
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Map<String, Object> bid = new HashMap<>();
                bid.put("id",               rs.getInt("id"));
                bid.put("bid_amount",       rs.getDouble("bid_amount"));
                bid.put("item_title",       rs.getString("item_title"));
                bid.put("current_high_bid", rs.getDouble("current_high_bid"));
                bid.put("image_url",        rs.getString("image_url"));
                bid.put("item_id",          rs.getInt("item_id"));
                // BUG FIX 1: Pass item_status so JSP can decide whether to show cancel button
                bid.put("item_status",      rs.getString("item_status"));

                String dbStatus    = rs.getString("status");
                String itemStatus  = rs.getString("item_status");
                double userBidAmt  = rs.getDouble("bid_amount");
                double maxBid      = rs.getDouble("max_bid");

                String displayStatus;
                if ("ended".equals(itemStatus)) {
                    // Auction ended — winner is the one with accepted bid
                    if ("accepted".equals(dbStatus)) {
                        displayStatus = "Winning"; // Won the auction
                    } else {
                        displayStatus = "Lost";
                    }
                } else {
                    // Auction still active
                    if ("rejected".equals(dbStatus)) {
                        displayStatus = "Lost";
                    } else if (userBidAmt >= maxBid) {
                        displayStatus = "Winning";
                    } else {
                        displayStatus = "Outbid";
                    }
                }

                bid.put("status", displayStatus);
                bids.add(bid);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        request.setAttribute("bids", bids);
        request.getRequestDispatcher("/WEB-INF/pages/user_dashboard.jsp").forward(request, response);
    }
}
