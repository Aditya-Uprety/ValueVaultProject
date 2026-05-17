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
                Fill out the form below and our team will get back to you within 1–2 business days.
            </p>

            <% if ("true".equals(request.getParameter("sent"))) { %>
                <div class="success-msg">
                    Your message has been sent successfully.<br>
                    <span style="font-size:13px;">We've received your enquiry and will respond to your email address within 1–2 business days. Please check your inbox (and spam folder) for our reply.</span>
                </div>
            <% } %>

            <% if (request.getAttribute("error") != null) { %>
                <div class="error-msg"><%= request.getAttribute("error") %></div>
            <% } %>

            <form action="${pageContext.request.contextPath}/contact" method="post">
                <div class="form-group">
                    <label>Full Name</label>
                    <input type="text" name="name" placeholder="Your full name" required>
                </div>
                <div class="form-group">
                    <label>Email Address</label>
                    <input type="email" name="email" placeholder="your@email.com" required>
                </div>
                <div class="form-group">
                    <label>Subject</label>
                    <select name="subject">
                        <option value="General Enquiry">General Enquiry</option>
                        <option value="Item Listing">I want to list an item</option>
                        <option value="Bid Support">Bid / Auction Support</option>
                        <option value="Account Issue">Account Issue</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Message</label>
                    <textarea name="message" rows="6" placeholder="How can we assist you? Please be as detailed as possible." required></textarea>
                </div>
                <button type="submit" class="btn-primary">Send Message</button>
                <p style="color:var(--text-muted);font-size:12px;margin-top:10px;text-align:center;">
                    After submitting, you will see a confirmation on this page. We'll reply to the email address you provided above.
                </p>
            </form>
        </div>

        <div class="contact-info">
            <h2>Get in Touch</h2>

            <p>
                <strong>Our Office</strong><br>
                ValueVault HQ<br>
                Lazimpat Road, Lazimpat<br>
                Kathmandu, Bagmati Province<br>
                Nepal – 44600
            </p>

            <p>
                <strong>Email</strong><br>
                inquiries@valuevault.com
            </p>

            <p>
                <strong>Phone</strong><br>
                +977 01-4XXXXXX
            </p>

            <p>
                <strong>Office Hours</strong><br>
                Sunday – Friday: 10:00 AM – 6:00 PM NPT<br>
                Saturday: Closed
            </p>

            <div style="border-top:1px solid var(--border);padding-top:20px;margin-top:8px;">
                <p style="color:var(--text-muted);font-size:13px;line-height:1.7;">
                    <strong style="color:var(--text-white);">What happens after you send a message?</strong><br>
                    Once you submit the form, our support team is notified of your enquiry. You will see a confirmation message on this page immediately. A member of our team will then review your message and reply directly to the email address you provided, typically within 1–2 business days. For urgent auction-related matters, please mention it clearly in your message.
                </p>
            </div>

            <div style="border-top:1px solid var(--border);padding-top:20px;margin-top:8px;">
                <p style="color:var(--text-muted);font-size:13px;line-height:1.7;">
                    Our specialists are available for confidential consultations regarding high-value assets, private auction arrangements, and partnership enquiries.
                </p>
            </div>
        </div>
    </div>
</body>
</html>
