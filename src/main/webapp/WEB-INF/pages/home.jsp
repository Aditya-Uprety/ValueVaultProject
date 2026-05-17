<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.valuevault.model.Item" %>
<%@ page import="com.valuevault.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ValueVault - Premium Asset Auctions</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%
        User loggedUser = (User) session.getAttribute("user");
        boolean isAdmin = loggedUser != null && "admin".equals(loggedUser.getRole());
    %>
    <nav class="navbar">
        <div class="nav-left">
           <a href="${pageContext.request.contextPath}/home" style="text-decoration:none;">
                <img src="${pageContext.request.contextPath}/images/logo.png"
                     alt="ValueVault" style="height:48px; width:auto;">
           </a>
        </div>
        <div class="nav-right">
            <% if (loggedUser != null && isAdmin) { %>
                <a href="${pageContext.request.contextPath}/admin-dashboard">Dashboard</a>
                <a href="${pageContext.request.contextPath}/users">Users</a>
                <a href="${pageContext.request.contextPath}/items">Items</a>
                <a href="${pageContext.request.contextPath}/bids">Bids</a>
                <a href="${pageContext.request.contextPath}/upload">Upload Item</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
            <% } else if (loggedUser != null) { %>
                <a href="${pageContext.request.contextPath}/home" class="active">Home</a>
                <a href="${pageContext.request.contextPath}/shop">Shop</a>
                <a href="${pageContext.request.contextPath}/my-bids">My Bids</a>
                <a href="${pageContext.request.contextPath}/about">About</a>
                <a href="${pageContext.request.contextPath}/contact">Contact</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/home" class="active">Home</a>
                <a href="${pageContext.request.contextPath}/about">About</a>
                <a href="${pageContext.request.contextPath}/contact">Contact</a>
                <a href="${pageContext.request.contextPath}/login" class="btn-login">Login</a>
            <% } %>
        </div>
    </nav>

    <%-- logo image  --%>
    <div class="hero">
        <div class="hero-logo-icon">
            <img src="${pageContext.request.contextPath}/images/logo.png"
                 alt="ValueVault"
                 style="height:110px;width:auto;opacity:0.85;">
        </div>
        <h1>ValueVault</h1>
        <p>Premium Asset Auctions</p>
    </div>

    <div class="home-items-grid">
        <%
        List<Item> items = (List<Item>) request.getAttribute("items");
        if (items != null && !items.isEmpty()) {
            for (Item item : items) {
        %>
            <div class="item-card">
                <div class="item-image">
                    <% if (item.getImageUrl() != null && !item.getImageUrl().isEmpty()) { %>
                        <img src="${pageContext.request.contextPath}/images/<%= item.getImageUrl() %>"
                             alt="<%= item.getTitle() %>">
                    <% } else { %>
                        <div class="placeholder-img" style="font-size:13px;font-weight:700;color:var(--gold-dim);letter-spacing:2px;opacity:.5;">VV</div>
                    <% } %>
                </div>
                <div class="item-details">
                    <h3><%= item.getTitle() %></h3>
                    <div class="bid-info">
                        <div>
                            <span class="label">Current Bid</span>
                            <span class="price">Rs <%= String.format("%,.0f", item.getCurrentBid()) %></span>
                        </div>
                    </div>
                    <% if (loggedUser != null) { %>
                        <a href="${pageContext.request.contextPath}/item?id=<%= item.getId() %>" class="btn-primary">VIEW AUCTION</a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/login" class="btn-primary">LOGIN TO BID</a>
                    <% } %>
                </div>
            </div>
        <%
            }
        } else {
        %>
            <div class="no-items" style="color:var(--text-muted);grid-column:1/-1;text-align:center;padding:60px 0;">
                No auction items available at the moment.
            </div>
        <% } %>
    </div>
</body>
</html>
