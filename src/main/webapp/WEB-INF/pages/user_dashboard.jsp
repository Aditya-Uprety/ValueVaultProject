<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bids - ValueVault</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-left">
            <a href="${pageContext.request.contextPath}/home" style="text-decoration:none;">
                <img src="${pageContext.request.contextPath}/images/logo.png"
                     alt="ValueVault" style="height:48px;width:auto;">
            </a>
        </div>
        <div class="nav-right">
            <a href="${pageContext.request.contextPath}/home">Home</a>
            <a href="${pageContext.request.contextPath}/shop">Shop</a>
            <a href="${pageContext.request.contextPath}/my-bids" class="active">My Bids</a>
            <a href="${pageContext.request.contextPath}/about">About</a>
            <a href="${pageContext.request.contextPath}/contact">Contact</a>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <div>
                <h1>My Bids</h1>
                <p>Track the status of your current and past auction bids.</p>
            </div>
        </div>

        <div class="bids-table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Item Details</th>
                        <th>Current High Bid</th>
                        <th>Your Bid</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    List<Map<String, Object>> bids = (List<Map<String, Object>>) request.getAttribute("bids");
                    if (bids != null && !bids.isEmpty()) {
                        for (Map<String, Object> bid : bids) {
                            String status      = (String) bid.get("status");
                            String statusClass = status != null ? status.toLowerCase() : "lost";
                            // BUG FIX 1: Determine if auction is still active so we can show/hide cancel
                            // "Winning" on an ended item means the bid was accepted — no cancel allowed
                            // "Winning" on an active item means highest bidder — cancel still allowed
                            boolean auctionEnded = "Lost".equals(status) ||
                                                   ("Winning".equals(status) &&
                                                    "ended".equals(bid.get("item_status")));
                    %>
                        <tr>
                            <td class="item-cell">
                                <div class="item-thumb">
                                    <% if (bid.get("image_url") != null) { %>
                                        <img src="${pageContext.request.contextPath}/images/<%= bid.get("image_url") %>"
                                             alt="">
                                    <% } else { %>
                                        <span style="font-size:10px;font-weight:700;color:var(--gold-dim);letter-spacing:1px;opacity:.6;">VV</span>
                                    <% } %>
                                </div>
                                <div>
                                    <strong><%= bid.get("item_title") %></strong>
                                    <div class="time-remaining" style="font-size:11px;color:var(--text-muted);margin-top:2px;">
                                        <%= auctionEnded ? "Auction Ended" : "Auction Active" %>
                                    </div>
                                </div>
                            </td>
                            <td>Rs <%= String.format("%,.0f", bid.get("current_high_bid")) %></td>
                            <td class="highlight">Rs <%= String.format("%,.0f", bid.get("bid_amount")) %></td>
                            <td>
                                <span class="status <%= statusClass %>"><%= status %></span>
                            </td>
                            <td>
                                <div style="display:flex;gap:8px;flex-wrap:wrap;">
                                    <%
                                    // Action buttons logic
                                    if ("Winning".equals(status) && !auctionEnded) {
                                    %>
                                        <a href="${pageContext.request.contextPath}/item?id=<%= bid.get("item_id") %>"
                                           class="btn-secondary" style="padding:6px 14px;font-size:13px;">View</a>
                                        <a href="${pageContext.request.contextPath}/cancel-bid?bidId=<%= bid.get("id") %>"
                                           class="btn-secondary" style="padding:6px 14px;font-size:13px;"
                                           onclick="return confirm('Are you sure you want to cancel your winning bid? This cannot be undone.');">
                                           Cancel Bid
                                        </a>
                                    <% } else if ("Winning".equals(status) && auctionEnded) { %>
                                        <%-- Auction ended and this user won — show details only, NO cancel --%>
                                        <a href="${pageContext.request.contextPath}/item?id=<%= bid.get("item_id") %>"
                                           class="btn-secondary" style="padding:6px 14px;font-size:13px;">View</a>
                                        <span style="font-size:12px;color:var(--green);align-self:center;font-weight:600;">Won</span>
                                    <% } else if ("Outbid".equals(status)) { %>
                                        <a href="${pageContext.request.contextPath}/item?id=<%= bid.get("item_id") %>"
                                           class="btn-primary small">Bid Again</a>
                                        <a href="${pageContext.request.contextPath}/cancel-bid?bidId=<%= bid.get("id") %>"
                                           class="btn-secondary" style="padding:6px 14px;font-size:13px;"
                                           onclick="return confirm('Cancel your bid on this item?');">Cancel</a>
                                    <% } else { %>
                                        <a href="${pageContext.request.contextPath}/item?id=<%= bid.get("item_id") %>"
                                           class="btn-secondary" style="padding:6px 14px;font-size:13px;">Details</a>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                    <%
                        }
                    } else {
                    %>
                        <tr>
                            <td colspan="5" class="no-data">
                                You haven't placed any bids yet.
                                <a href="${pageContext.request.contextPath}/shop"
                                   style="color:var(--gold);margin-left:8px;">Browse auctions →</a>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
