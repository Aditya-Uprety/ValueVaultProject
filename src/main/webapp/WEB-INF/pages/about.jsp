<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.valuevault.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About - ValueVault</title>
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
                <a href="${pageContext.request.contextPath}/home">Home</a>
                <a href="${pageContext.request.contextPath}/shop">Shop</a>
                <a href="${pageContext.request.contextPath}/my-bids">My Bids</a>
                <a href="${pageContext.request.contextPath}/about" class="active">About</a>
                <a href="${pageContext.request.contextPath}/contact">Contact</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/home">Home</a>
                <a href="${pageContext.request.contextPath}/about" class="active">About</a>
                <a href="${pageContext.request.contextPath}/contact">Contact</a>
                <a href="${pageContext.request.contextPath}/login" class="btn-login">Login</a>
            <% } %>
        </div>
    </nav>

    <div class="about-container">
        <h1>About ValueVault</h1>
        <p>ValueVault is a premier online auction platform specialising in high-value assets. From vintage watches and fine jewelry to rare collectibles and luxury electronics, we connect discerning buyers with exclusive sellers in a secure, transparent environment.</p>
        <p>Our mission is to provide a trusted marketplace where every item is authenticated, every bid is validated, and every transaction is seamless. Founded in 2024, ValueVault has quickly become the go-to destination for collectors and enthusiasts worldwide.</p>
    </div>
</body>
</html>
