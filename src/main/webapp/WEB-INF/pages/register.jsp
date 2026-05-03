<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - ValueVault</title>
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
            <a href="${pageContext.request.contextPath}/home">Home</a>
            <a href="${pageContext.request.contextPath}/about">About</a>
            <a href="${pageContext.request.contextPath}/contact">Contact</a>
            <a href="${pageContext.request.contextPath}/login" class="btn-login">Login</a>
        </div>
    </nav>

    <div class="login-container">
        <div class="login-card">
            <div class="login-icon">📋</div>
            <h1>Join ValueVault</h1>
            <p class="subtitle">Create an account to participate in high-end auctions.</p>

            <% if(request.getAttribute("error") != null) { %>
                <div class="error-msg"><%= request.getAttribute("error") %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/register" method="post">
                <div class="form-group">
                    <label>Name</label>
                    <input type="text" name="name" placeholder="John Doe" required>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" placeholder="john@example.com" required>
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" name="password" placeholder="••••••••" required>
                </div>
                <div class="form-group">
                    <label>Confirm Password</label>
                    <input type="password" name="confirmPassword" placeholder="••••••••" required>
                </div>
                <button type="submit" class="btn-primary">Register →</button>
            </form>
            <p class="footer-text">Already have an account? <a href="${pageContext.request.contextPath}/login">Login</a></p>
        </div>
    </div>
</body>
</html>
