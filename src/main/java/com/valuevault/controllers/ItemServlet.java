package com.valuevault.controllers;

import com.valuevault.config.DBConfig;
import com.valuevault.model.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/item")
public class ItemServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        // Admins cannot view or bid on items — redirect to their dashboard
        User sessionUser = (User) session.getAttribute("user");
        if ("admin".equals(sessionUser.getRole())) {
            response.sendRedirect("admin-dashboard");
            return;
        }

        String itemIdParam = request.getParameter("id");
        if (itemIdParam == null) {
            response.sendRedirect("shop");
            return;
        }

        try {
            int itemId = Integer.parseInt(itemIdParam);
            ItemDAO itemDAO = new ItemDAO();
            BidDAO  bidDAO  = new BidDAO();

            Item item = itemDAO.getItemById(itemId);
            if (item == null) {
                request.setAttribute("error", "Item not found.");
                request.getRequestDispatcher("/WEB-INF/pages/item.jsp").forward(request, response);
                return;
            }

            int bidCount = bidDAO.getBidCount(itemId);
            request.setAttribute("item",     item);
            request.setAttribute("bidCount", bidCount);

        } catch (NumberFormatException e) {
            response.sendRedirect("shop");
            return;
        }

        request.getRequestDispatcher("/WEB-INF/pages/item.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        // Admins cannot place bids
        User user = (User) session.getAttribute("user");
        if ("admin".equals(user.getRole())) {
            response.sendRedirect("admin-dashboard");
            return;
        }

        String itemIdParam    = request.getParameter("itemId");
        String bidAmountParam = request.getParameter("bidAmount");

        if (itemIdParam == null || bidAmountParam == null) {
            response.sendRedirect("shop");
            return;
        }

        try {
            int    itemId    = Integer.parseInt(itemIdParam);
            double bidAmount = Double.parseDouble(bidAmountParam);

            ItemDAO itemDAO = new ItemDAO();
            BidDAO  bidDAO  = new BidDAO();
            Item    item    = itemDAO.getItemById(itemId);

            if (item == null) {
                response.sendRedirect("shop");
                return;
            }

            // Reject bid if item auction has already ended
            if ("ended".equals(item.getStatus())) {
                request.setAttribute("item",     item);
                request.setAttribute("bidCount", bidDAO.getBidCount(itemId));
                request.setAttribute("error",    "This auction has already ended.");
                request.getRequestDispatcher("/WEB-INF/pages/item.jsp").forward(request, response);
                return;
            }

            // Bid must be strictly higher than current bid
            if (bidAmount <= item.getCurrentBid()) {
                request.setAttribute("item",     item);
                request.setAttribute("bidCount", bidDAO.getBidCount(itemId));
                request.setAttribute("error",
                    "Your bid must be higher than the current bid of Rs " +
                    String.format("%,.0f", item.getCurrentBid()));
                request.getRequestDispatcher("/WEB-INF/pages/item.jsp").forward(request, response);
                return;
            }

            try (Connection conn = DBConfig.getConnection()) {

                // BUG FIX 3: Check if this user already has a pending bid on this item
                // If yes — UPDATE it instead of inserting a duplicate
                String checkExistingSql =
                    "SELECT id FROM bids WHERE user_id = ? AND item_id = ? AND status = 'pending'";
                PreparedStatement checkPs = conn.prepareStatement(checkExistingSql);
                checkPs.setInt(1, user.getId());
                checkPs.setInt(2, itemId);
                ResultSet existingRs = checkPs.executeQuery();

                if (existingRs.next()) {
                    // User already has a pending bid — update the amount instead
                    int existingBidId = existingRs.getInt("id");
                    String updateBidSql = "UPDATE bids SET bid_amount = ? WHERE id = ?";
                    PreparedStatement updateBidPs = conn.prepareStatement(updateBidSql);
                    updateBidPs.setDouble(1, bidAmount);
                    updateBidPs.setInt(2, existingBidId);
                    updateBidPs.executeUpdate();
                } else {
                    // No existing bid — insert new bid
                    String insertSql =
                        "INSERT INTO bids (user_id, item_id, bid_amount, status) VALUES (?, ?, ?, 'pending')";
                    PreparedStatement insertPs = conn.prepareStatement(insertSql);
                    insertPs.setInt(1, user.getId());
                    insertPs.setInt(2, itemId);
                    insertPs.setDouble(3, bidAmount);
                    insertPs.executeUpdate();
                }

                // Update the item's current_bid so everyone sees the new highest amount
                String updateSql = "UPDATE items SET current_bid = ? WHERE id = ?";
                PreparedStatement updateItemPs = conn.prepareStatement(updateSql);
                updateItemPs.setDouble(1, bidAmount);
                updateItemPs.setInt(2, itemId);
                updateItemPs.executeUpdate();
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("shop");
            return;
        } catch (SQLException e) {
            e.printStackTrace();
        }

        response.sendRedirect("item?id=" + itemIdParam);
    }
}
