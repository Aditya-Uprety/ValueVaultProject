<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Bids - ValueVault</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <nav class="navbar">
        <div class="nav-left">
            <a href="${pageContext.request.contextPath}/admin-dashboard" style="text-decoration:none;">
                <img src="${pageContext.request.contextPath}/images/logo.png"
                     alt="ValueVault" style="height:48px;width:auto;">
            </a>
        </div>
        <div class="nav-right">
            <a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a>
            <a href="${pageContext.request.contextPath}/users">Users</a>
            <a href="${pageContext.request.contextPath}/items">Items</a>
            <a href="${pageContext.request.contextPath}/bids" class="active">Bids</a>
            <a href="${pageContext.request.contextPath}/upload">Upload Item</a>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="page-header">
            <div>
                <h1>Manage Bids</h1>
                <p>Review and authorize pending auction offers.</p>
            </div>
        </div>

        <div class="table-container">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Item</th>
                        <th>Bidder</th>
                        <th>Buyer Type</th>
                        <th>Time Submitted</th>
                        <th>Bid Amount</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    List<Map<String, Object>> bids = (List<Map<String, Object>>) request.getAttribute("bids");
                    if (bids != null && !bids.isEmpty()) {
                        for (Map<String, Object> bid : bids) {
                            String status     = (String) bid.get("status");
                            String itemStatus = bid.get("item_status") != null
                                                ? bid.get("item_status").toString() : "active";
                            String userStatus = bid.get("user_status") != null
                                                ? bid.get("user_status").toString() : "Standard";
                            // BUG FIX 2 (UI): Item is already sold if item_status = 'ended'
                            boolean itemAlreadySold = "ended".equals(itemStatus);
                    %>
                        <tr>
                            <td style="color:var(--text-mid);font-size:13px;">
                                <a href="${pageContext.request.contextPath}/item?id=<%= bid.get("item_id") %>"
                                   style="color:var(--gold);text-decoration:none;">
                                    <%= bid.get("item_title") %>
                                </a>
                                <% if (itemAlreadySold) { %>
                                    <span class="status ended" style="margin-left:6px;font-size:10px;">Sold</span>
                                <% } %>
                            </td>
                            <td><strong><%= bid.get("user_name") %></strong></td>
                            <td>
                                <% if ("Verified Buyer".equals(userStatus)) { %>
                                    <span class="status verified">Verified</span>
                                <% } else { %>
                                    <span class="status standard">Standard</span>
                                <% } %>
                            </td>
                            <td style="color:var(--text-muted);font-size:13px;"><%= bid.get("created_at") %></td>
                            <td class="highlight">Rs <%= String.format("%,.2f", bid.get("bid_amount")) %></td>
                            <td>
                                <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                                    <% if ("pending".equals(status) && !itemAlreadySold) { %>
                                        <%-- BUG FIX 2: Only show Accept/Reject if item is still active --%>
                                        <form action="${pageContext.request.contextPath}/bids" method="post"
                                              style="display:inline;"
                                              onsubmit="return confirm('Accept this bid? All other bids for this item will be rejected and the auction will close.');">
                                            <input type="hidden" name="bidId" value="<%= bid.get("id") %>">
                                            <input type="hidden" name="action" value="accept">
                                            <button type="submit" class="btn-primary small">Accept</button>
                                        </form>
                                        <form action="${pageContext.request.contextPath}/bids" method="post"
                                              style="display:inline;"
                                              onsubmit="return confirm('Reject this bid?');">
                                            <input type="hidden" name="bidId" value="<%= bid.get("id") %>">
                                            <input type="hidden" name="action" value="reject">
                                            <button type="submit" class="btn-reject">Reject</button>
                                        </form>
                                    <% } else if ("pending".equals(status) && itemAlreadySold) { %>
                                        <%-- Item sold but this bid is still pending — auto-label as rejected --%>
                                        <span class="status rejected">Item Sold</span>
                                    <% } else if ("accepted".equals(status)) { %>
                                        <span class="status accepted">Accepted</span>
                                    <% } else { %>
                                        <span class="status rejected">Rejected</span>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                    <%
                        }
                    } else {
                    %>
                        <tr>
                            <td colspan="6" class="no-data">No bids found.</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
