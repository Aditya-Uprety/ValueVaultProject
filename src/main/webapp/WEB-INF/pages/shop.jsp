<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.valuevault.model.Item" %>
<%@ page import="com.valuevault.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shop - ValueVault</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%
        User loggedUser = (User) session.getAttribute("user");
    %>
    <nav class="navbar">
        <div class="nav-left">
            <a href="${pageContext.request.contextPath}/home" style="text-decoration:none;">
    			<img src="${pageContext.request.contextPath}/images/logo.png" 
        			 alt="ValueVault" style="height:48px; width:auto;">
			</a>
        </div>
        <div class="nav-right">
            <a href="${pageContext.request.contextPath}/home">Home</a>
            <a href="${pageContext.request.contextPath}/shop" class="active">Shop</a>
            <a href="${pageContext.request.contextPath}/my-bids">My Bids</a>
            <a href="${pageContext.request.contextPath}/about">About</a>
            <a href="${pageContext.request.contextPath}/contact">Contact</a>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="search-section">
            <form action="${pageContext.request.contextPath}/shop" method="get" class="search-form">
                <input type="text" name="search" placeholder="Search the vault..."
                       value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
                <button type="submit" class="btn-search">🔍</button>
            </form>
        </div>

        <%
            String searchVal = request.getParameter("search");
            if (searchVal != null && !searchVal.trim().isEmpty()) {
        %>
            <p style="color:var(--text-muted);margin-bottom:16px;font-size:14px;">
                Showing results for: <strong style="color:var(--gold)"><%= searchVal %></strong>
                &nbsp;—&nbsp;<a href="${pageContext.request.contextPath}/shop" style="color:var(--text-muted);text-decoration:underline;">Clear</a>
            </p>
        <% } %>

        <div class="items-grid">
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
                            <div class="placeholder-img">💎</div>
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
                        <a href="${pageContext.request.contextPath}/item?id=<%= item.getId() %>"
                           class="btn-primary">View Auction</a>
                    </div>
                </div>
            <%
                }
            } else {
            %>
                <div style="grid-column:1/-1;text-align:center;color:var(--text-muted);padding:60px 0;">
                    No items found.
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>
