<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - ValueVault</title>
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
        <div class="login-card" style="width:460px;">

            <%
                String step = (String) request.getAttribute("step");
                if (step == null) step = "email"; // default first step
            %>

            <%-- ── Step 1: Enter Email ── --%>
            <% if ("email".equals(step)) { %>
                <div class="login-icon">
                    <img src="${pageContext.request.contextPath}/images/logo.png" alt="ValueVault" style="height:64px;width:auto;">
                </div>
                <h1>Forgot Password</h1>
                <p class="subtitle">Enter your registered email address and we'll ask you a security question.</p>

                <% if (request.getAttribute("error") != null) { %>
                    <div class="error-msg"><%= request.getAttribute("error") %></div>
                <% } %>

                <form action="${pageContext.request.contextPath}/forgot-password" method="post">
                    <input type="hidden" name="action" value="lookup">
                    <div class="form-group">
                        <label>Email Address</label>
                        <input type="email" name="email" placeholder="name@example.com" required autofocus>
                    </div>
                    <button type="submit" class="btn-primary">Continue</button>
                </form>
                <p class="footer-text" style="margin-top:16px;">
                    <a href="${pageContext.request.contextPath}/login" style="color:var(--gold);">Back to Login</a>
                </p>

            <%-- ── Step 2: Answer Security Question ── --%>
            <% } else if ("question".equals(step)) { %>
                <div class="login-icon">
                    <img src="${pageContext.request.contextPath}/images/logo.png" alt="ValueVault" style="height:64px;width:auto;">
                </div>
                <h1>Security Check</h1>
                <p class="subtitle">Please answer your security question to verify your identity.</p>

                <% if (request.getAttribute("error") != null) { %>
                    <div class="error-msg"><%= request.getAttribute("error") %></div>
                <% } %>

                <div style="background:var(--bg-input);border:1px solid var(--border);border-radius:var(--radius-sm);padding:14px 16px;margin-bottom:20px;">
                    <span style="color:var(--text-muted);font-size:11px;font-weight:700;letter-spacing:.8px;text-transform:uppercase;display:block;margin-bottom:6px;">Your Security Question</span>
                    <span style="color:var(--text-white);font-size:15px;"><%= request.getAttribute("securityQuestion") %></span>
                </div>

                <form action="${pageContext.request.contextPath}/forgot-password" method="post">
                    <input type="hidden" name="action" value="verify">
                    <div class="form-group">
                        <label>Your Answer</label>
                        <input type="text" name="securityAnswer" placeholder="Type your answer here" required autofocus>
                    </div>
                    <button type="submit" class="btn-primary">Verify</button>
                </form>
                <p class="footer-text" style="margin-top:16px;">
                    <a href="${pageContext.request.contextPath}/forgot-password" style="color:var(--gold);">Try a different email</a>
                </p>

            <%-- ── Step 3: Set New Password ── --%>
            <% } else if ("reset".equals(step)) { %>
                <div class="login-icon">
                    <img src="${pageContext.request.contextPath}/images/logo.png" alt="ValueVault" style="height:64px;width:auto;">
                </div>
                <h1>Set New Password</h1>
                <p class="subtitle">Identity verified. Please choose a new password for your account.</p>

                <% if (request.getAttribute("error") != null) { %>
                    <div class="error-msg"><%= request.getAttribute("error") %></div>
                <% } %>

                <form action="${pageContext.request.contextPath}/forgot-password" method="post">
                    <input type="hidden" name="action" value="reset">
                    <div class="form-group">
                        <label>New Password</label>
                        <input type="password" name="newPassword" placeholder="At least 6 characters" required autofocus>
                    </div>
                    <div class="form-group">
                        <label>Confirm New Password</label>
                        <input type="password" name="confirmPassword" placeholder="Repeat your new password" required>
                    </div>
                    <button type="submit" class="btn-primary">Reset Password</button>
                </form>
            <% } %>

        </div>
    </div>
</body>
</html>
