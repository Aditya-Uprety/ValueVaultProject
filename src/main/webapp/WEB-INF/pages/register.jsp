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
        <div class="login-card" style="width:460px;">
            <div class="login-icon">
    			<img src="${pageContext.request.contextPath}/images/logo.png" alt="ValueVault" style="height:64px;width:auto;">
			</div>
            <h1>Join ValueVault</h1>
            <p class="subtitle">Create an account to participate in high-end auctions.</p>

            <% if(request.getAttribute("error") != null) { %>
                <div class="error-msg"><%= request.getAttribute("error") %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/register" method="post">
                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text" name="name" placeholder="John Doe" required>
                </div>
                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" name="email" placeholder="john@example.com" required>
                </div>
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" name="password" placeholder="At least 6 characters" required>
                </div>
                <div class="form-group">
                    <label>Confirm Password</label>
                    <input type="password" name="confirmPassword" placeholder="Repeat your password" required>
                </div>

                <%-- ── Security Question Section ── --%>
                <div style="border-top:1px solid var(--border);padding-top:18px;margin-top:4px;margin-bottom:4px;">
                    <p style="color:var(--text-muted);font-size:12px;margin-bottom:14px;">
                        🔐 Choose a security question — this will be used to recover your account if you forget your password.
                    </p>
                    <div class="form-group">
                        <label>Security Question</label>
                        <select name="securityQuestion" required
        					oninvalid="this.setCustomValidity('Please select a security question.')"
        					oninput="this.setCustomValidity('')">
                            <option value="" disabled selected>— Select a question —</option>
                            <option value="What is the name of your first pet?">What is the name of your first pet?</option>
                            <option value="What is your mother's maiden name?">What is your mother's maiden name?</option>
                            <option value="What city were you born in?">What city were you born in?</option>
                            <option value="What was the name of your primary school?">What was the name of your primary school?</option>
                            <option value="What is your favourite childhood book?">What is your favourite childhood book?</option>
                            <option value="What street did you grow up on?">What street did you grow up on?</option>
                            <option value="What is the name of your oldest sibling?">What is the name of your oldest sibling?</option>
                            <option value="What was your childhood nickname?">What was your childhood nickname?</option>
                            <option value="What is the name of the town your nearest relative lives in?">What is the name of the town your nearest relative lives in?</option>
                            <option value="What was the make and model of your first car?">What was the make and model of your first car?</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Your Answer</label>
                        <input type="text" name="securityAnswer" placeholder="Type your answer (case-insensitive)" required>
                    </div>
                </div>

                <button type="submit" class="btn-primary">Register</button>
            </form>
            <p class="footer-text">Already have an account? <a href="${pageContext.request.contextPath}/login">Login</a></p>
        </div>
    </div>
</body>
</html>
