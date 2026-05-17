<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         isErrorPage="true" %>
<%@ page import="com.valuevault.model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found - ValueVault</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
    <%
        User loggedUser = (session != null) ? (User) session.getAttribute("user") : null;
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
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
            <% } else if (loggedUser != null) { %>
                <a href="${pageContext.request.contextPath}/home">Home</a>
                <a href="${pageContext.request.contextPath}/shop">Shop</a>
                <a href="${pageContext.request.contextPath}/logout" class="btn-logout">Logout</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/home">Home</a>
                <a href="${pageContext.request.contextPath}/login" class="btn-login">Login</a>
            <% } %>
        </div>
    </nav>

    <div class="login-container">
        <div class="login-card" style="text-align:center;padding:52px 40px;">

            <div style="font-family:'Cinzel',serif;font-size:72px;font-weight:700;
                        color:var(--gold);line-height:1;margin-bottom:12px;
                        opacity:.85;">404</div>

            <h1 style="font-family:'Cinzel',serif;font-size:22px;margin-bottom:10px;
                       color:var(--text-white);">Page Not Found</h1>

            <p style="color:var(--text-muted);font-size:14px;line-height:1.7;
                      margin-bottom:28px;">
                The page you are looking for does not exist or may have been moved.<br>
                Please check the URL or navigate back to the platform.
            </p>

            <div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap;">
                <% if (loggedUser != null && isAdmin) { %>
                    <a href="${pageContext.request.contextPath}/admin-dashboard"
                       class="btn-primary" style="width:auto;padding:10px 24px;">
                        Go to Dashboard
                    </a>
                <% } else if (loggedUser != null) { %>
                    <a href="${pageContext.request.contextPath}/home"
                       class="btn-primary" style="width:auto;padding:10px 24px;">
                        Go to Home
                    </a>
                    <a href="${pageContext.request.contextPath}/shop"
                       class="btn-secondary" style="padding:10px 24px;">
                        Browse Auctions
                    </a>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/home"
                       class="btn-primary" style="width:auto;padding:10px 24px;">
                        Go to Home
                    </a>
                    <a href="${pageContext.request.contextPath}/login"
                       class="btn-secondary" style="padding:10px 24px;">
                        Login
                    </a>
                <% } %>
            </div>

        </div>
    </div>
</body>
</html>
