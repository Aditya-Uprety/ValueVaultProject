<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.valuevault.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact - ValueVault</title>
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
                <a href="${pageContext.request.contextPath}/about">About</a>
                <a href="${pageContext.request.contextPath}/contact" class="active">Contact</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/home">Home</a>
                <a href="${pageContext.request.contextPath}/about">About</a>
                <a href="${pageContext.request.contextPath}/contact" class="active">Contact</a>
                <a href="${pageContext.request.contextPath}/login" class="btn-login">Login</a>
            <% } %>
        </div>
    </nav>

    <div class="contact-layout">
        <div class="contact-form">
            <h2>Contact Us</h2>
            <p style="color:var(--text-muted);margin-bottom:24px;font-size:14px;">
                Please fill out the form below and we will get back to you promptly.
            </p>

            <% if ("true".equals(request.getParameter("sent"))) { %>
                <div class="success-msg">Your message has been sent. We'll be in touch shortly.</div>
            <% } %>

            <form action="${pageContext.request.contextPath}/contact" method="post">
                <div class="form-group">
                    <label>Name</label>
                    <input type="text" name="name" placeholder="Your full name" required>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" placeholder="your@email.com" required>
                </div>
                <div class="form-group">
                    <label>Message</label>
                    <textarea name="message" rows="6" placeholder="How can we assist you?" required></textarea>
                </div>
                <button type="submit" class="btn-primary">➤ Send Message</button>
            </form>
        </div>

        <div class="contact-info">
            <h2>Secure Inquiries</h2>
            <p><strong>📍 Address</strong><br>123 Vault Avenue, Financial District</p>
            <p><strong>📧 Email</strong><br>inquiries@valuevault.com</p>
            <p style="margin-top:24px;">
                Our specialists are available for confidential consultations regarding
                high-value assets and auction procedures.
            </p>
        </div>
    </div>
</body>
</html>
