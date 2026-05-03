<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - ValueVault</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-left">
            <a href="${pageContext.request.contextPath}/home" style="text-decoration:none;">
    			<img src="${pageContext.request.contextPath}/images/logo.png" 
        			 alt="ValueVault" style="height:48px; width:auto;">
			</a>
        </div>
        <div class="nav-right">
            <a href="${pageContext.request.contextPath}/admin-dashboard" class="active">Dashboard</a>
            <a href="${pageContext.request.contextPath}/users">Users</a>
            <a href="${pageContext.request.contextPath}/items">Items</a>
            <a href="${pageContext.request.contextPath}/bids">Bids</a>
            <a href="${pageContext.request.contextPath}/upload">Upload Item</a>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <div>
                <h1>Admin Dashboard</h1>
                <p>Overview of platform metrics and recent activity.</p>
            </div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-header">
                    <span>Active Listings</span>
                    <span class="stat-icon">📦</span>
                </div>
                <div class="stat-value"><%= request.getAttribute("activeListings") %></div>
            </div>
            <div class="stat-card">
                <div class="stat-header">
                    <span>Pending Bids</span>
                    <span class="stat-icon">⚡</span>
                </div>
                <div class="stat-value"><%= request.getAttribute("pendingBids") %></div>
            </div>
            <div class="stat-card">
                <div class="stat-header">
                    <span>Total Revenue (Accepted)</span>
                    <span class="stat-icon">🏛</span>
                </div>
                <div class="stat-value" style="font-size:22px;">
                    Rs <%= String.format("%,.0f", (Double) request.getAttribute("totalRevenue")) %>
                </div>
            </div>
        </div>

        <div class="dashboard-grid">
            <div class="listing-card">
                <div class="card-header">
                    <h3>Recent Listings</h3>
                    <a href="${pageContext.request.contextPath}/items" style="color:var(--gold);font-size:13px;text-decoration:none;">View All →</a>
                </div>
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Item Name</th>
                            <th>Starting Price</th>
                            <th>Current Bid</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        List<Map<String, Object>> recentItems =
                            (List<Map<String, Object>>) request.getAttribute("recentItems");
                        if (recentItems != null && !recentItems.isEmpty()) {
                            for (Map<String, Object> itm : recentItems) {
                                String st = (String) itm.get("status");
                        %>
                            <tr>
                                <td><%= itm.get("title") %></td>
                                <td>Rs <%= String.format("%,.0f", (Double) itm.get("starting_price")) %></td>
                                <td class="highlight">Rs <%= String.format("%,.0f", (Double) itm.get("current_bid")) %></td>
                                <td><span class="status <%= st %>"><%= st %></span></td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/bids?itemId=<%= itm.get("id") %>"
                                       class="btn-view">Bids</a>
                                </td>
                            </tr>
                        <%
                            }
                        } else {
                        %>
                            <tr>
                                <td colspan="5" class="no-data">No listings yet. <a href="${pageContext.request.contextPath}/upload" style="color:var(--gold);">Upload one →</a></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <div class="actions-card">
                <h3>Quick Actions</h3>
                <a href="${pageContext.request.contextPath}/upload" class="btn-primary full-width">⊕ Add New Item</a>
                <a href="${pageContext.request.contextPath}/bids"
                   class="pending-approval" style="text-decoration:none;margin-top:12px;display:flex;">
                    <span>📋 Pending Bids</span>
                    <span class="badge"><%= request.getAttribute("pendingBids") %></span>
                </a>
                <a href="${pageContext.request.contextPath}/users"
                   class="pending-approval" style="text-decoration:none;margin-top:8px;display:flex;">
                    <span>👥 Manage Users</span>
                </a>
            </div>
        </div>
    </div>
</body>
</html>
